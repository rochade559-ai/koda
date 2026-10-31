const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { setGlobalOptions } = require('firebase-functions/v2');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
require('dotenv').config();

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({
  region: 'southamerica-east1',
  maxInstances: 10,
  memory: '256MiB',
  timeoutSeconds: 60,
});

const CRYPTON_POR_DESBLOQUEIO = 25;
const MAX_HISTORICO = 10;

const PACOTES = {
  basico: { id: 'basico', nome: 'Básico', cryptons: 50, precoCentavos: 2500, descricao: '2 desbloqueios de contato' },
  popular: { id: 'popular', nome: 'Popular', cryptons: 100, precoCentavos: 4500, descricao: '4 desbloqueios de contato' },
  premium: { id: 'premium', nome: 'Premium', cryptons: 200, precoCentavos: 8000, descricao: '8 desbloqueios de contato' },
};

function setCors(res) {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.set('Access-Control-Max-Age', '3600');
}

async function garantirCarteira(uid, email) {
  const ref = db.collection('carteiras').doc(uid);
  const snap = await ref.get();
  if (!snap.exists) {
    await ref.set({
      uid, email, saldo_cryptons: 0, total_comprado: 0, total_gasto: 0,
      criado_em: admin.firestore.FieldValue.serverTimestamp(),
      atualizado_em: admin.firestore.FieldValue.serverTimestamp(),
    });
    return 0;
  }
  return snap.data().saldo_cryptons || 0;
}

function tsParaIso(ts) {
  if (!ts) return null;
  if (typeof ts.toDate === 'function') return ts.toDate().toISOString();
  if (ts instanceof Date) return ts.toISOString();
  return String(ts);
}

async function limparHistoricoAntigo(uid, colecao, maxItens = MAX_HISTORICO) {
  try {
    const snap = await db.collection(colecao).where('uid', '==', uid).limit(50).get();
    if (snap.size <= maxItens) return;

    const docs = snap.docs
      .map((d) => {
        const criado = d.data().criado_em;
        let data = new Date(0);
        if (criado && typeof criado.toDate === 'function') data = criado.toDate();
        return { ref: d.ref, criado_em: data };
      })
      .sort((a, b) => b.criado_em - a.criado_em);

    const paraDeletar = docs.slice(maxItens);
    if (paraDeletar.length === 0) return;

    const batch = db.batch();
    paraDeletar.forEach((d) => batch.delete(d.ref));
    await batch.commit();

    logger.info(`🧹 Limpeza: ${paraDeletar.length} doc(s) antigos removidos de ${colecao} (uid ${uid})`);
  } catch (err) {
    logger.error('Erro na limpeza de histórico:', err);
  }
}

exports.listarPacotesCrypton = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Faça login.');
  return { pacotes: Object.values(PACOTES), cryptonPorDesbloqueio: CRYPTON_POR_DESBLOQUEIO };
});

exports.consultarCarteira = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Faça login.');
  const uid = request.auth.uid;
  const email = request.auth.token.email || '';
  const saldo = await garantirCarteira(uid, email);

  const comprasSnap = await db.collection('compras_tokens').where('uid', '==', uid).limit(50).get();
  const compras = comprasSnap.docs.map((d) => {
    const data = d.data();
    return { id: d.id, pacote: data.pacote, cryptons: data.cryptons, valor: data.valor, status: data.status, criado_em: tsParaIso(data.criado_em) };
  }).sort((a, b) => (b.criado_em ?? '').localeCompare(a.criado_em ?? '')).slice(0, MAX_HISTORICO);

  const usoSnap = await db.collection('historico_uso').where('uid', '==', uid).limit(50).get();
  const usos = usoSnap.docs.map((d) => {
    const data = d.data();
    return { id: d.id, anuncio_titulo: data.anuncio_titulo, cryptons: data.cryptons, criado_em: tsParaIso(data.criado_em) };
  }).sort((a, b) => (b.criado_em ?? '').localeCompare(a.criado_em ?? '')).slice(0, MAX_HISTORICO);

  return { saldo, compras, usos };
});

