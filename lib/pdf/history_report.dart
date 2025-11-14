import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HistoryReportGenerator {
  static Future<pw.Document> generateReport(
    List<Map<String, dynamic>> data,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    final baseTextStyle = pw.TextStyle(fontSize: 11);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // === HEADER ===
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN PEMAKAIAN KENDARAAN DINAS',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Nomor Surat: 090/1234/DIS/2025',
                    style: baseTextStyle,
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
            ),

            pw.Table.fromTextArray(
              headers: [
                'No',
                'No Pengajuan',
                'Nama Peminjam',
                'Kendaraan',
                'Tujuan',
                'Tgl Berangkat',
                'Tgl Kembali',
                'Tgl Pengembalian',
              ],
              data: List.generate(data.length, (index) {
                final item = data[index];
                return [
                  (index + 1).toString(),
                  item["no_pengajuan"] ?? "-",
                  item["nama_user"] ?? "-",
                  item["nama_kendaraan"] ?? "-",
                  item["tujuan"] ?? "-",
                  item["tanggal_berangkat"] != null
                      ? dateFormat.format(
                          DateTime.parse(item["tanggal_berangkat"]),
                        )
                      : "-",
                  item["tanggal_kembali"] != null
                      ? dateFormat.format(
                          DateTime.parse(item["tanggal_kembali"]),
                        )
                      : "-",
                  item["tanggal_pengembalian"] != null
                      ? dateFormat.format(
                          DateTime.parse(item["tanggal_pengembalian"]),
                        )
                      : "-",
                ];
              }),
              border: pw.TableBorder.all(width: 0.7, color: PdfColors.grey700),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 11.5,
              ),
              cellStyle: baseTextStyle,
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
            ),

            pw.SizedBox(height: 30),
          ];
        },
      ),
    );

    return pdf;
  }
}
