import 'package:flutter/material.dart';
import 'package:newapp/api/driver_api.dart';
import 'package:newapp/api/kinerja_supir_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class LaporanKinerjaSupirForm extends StatefulWidget {
  const LaporanKinerjaSupirForm({super.key});

  @override
  State<LaporanKinerjaSupirForm> createState() =>
      _LaporanKinerjaSupirFormState();
}

class _LaporanKinerjaSupirFormState extends State<LaporanKinerjaSupirForm> {
  bool _isLoading = false;
  bool _isLoadingSupir = true;

  List<Map<String, dynamic>> supirList = [];
  Map<String, dynamic>? selectedSupir;

  @override
  void initState() {
    super.initState();
    _loadSupir();
  }

  Future<void> _loadSupir() async {
    try {
      final res = await DriverApi.getDriver();
      setState(() {
        supirList = res;
        _isLoadingSupir = false;
      });
    } catch (e) {
      _isLoadingSupir = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data supir: $e")));
    }
  }

  // 🔹 Popup reusable
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

  // 🔹 CETAK LAPORAN
  void _cetakLaporan() async {
    if (selectedSupir == null) {
      await showPopup(context, "Pilih supir terlebih dahulu");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supirId = int.parse(selectedSupir!['id'].toString());
      final supirNama = selectedSupir!['name'].toString();

      final res = await KinerjaSupirApi.getKinerjaSupir(supirId);

      if (res.isEmpty) {
        await showPopup(context, "Data kinerja supir kosong");
        return;
      }

      final pdf = pw.Document();

      // 🔹 Kop surat
      final Uint8List imageBytes = (await rootBundle.load(
        'assets/images/header.jpg',
      )).buffer.asUint8List();
      final pw.ImageProvider kopSurat = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(32, 24, 32, 24),
          build: (context) => [
            // ===== KOP =====
            pw.Center(
              child: pw.Image(kopSurat, width: PdfPageFormat.a4.availableWidth),
            ),
            pw.SizedBox(height: 10),

            // ===== JUDUL =====
            pw.Center(
              child: pw.Text(
                "LAPORAN KINERJA SUPIR",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.times(),
                ),
              ),
            ),
            pw.SizedBox(height: 15),

            // ===== INFO =====
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Nama Supir : $supirNama",
                  style: pw.TextStyle(fontSize: 11),
                ),
                pw.Text(
                  "Tanggal    : ${DateTime.now().toLocal().toString().split(' ')[0]}",
                  style: pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            _buildTabel(res),
          ],

          // ✅ FOOTER TANDA TANGAN — AMAN TIDAK TERPOTONG
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text("Mengetahui,", style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 4),
                pw.Text("Kepala Tata Usaha", style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 60),
                pw.Text("Muhammad Fikry Ramadhan,S.E."),
                pw.Text(
                  "________________________",
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
    return _isLoadingSupir
        ? const Center(child: CircularProgressIndicator())
        : Card(
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
                    "Laporan Kinerja Supir",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedSupir,
                    hint: const Text("Pilih Supir"),
                    items: supirList
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e['name'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedSupir = v),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
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
                        "Cetak Laporan",
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

  // ===== TABEL =====
  pw.Widget _buildTabel(List<Map<String, dynamic>> dataList) {
    final rows = [
      for (int i = 0; i < dataList.length; i++)
        [
          "${i + 1}",
          dataList[i]['nama_supir'] ?? "-",
          dataList[i]['nama_kendaraan'] ?? "-",
          dataList[i]['tanggal_berangkat'] ?? "-",
          dataList[i]['tanggal_kembali'] ?? "-",
          dataList[i]['tujuan'] ?? "-",
        ],
    ];

    return pw.Table.fromTextArray(
      headers: const [
        "No",
        "Nama Supir",
        "Kendaraan",
        "Berangkat",
        "Kembali",
        "Tujuan",
      ],
      data: rows,
      border: pw.TableBorder.all(width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }
}