exports.criarSessaoCheckoutStripe = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Faça login.');

  const uid = request.auth.uid;
  const email = request.auth.token.email || '';
  const { pacoteId } = request.data || {};

  if (!pacoteId || !PACOTES[pacoteId]) {
    throw new HttpsError('invalid-argument', 'Pacote inválido.');
  }

  const pacote = PACOTES[pacoteId];

  try {
    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: [{
        price_data: {
          currency: 'brl',
          product_data: { name: `Pacote ${pacote.nome} - ${pacote.cryptons} Cryptons` },
          unit_amount: pacote.precoCentavos,
        },
        quantity: 1,
      }],
      customer_email: email,
      success_url: `https://kodaff.com/#/market/carteira?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `https://kodaff.com/#/market/comprar-cryptons`,
      metadata: { uid, pacote_id: pacote.id, cryptons: String(pacote.cryptons), valor: String(pacote.precoCentavos) },
    });

    await db.collection('compras_tokens').doc(session.id).set({
      uid, email, pacote: pacoteId, cryptons: pacote.cryptons,
      valor: pacote.precoCentavos / 100,
      stripe_session_id: session.id,
      status: 'pendente',
      criado_em: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info('Sessão Stripe criada:', session.id);
    return { checkoutUrl: session.url, sessionId: session.id };
  } catch (error) {
    logger.error('Erro Stripe:', error.message);
    throw new HttpsError('internal', `Falha ao criar checkout: ${error.message}`);
  }
});

