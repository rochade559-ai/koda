import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio {
  final String id;
  final String uid;
  final String titulo;
  final String categoria;
  final String descricao;
  final double? preco;
  final List<String> fotos;
  final String emailContato;
  final String whatsappContato;
  final String status; // pendente | ativo | expirado | pausado | reprovado
  final DateTime? criadoEm;
  final DateTime? expiraEm;
  final int visualizacoes;

  Anuncio({
    required this.id,
    required this.uid,
    required this.titulo,
    required this.categoria,
    required this.descricao,
    this.preco,
    required this.fotos,
    required this.emailContato,
    required this.whatsappContato,
    required this.status,
    this.criadoEm,
    this.expiraEm,
    this.visualizacoes = 0,
  });

  factory Anuncio.fromMap(Map<String, dynamic> map, String id) {
    return Anuncio(
      id: id,
      uid: map['uid'] ?? '',
      titulo: map['titulo'] ?? '',
      categoria: map['categoria'] ?? 'outros',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] as num?)?.toDouble(),
      fotos: List<String>.from(map['fotos'] ?? []),
      emailContato: map['email_contato'] ?? '',
      whatsappContato: map['whatsapp_contato'] ?? '',
      status: map['status'] ?? 'pendente',
      criadoEm: (map['criado_em'] as Timestamp?)?.toDate(),
      expiraEm: (map['expira_em'] as Timestamp?)?.toDate(),
      visualizacoes: map['visualizacoes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'titulo': titulo,
      'categoria': categoria,
      'descricao': descricao,
      'preco': preco,
      'fotos': fotos,
      'email_contato': emailContato,
      'whatsapp_contato': whatsappContato,
      'status': status,
      'criado_em': criadoEm != null
          ? Timestamp.fromDate(criadoEm!)
          : FieldValue.serverTimestamp(),
      'expira_em': expiraEm != null ? Timestamp.fromDate(expiraEm!) : null,
      'visualizacoes': visualizacoes,
    };
  }
}
