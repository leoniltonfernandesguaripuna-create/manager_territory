import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// =============================================================================
// CONSTANTES DE COR
// =============================================================================
const _azulPDF = PdfColor.fromInt(0xFF1F3A5F);
const _laranjaPDF = PdfColor.fromInt(0xFFED7D31);
const _begePDF = PdfColor.fromInt(0xFFEDE2C6);
const _verdePDF = PdfColor.fromInt(0xFF2F855A);
const _vinhoPDF = PdfColor.fromInt(0xFF7B1F2E);

// =============================================================================
// IMPRESSÃO — SERVIÇO DE CAMPO
// =============================================================================
Future<void> imprimirServicoCampo({
  required String titulo,
  required List<List<String>> linhas,
  String obs = '',
}) async {
  final doc = pw.Document();
  final linhasOk =
      linhas.where((l) => l.isNotEmpty && l[0].isNotEmpty).toList();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(15),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // === TÍTULO (fundo azul) ===
          pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            decoration: const pw.BoxDecoration(color: _azulPDF),
            child: pw.Text(
              titulo.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          // === TABELA ===
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey800, width: 0.6),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1.3),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FlexColumnWidth(1.1),
              4: const pw.FlexColumnWidth(3),
            },
            children: [
              // Cabeçalho laranja
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: _laranjaPDF),
                children: ['MÊS', 'SEMANA', 'LOCAL', 'HORÁRIO', 'DIRIGENTE']
                    .map((h) => pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              // Linhas de dados
              ...linhasOk.map((linha) {
                final semana = linha[1].toUpperCase();
                final isDom = semana == 'DOM';
                final isSab = semana == 'SÁB' || semana == 'SAB';
                final corFundo = isDom
                    ? _vinhoPDF
                    : isSab
                        ? const PdfColor.fromInt(0xFFE0E0E0)
                        : PdfColors.white;
                final corTexto = isDom ? PdfColors.white : PdfColors.black;
                final bold = isDom;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: corFundo),
                  children: List.generate(linha.length, (i) {
                    final texto = linha[i].toUpperCase();
                    return pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 3.2),
                      child: pw.Text(
                        texto,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          color: corTexto,
                          fontWeight: bold
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
          pw.SizedBox(height: 10),
          // === OBSERVAÇÕES ===
          pw.Text(
            'OBSERVAÇÕES (SSC / TRABALHO RURAL)',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _azulPDF,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Container(
            height: 50,
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey700, width: 0.6),
            ),
            child: pw.Text(
              obs.isEmpty
                  ? 'Anotações para trabalho rural, saídas especiais, etc...'
                  : obs,
              style: pw.TextStyle(
                fontSize: 8.5,
                color: obs.isEmpty ? PdfColors.grey600 : PdfColors.black,
                fontStyle:
                    obs.isEmpty ? pw.FontStyle.italic : pw.FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}

// =============================================================================
// IMPRESSÃO — EVENTOS
// =============================================================================
Future<void> imprimirEventos({
  required int passagensMarcadas,
  required double valorPassagem,
  required double estipulado,
  required double recebido,
  required int pessoasPagas,
  required int passagensPagas,
  required double restante,
  required List<List<List<String>>> grupos,
}) async {
  String fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => [
        pw.Center(
          child: pw.Text(
            'EVENTOS',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: _azulPDF,
            ),
          ),
        ),
        pw.SizedBox(height: 14),

        // ==== 4 caixas ====
        pw.Row(children: [
          pw.Expanded(
            child: _caixaPDF('PASSAGENS MARCADAS', '$passagensMarcadas'),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _caixaPDF('VALOR POR PASSAGEM', fmt(valorPassagem)),
          ),
        ]),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          pw.Expanded(
            child: _caixaPDF('VALOR ESTIPULADO (A receber)', fmt(estipulado)),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _caixaPDF('TOTAL RECEBIDO', fmt(recebido)),
          ),
        ]),
        pw.SizedBox(height: 14),

        // ==== 3 linhas ====
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: _begePDF,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _linhaPDF('Pessoas pagas', '$pessoasPagas'),
              pw.SizedBox(height: 4),
              _linhaPDF('Passagens pagas', '$passagensPagas'),
              pw.Divider(height: 12),
              _linhaPDF('Restante', fmt(restante), negrito: true),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // ==== 4 grupos ====
        for (int g = 0; g < grupos.length; g++) ...[
          pw.Text(
            'GRUPO ${g + 1}',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _azulPDF,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: const ['Nº', 'NOME', 'DIAS', 'PG'],
            data: grupos[g],
            headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: _azulPDF),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.center,
            headerAlignment: pw.Alignment.center,
            border:
                pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 4, vertical: 3),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
            },
          ),
          pw.SizedBox(height: 16),
        ],
      ],
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}

// =============================================================================
// IMPRESSÃO — S.13
// =============================================================================

Future<void> imprimirS13({
  required String anoServico,
  required List<List<String>> linhas,
}) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(
            child: pw.Text(
              'REGISTRO DE DESIGNAÇÃO DE TERRITÓRIO',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Ano de Serviço: ${anoServico.isEmpty ? "____" : anoServico}',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Expanded(
            child: pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
              columnWidths: {
                0: const pw.FixedColumnWidth(38),
                1: const pw.FixedColumnWidth(75),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1),
              },
              children: [
                // === Cabeçalho ===
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _azulPDF),
                  children: [
                    _cellCabecalhoPDF('Terr.\nn.º'),
                    _cellCabecalhoPDF('Última data\nconcluída'),
                    _cellCabecalhoPDF('Designação 1'),
                    _cellCabecalhoPDF('Designação 2'),
                    _cellCabecalhoPDF('Designação 3'),
                    _cellCabecalhoPDF('Designação 4'),
                  ],
                ),
                // === Linhas de dados ===
                ...linhas.map((linha) {
                  return pw.TableRow(
                    children: List.generate(linha.length, (i) {
                      final texto = linha[i].replaceAll('—', '-');
                      final vazio = texto.trim().isEmpty || texto.trim() == '-';
                      return pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 3, vertical: 4),
                        child: pw.Text(
                          vazio ? '-' : texto,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: vazio ? PdfColors.grey600 : PdfColors.black,
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('S-13-T 01/22',
              style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}

pw.Widget _cellCabecalhoPDF(String texto) {
  return pw.Container(
    alignment: pw.Alignment.center,
    padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 3),
    child: pw.Text(
      texto,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 9.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
    ),
  );
}

// =============================================================================
// HELPERS
// =============================================================================
pw.Widget _caixaPDF(String titulo, String valor) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: _begePDF,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: _azulPDF, width: 0.5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(titulo,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: _azulPDF)),
        pw.SizedBox(height: 4),
        pw.Text(valor,
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: _verdePDF)),
      ],
    ),
  );
}

pw.Widget _linhaPDF(String label, String valor, {bool negrito = false}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label,
          style: pw.TextStyle(
              fontSize: 11,
              fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: _azulPDF)),
      pw.Text(valor,
          style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: negrito ? _verdePDF : _azulPDF)),
    ],
  );
}