exports.webhookStripe = onRequest(async (req, res) => {
  setCors(res);
  if (req.method === 'OPTIONS') { res.status(204).send(''); return; }
  if (req.method !== 'POST') { res.status(405).send('Method not allowed'); return; }

  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  if (!endpointSecret || !sig) {
    logger.error('Segredo ou assinatura do webhook ausente');
    return res.status(400).send('Webhook não configurado');
  }

  let event;
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (err) {
    logger.error('Assinatura inválida:', err.message);
    return res.status(400).send('Assinatura inválida');
  }

  logger.info('===== WEBHOOK STRIPE =====');
  logger.info('Tipo:', event.type);

  try {
    const tiposQueCreditam = ['checkout.session.completed', 'checkout.session.async_payment_succeeded'];

    if (!tiposQueCreditam.includes(event.type)) {
      logger.info('Evento ignorado (não credita):', event.type);
      return res.status(200).send('Evento ignorado');
    }

    const session = event.data.object;

    if (session.payment_status !== 'paid') {
      logger.info('Pagamento ainda não confirmado:', session.id, '| status:', session.payment_status);
      return res.status(200).send('Pagamento ainda não confirmado');
    }

    const metadata = session.metadata || {};
    const uid = metadata.uid;
    const cryptons = parseInt(metadata.cryptons || '0', 10);
    const sessionId = session.id;

    if (!uid || cryptons <= 0) {
      logger.error('Metadata inválido:', JSON.stringify(metadata));
      return res.status(200).send('Metadata inválido');
    }

    const compraRef = db.collection('compras_tokens').doc(sessionId);
    const carteiraRef = db.collection('carteiras').doc(uid);

    await db.runTransaction(async (tx) => {
      const compraSnap = await tx.get(compraRef);
      if (compraSnap.exists && compraSnap.data().status === 'pago') {
        logger.info('Compra já paga (idempotência):', sessionId);
        return;
      }

      const carteiraSnap = await tx.get(carteiraRef);
      if (!carteiraSnap.exists) {
        tx.set(carteiraRef, {
          uid, email: session.customer_email || '', saldo_cryptons: cryptons,
          total_comprado: cryptons, total_gasto: 0,
          criado_em: admin.firestore.FieldValue.serverTimestamp(),
          atualizado_em: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(carteiraRef, {
          saldo_cryptons: admin.firestore.FieldValue.increment(cryptons),
          total_comprado: admin.firestore.FieldValue.increment(cryptons),
          atualizado_em: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      if (compraSnap.exists) {
        tx.update(compraRef, { status: 'pago', pago_em: admin.firestore.FieldValue.serverTimestamp() });
      } else {
        tx.set(compraRef, {
          uid, email: session.customer_email || '',
          pacote: metadata.pacote_id || 'desconhecido',
          cryptons, valor: parseInt(metadata.valor || '0', 10) / 100,
          stripe_session_id: sessionId, status: 'pago',
          criado_em: admin.firestore.FieldValue.serverTimestamp(),
          pago_em: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    logger.info(`✅ Créditos adicionados: ${cryptons} para ${uid}`);
    await limparHistoricoAntigo(uid, 'compras_tokens');
    res.status(200).send('OK');
  } catch (error) {
    logger.error('❌ Erro webhook:', error);
    res.status(500).send('Erro');
  }
});

exports.desbloquearComCrypton = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Faça login.');

  const uid = request.auth.uid;
  const email = request.auth.token.email || '';
  const { anuncioId } = request.data || {};

  if (!anuncioId) throw new HttpsError('invalid-argument', 'Anúncio não informado.');

  const anuncioSnap = await db.collection('anuncios').doc(anuncioId).get();
  if (!anuncioSnap.exists) throw new HttpsError('not-found', 'Anúncio não encontrado.');
  const anuncioData = anuncioSnap.data();

  const jaDesb = await db.collection('desbloqueios')
    .where('anuncio_id', '==', anuncioId)
    .where('comprador_uid', '==', uid)
    .where('status', '==', 'aprovado').limit(1).get();

  if (!jaDesb.empty) throw new HttpsError('already-exists', 'Você já desbloqueou este contato.');

  const saldo = await garantirCarteira(uid, email);
  if (saldo < CRYPTON_POR_DESBLOQUEIO) {
    throw new HttpsError('failed-precondition', `Saldo insuficiente. Você tem ${saldo} Cryptons e precisa de ${CRYPTON_POR_DESBLOQUEIO}.`);
  }

  const carteiraRef = db.collection('carteiras').doc(uid);

  await db.runTransaction(async (tx) => {
    const carteiraSnap = await tx.get(carteiraRef);
    const saldoAtual = carteiraSnap.data().saldo_cryptons || 0;
    if (saldoAtual < CRYPTON_POR_DESBLOQUEIO) throw new Error('Saldo insuficiente.');

    tx.update(carteiraRef, {
      saldo_cryptons: saldoAtual - CRYPTON_POR_DESBLOQUEIO,
      total_gasto: admin.firestore.FieldValue.increment(CRYPTON_POR_DESBLOQUEIO),
      atualizado_em: admin.firestore.FieldValue.serverTimestamp(),
    });

    const desbRef = db.collection('desbloqueios').doc();
    tx.set(desbRef, {
      anuncio_id: anuncioId, comprador_uid: uid,
      cryptons_gastos: CRYPTON_POR_DESBLOQUEIO, status: 'aprovado', metodo: 'crypton',
      criado_em: admin.firestore.FieldValue.serverTimestamp(),
    });

    const usoRef = db.collection('historico_uso').doc();
    tx.set(usoRef, {
      uid, anuncio_id: anuncioId, anuncio_titulo: anuncioData.titulo || 'Anúncio',
      cryptons: CRYPTON_POR_DESBLOQUEIO,
      criado_em: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await limparHistoricoAntigo(uid, 'historico_uso');

  return { sucesso: true, saldo_restante: saldo - CRYPTON_POR_DESBLOQUEIO, cryptons_gastos: CRYPTON_POR_DESBLOQUEIO };
});