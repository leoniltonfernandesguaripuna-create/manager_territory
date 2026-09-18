class Designacao {
  String nome;
  String dataDesignacao;
  String dataConclusao;
  Designacao({this.nome = '', this.dataDesignacao = '', this.dataConclusao = ''});
}

class LinhaServico {
  final String mes;
  final String semana;
  final String horario;
  String local;
  String dirigente;
  LinhaServico({
    required this.mes,
    required this.semana,
    required this.horario,
    this.local = '',
    this.dirigente = '',
  });
}
