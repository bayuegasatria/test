import 'package:flutter/material.dart';
import 'package:newapp/api/laporan_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class LaporanPeminjamanForm extends StatefulWidget {
  final String userRole;
  final String userDivisi;

  const LaporanPeminjamanForm({
    super.key,
    required this.userRole,
    required this.userDivisi,
  });

  @override
  State<LaporanPeminjamanForm> createState() => _LaporanPeminjamanFormState();
}

class _LaporanPeminjamanFormState extends State<LaporanPeminjamanForm> {
  String? selectedBidang;
  List<String> bidangList = ["Semua Bidang"];
  bool isLoadingDivisi = true;

  String? durasi;
  String? bulan;
  String? triwulan;
  String? tahun;

  final List<String> bulanList = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  final List<String> triwulanList = [
    "Jan - Mar",
    "Apr - Jun",
    "Jul - Sep",
    "Okt - Des",
  ];

  final int currentYear = DateTime.now().year;
  late final List<String> tahunList = List.generate(
    5,
    (i) => (currentYear - 4 + i).toString(),
  );
  @override
  void initState() {
    super.initState();
    _loadDivisi();
  }

  Future<void> _loadDivisi() async {
    final isAdmin = widget.userRole.toLowerCase() == "admin";
    final isTU = widget.userDivisi.toLowerCase() == "tata usaha";

    if (!isAdmin && !isTU) {
      // user non-admin, readonly
      setState(() {
        isLoadingDivisi = false;
      });
      return;
    }

    try {
      final divisiList = await LaporanApi.getDivisiList();
      setState(() {
        selectedBidang = widget.userDivisi;
        bidangList.addAll(divisiList.map((e) => e['nama'].toString()));
        isLoadingDivisi = false;
      });
    } catch (e) {
      setState(() => isLoadingDivisi = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data divisi: $e")));
    }
  }

  // 🔹 Popup Reusable
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

  // 🔹 Cetak laporan
  void _cetakLaporan() async {
    if (durasi == null || tahun == null) {
      await showPopup(context, "Lengkapi pilihan periode dan tahun");
      return;
    }
    try {
      final res = await LaporanApi.getLaporanPeminjaman(
        bidang: selectedBidang ?? widget.userDivisi,
        durasi: durasi!,
        bulan: bulan,
        triwulan: triwulan,
        tahun: tahun!,
      );

      if (res == null || res.isEmpty) {
        await showPopup(context, "Data laporan kosong");
        return;
      }

      final pdf = pw.Document();

      final Uint8List imageBytes = (await rootBundle.load(
        'assets/images/header.png',
      )).buffer.asUint8List();
      final pw.ImageProvider kopSurat = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.portrait,
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 24),

          build: (context) => [
            pw.Center(
              child: pw.Image(
                kopSurat,
                width: PdfPageFormat.a4.availableWidth,
                alignment: pw.Alignment.center,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),

            // ===== Judul Dokumen =====
            pw.Center(
              child: pw.Text(
                "LAPORAN PEMINJAMAN KENDARAAN DINAS",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.times(),
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // ===== Info Bidang dan Periode =====
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Bidang   : ${selectedBidang ?? widget.userDivisi}",
                    style: pw.TextStyle(fontSize: 11, font: pw.Font.times()),
                  ),
                  pw.Text(
                    "Periode  : ${bulan ?? triwulan ?? ''} ${tahun!}",
                    style: pw.TextStyle(fontSize: 11, font: pw.Font.times()),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            // ===== Tabel Data =====
            pw.Table.fromTextArray(
              headers: [
                "No",
                "Nama Peminjam",
                "Kendaraan Dinas",
                "Waktu Pinjam",
                "Waktu Kembali",
                "Tujuan",
              ],
              data: [
                for (int i = 0; i < res.length; i++)
                  [
                    "${i + 1}",
                    res[i]['nama_pengaju'] ?? "-",
                    res[i]['nama_kendaraan'] ?? "-",
                    res[i]['tanggal_mulai'] ?? "-",
                    res[i]['tanggal_kembali'] ?? "-",
                    res[i]['tujuan'] ?? "-",
                  ],
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                font: pw.Font.times(),
              ),
              cellStyle: pw.TextStyle(fontSize: 10, font: pw.Font.times()),
              cellAlignment: pw.Alignment.centerLeft,
              border: pw.TableBorder.all(width: 0.5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
          ],

          // ✅ TANDA TANGAN — TIDAK AKAN PERNAH TERPOTONG HALAMAN
          footer: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Mengetahui,", style: pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Kepala Tata Usaha",
                    style: pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 60),
                  pw.Text(
                    "( ________________________ )",
                    style: pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      await showPopup(context, "Gagal mencetak laporan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole.toLowerCase() == "admin";
    final isTU = widget.userDivisi.toLowerCase() == "tata usaha";
    final isReadonly = !isAdmin && !isTU;

    return isLoadingDivisi
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
                    "Pilih Bidang",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedBidang ?? widget.userDivisi,
                    items: bidangList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: isReadonly
                        ? null
                        : (v) => setState(() => selectedBidang = v),
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

                  const Text(
                    "Periode Laporan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // Checkbox durasi
                  Wrap(
                    spacing: 20,
                    children: [
                      CheckboxListTile(
                        title: const Text("Bulan"),
                        value: durasi == "bulan",
                        onChanged: (v) {
                          setState(() {
                            durasi = v == true ? "bulan" : null;
                            if (v == true) triwulan = null;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text("Triwulan"),
                        value: durasi == "triwulan",
                        onChanged: (v) {
                          setState(() {
                            durasi = v == true ? "triwulan" : null;
                            if (v == true) bulan = null;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text("Tahun"),
                        value: durasi == "tahun",
                        onChanged: (v) =>
                            setState(() => durasi = v == true ? "tahun" : null),
                      ),
                    ],
                  ),

                  if (durasi == "bulan")
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Pilih Bulan",
                      ),
                      value: bulan,
                      items: bulanList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => bulan = v),
                    ),

                  if (durasi == "triwulan")
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Pilih Triwulan",
                      ),
                      value: triwulan,
                      items: triwulanList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => triwulan = v),
                    ),

                  if (durasi != null)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Pilih Tahun",
                      ),
                      value: tahun,
                      items: tahunList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => tahun = v),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: _cetakLaporan,
                      icon: const Icon(Icons.print, color: Colors.white),
                      label: const Text(
                        "Cetak Laporan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
