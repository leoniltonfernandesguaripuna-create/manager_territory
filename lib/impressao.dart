import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const _azulPDF = PdfColor.fromInt(0xFF1F3A5F);
const _begePDF = PdfColor.fromInt(0xFFEDE2C6);
const _verdePDF = PdfColor.fromInt(0xFF2F855A);

// =============================================================================
// IMPRESSÃO — SERVIÇO DE CAMPO
// =============================================================================
Future<void> imprimirServicoCampo({
  required String titulo,
  required List<List<String>> linhas,
}) async {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => [
        pw.Center(
          child: pw.Text(
            'SERVIÇO DE CAMPO — $titulo',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _azulPDF,
            ),
          ),
        ),
        pw.SizedBox(height: 14),
        pw.TableHelper.fromTextArray(
          headers: ['MÊS', 'SEMANA', 'LOCAL', 'HORÁRIO', 'DIRIGENTE'],
          data: linhas,
          headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: _azulPDF),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.center,
          headerAlignment: pw.Alignment.center,
          border:
              pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 4, vertical: 4),
        ),
      ],
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
  required List<List<List<String>>> grupos, // 4 grupos, cada um com linhas [nº, nome, dias, pg]
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
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) => [
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
            pw.Text('Ano de Serviço: $anoServico',
                style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: const [
            'Terr.\nn.º',
            'Última data\nconcluída',
            'Designação 1',
            'Designação 2',
            'Designação 3',
            'Designação 4',
          ],
          data: linhas,
          headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: _azulPDF),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.center,
          headerAlignment: pw.Alignment.center,
          border:
              pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 3, vertical: 4),
          columnWidths: {
            0: const pw.FixedColumnWidth(35),
            1: const pw.FixedColumnWidth(60),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1),
          },
        ),
        pw.SizedBox(height: 8),
        pw.Text('S-13-T 01/22',
            style: const pw.TextStyle(fontSize: 8)),
      ],
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => doc.save());
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
