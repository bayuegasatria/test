import 'package:flutter/material.dart';
import 'package:newapp/api/history_laporan_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class LaporanHistoryPinjamForm extends StatefulWidget {
  final int userId;
  final String userNama;
  final String userRole;

  const LaporanHistoryPinjamForm({
    super.key,
    required this.userId,
    required this.userNama,
    required this.userRole,
  });

  @override
  State<LaporanHistoryPinjamForm> createState() =>
      _LaporanHistoryPinjamFormState();
}

class _LaporanHistoryPinjamFormState extends State<LaporanHistoryPinjamForm> {
  bool _isLoading = false;

  Future<void> showPopup(
    BuildContext context,
    String message, {
    String title = "Peringatan",
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueAccent,
          ),
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // 🔹 CETAK LAPORAN HISTORY
  void _cetakLaporan() async {
    setState(() => _isLoading = true);
    try {
      final res = await HistoryLaporanApi.getHistoryPinjam(widget.userId);

      if (res.isEmpty) {
        await showPopup(context, "Data riwayat peminjaman kosong");
        return;
      }

      final pdf = pw.Document();

      // 🔹 Load kop surat
      final Uint8List imageBytes = (await rootBundle.load(
        'assets/images/header.jpg',
      )).buffer.asUint8List();
      final pw.ImageProvider kopSurat = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(32, 24, 32, 24),
          build: (context) => [
            // ===== KOP SURAT =====
            pw.Center(
              child: pw.Image(kopSurat, width: PdfPageFormat.a4.availableWidth),
            ),

            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                "LAPORAN RIWAYAT PERJALANAN",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.times(),
                ),
              ),
            ),

            pw.SizedBox(height: 15),

            // ===== INFO USER =====
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Nama User : ${widget.userNama}",
                  style: pw.TextStyle(fontSize: 11),
                ),
                pw.Text(
                  "Tanggal   : ${DateTime.now().toLocal().toString().split(' ')[0]}",
                  style: pw.TextStyle(fontSize: 11),
                ),
              ],
            ),

            pw.SizedBox(height: 15),

            _buildTabelHistory(res),
          ],

          // ✅ TANDA TANGAN AMAN 100%
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text("Mengetahui,", style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 4),
                pw.Text("Kepala Tata Usaha", style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 45),
                pw.Text("Muhammad Fikry Ramadhan,S.E."),
                pw.Text(
                  "________________________ ",

                  style: pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      await showPopup(context, "Gagal mencetak laporan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blueGrey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Laporan Riwayat Peminjaman",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: _isLoading ? null : _cetakLaporan,
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text(
                  "Cetak Laporan History",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 15),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  // ===== TABEL HISTORY =====
  pw.Widget _buildTabelHistory(List<Map<String, dynamic>> dataList) {
    final rows = [
      for (int i = 0; i < dataList.length; i++)
        [
          "${i + 1}",
          dataList[i]['no_pengajuan'] ?? "-",
          dataList[i]['nama_kendaraan'] ?? "-",
          dataList[i]['tanggal_berangkat'] ?? "-",
          dataList[i]['tanggal_kembali'] ?? "-",
          dataList[i]['tanggal_pengembalian'] ?? "-",
          dataList[i]['tujuan'] ?? "-",
          (dataList[i]['status'] ?? "-").toString().toUpperCase(),
        ],
    ];

    return pw.Table.fromTextArray(
      headers: [
        "No",
        "No Pengajuan",
        "Kendaraan",
        "Berangkat",
        "Kembali",
        "Pengembalian",
        "Tujuan",
        "Status",
      ],
      data: rows,
      border: pw.TableBorder.all(width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        font: pw.Font.times(),
      ),
      cellStyle: pw.TextStyle(fontSize: 9, font: pw.Font.times()),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }
}
