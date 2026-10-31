import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this); // 👈 Mudou para 5
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Painel Admin'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: AppColors.goldLight,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Empresas'),
            Tab(text: 'Investidores'),
            Tab(text: 'Construção'),
            Tab(text: 'Especializada'),
            Tab(text: 'Usuários'), // 👈 NOVA ABA
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ListaLeads(
            stream: AdminService.leadsEmpresas(),
            colecao: 'leads_empresas',
            tipo: _TipoLead.empresa,
          ),
          _ListaLeads(
            stream: AdminService.leadsInvestidores(),
            colecao: 'leads_investidores',
            tipo: _TipoLead.investidor,
          ),
          _ListaLeads(
            stream: AdminService.leadsConstrucao(),
            colecao: 'leads_construcao',
            tipo: _TipoLead.construcao,
          ),
          _ListaLeads(
            stream: AdminService.ajudaEspecializada(),
            colecao: 'ajuda_especializada',
            tipo: _TipoLead.ajuda,
          ),
          _ListaUsuarios(
            stream: AdminService.usuarios(),
          ),
        ],
      ),
    );
  }
}

enum _TipoLead { empresa, investidor, construcao, ajuda }

class _ListaLeads extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final String colecao;
  final _TipoLead tipo;

  const _ListaLeads({
    required this.stream,
    required this.colecao,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Erro: ${snapshot.error}'),
            ),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma solicitação ainda.',
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _CardLead(
              docId: doc.id,
              colecao: colecao,
              data: data,
              tipo: tipo,
            );
          },
        );
      },
    );
  }
}

class _CardLead extends StatelessWidget {
  final String docId;
  final String colecao;
  final Map<String, dynamic> data;
  final _TipoLead tipo;

  const _CardLead({
    required this.docId,
    required this.colecao,
    required this.data,
    required this.tipo,
  });

  String get _titulo {
    switch (tipo) {
      case _TipoLead.empresa:
        return data['nome_responsavel'] ?? 'Sem nome';
      case _TipoLead.investidor:
        return data['nome'] ?? data['email'] ?? 'Sem nome';
      case _TipoLead.construcao:
        return data['nome'] ?? 'Sem nome';
      case _TipoLead.ajuda:
        return data['nome'] ?? 'Sem nome';
    }
  }

  String get _subtitulo {
    switch (tipo) {
      case _TipoLead.empresa:
        return 'CNPJ: ${data['cnpj'] ?? '-'}';
      case _TipoLead.investidor:
        return data['email'] ?? '-';
      case _TipoLead.construcao:
        return '${data['tipo_imovel'] ?? '-'} • ${data['localizacao'] ?? '-'}';
      case _TipoLead.ajuda:
        final tipoAjuda = (data['tipo_ajuda'] ?? '').toString();
        final label = tipoAjuda == 'advogado' ? 'Advogado' : 'Engenheiro';
        final esp = data['especialidade'] ?? '-';
        return '$label • $esp';
    }
  }

  Color? get _corTipo {
    if (tipo != _TipoLead.ajuda) return null;
    return data['tipo_ajuda'] == 'advogado'
        ? const Color(0xFF1E3A8A)
        : const Color(0xFFEA580C);
  }

  String _formatarValorCausa(dynamic valor) {
    if (valor == null) return '-';
    final n = valor is int ? valor : int.tryParse(valor.toString());
    if (n == null) return '-';
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'R\$ $buf,00';
  }

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'em_analise') as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (_corTipo != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _corTipo!.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _corTipo!.withOpacity(0.3)),
                ),
                child: Text(
                  data['tipo_ajuda'] == 'advogado' ? 'ADV' : 'ENG',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: _corTipo,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _subtitulo,
            style: const TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
        ),
        trailing: _ChipStatus(status: status),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          if (tipo == _TipoLead.ajuda && data['valor_causa'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_rounded,
                        color: Color(0xFF1E3A8A), size: 18),
                    const SizedBox(width: 10),
                    const Text(
                      'Valor da causa:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatarValorCausa(data['valor_causa']),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ...data.entries.map((e) {
            if (e.key == 'dados_cnpj' ||
                e.key == 'uid' ||
                e.key == 'criado_em' ||
                e.key == 'ultimo_login' ||
                e.key == 'status') {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      '${e.key}:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${e.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Alterar status:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const Spacer(),
              _BotaoStatus(
                label: 'Em análise',
                cor: AppColors.warning,
                ativo: status == 'em_analise',
                onTap: () => AdminService.atualizarStatus(
                  colecao: colecao,
                  leadId: docId,
                  novoStatus: 'em_analise',
                ),
              ),
              const SizedBox(width: 6),
              _BotaoStatus(
                label: 'Aprovado',
                cor: AppColors.success,
                ativo: status == 'aprovado',
                onTap: () => AdminService.atualizarStatus(
                  colecao: colecao,
                  leadId: docId,
                  novoStatus: 'aprovado',
                ),
              ),
              const SizedBox(width: 6),
              _BotaoStatus(
                label: 'Recusado',
                cor: AppColors.error,
                ativo: status == 'recusado',
                onTap: () => AdminService.atualizarStatus(
                  colecao: colecao,
                  leadId: docId,
                  novoStatus: 'recusado',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 👇 NOVA LISTA DE USUÁRIOS
// ============================================================
class _ListaUsuarios extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  const _ListaUsuarios({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Erro: ${snapshot.error}'),
            ),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum usuário cadastrado ainda.',
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _CardUsuario(data: data);
          },
        );
      },
    );
  }
}

class _CardUsuario extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CardUsuario({required this.data});

  @override
  Widget build(BuildContext context) {
    final nome = data['nome'] ?? 'Sem nome';
    final email = data['email'] ?? 'Sem e-mail';
    final foto = data['foto'];

    String ultimoLogin = 'Nunca logou';
    if (data['ultimo_login'] != null) {
      final ts = data['ultimo_login'] as Timestamp;
      final dt = ts.toDate();
      ultimoLogin =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.electricBlue.withOpacity(0.1),
          backgroundImage: foto != null ? NetworkImage(foto) : null,
          child: foto == null
              ? const Icon(Icons.person, color: AppColors.electricBlue)
              : null,
        ),
        title: Text(
          nome,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(email,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textGray)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 12, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  'Último login: $ultimoLogin',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipStatus extends StatelessWidget {
  final String status;
  const _ChipStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    Color cor;
    String label;
    switch (status) {
      case 'aprovado':
        cor = AppColors.success;
        label = 'Aprovado';
        break;
      case 'recusado':
        cor = AppColors.error;
        label = 'Recusado';
        break;
      default:
        cor = AppColors.warning;
        label = 'Em análise';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cor,
        ),
      ),
    );
  }
}

class _BotaoStatus extends StatelessWidget {
  final String label;
  final Color cor;
  final bool ativo;
  final VoidCallback onTap;

  const _BotaoStatus({
    required this.label,
    required this.cor,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ativo ? cor : cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: ativo ? Colors.white : cor,
          ),
        ),
      ),
    );
  }
}
