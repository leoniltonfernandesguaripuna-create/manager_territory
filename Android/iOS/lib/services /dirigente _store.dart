class DirigentesStore {
  static List<List<String>> nomes = [
    ['Irmão João Silva', 'Irmão Pedro Santos', 'Irmão Carlos Souza'],
    ['Irmão Marcos Lima', 'Irmão André Costa', 'Irmão Rafael Alves'],
    ['Irmão Lucas Pereira', 'Irmão Mateus Rocha', 'Irmão Tiago Ribeiro'],
  ];

  static List<String> validos(int coluna) {
    return nomes[coluna]
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  static void setAt(int coluna, int index, String valor) {
    while (nomes[coluna].length <= index) {
      nomes[coluna].add('');
    }
    nomes[coluna][index] = valor;
  }
}
