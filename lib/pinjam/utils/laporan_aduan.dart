import 'package:flutter/material.dart';
import 'package:newapp/api/aduan_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanAduanNonTikForm extends StatefulWidget {
  final String userRole;
  final String userDivisi;

  const LaporanAduanNonTikForm({
    super.key,
    required this.userRole,
    required this.userDivisi,
  });

  @override
  State<LaporanAduanNonTikForm> createState() => _LaporanAduanNonTikFormState();
}

class _LaporanAduanNonTikFormState extends State<LaporanAduanNonTikForm> {
  String? durasi;
  String? bulan;
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

  final int currentYear = DateTime.now().year;
  late final List<String> tahunList = List.generate(
    5,
    (i) => (currentYear - 4 + i).toString(),
  );

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

    if (durasi == "bulan" && bulan == null) {
      await showPopup(context, "Pilih bulan terlebih dahulu");
      return;
    }

    try {
      final res = await AduanApi.getAduanData(
        role: widget.userRole,
        userId: 0, // tidak dibatasi user
        divisi: 0, // semua divisi
      );

      if (res.isEmpty) {
        await showPopup(context, "Data laporan kosong");
        return;
      }

      // 🔹 Filter data berdasarkan bulan/tahun yang dipilih
      final filteredData = res.where((item) {
        final tanggalStr = item['tanggal'] ?? '';
        final tanggal = DateTime.tryParse(tanggalStr);
        if (tanggal == null) return false;

        final isSameYear = tanggal.year.toString() == tahun;

        if (durasi == "tahun") return isSameYear;

        final monthName = bulanList[tanggal.month - 1];
        final isSameMonth = monthName == bulan;

        return isSameYear && isSameMonth;
      }).toList();

      // 🔹 Jika tidak ada data sesuai periode, tampilkan popup dan hentikan
      if (filteredData.isEmpty) {
        await showPopup(context, "Tidak ada data untuk periode yang dipilih");
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          build: (context) => [
            // ===== Header Instansi =====
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    "BADAN PENGAWAS OBAT DAN MAKANAN",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      font: pw.Font.times(),
                    ),
                  ),
                  pw.Text(
                    "BALAI BESAR POM DI BANJARBARU",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      font: pw.Font.times(),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Divider(borderStyle: pw.BorderStyle.solid, thickness: 1),
                  pw.SizedBox(height: 10),
                ],
              ),
            ),

            // ===== Judul Dokumen =====
            pw.Center(
              child: pw.Text(
                "LAPORAN ADUAN NON-TIK",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.times(),
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // ===== Info Periode =====
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Bidang   : Semua Bidang",
                    style: pw.TextStyle(fontSize: 11, font: pw.Font.times()),
                  ),
                  pw.Text(
                    "Periode  : ${durasi == "bulan" ? bulan! : ""} ${tahun!}",
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
                "Nomor Aduan",
                "Tanggal Aduan",
                "Nama Pegawai",
                "Kode Barang",
                "Nama Barang",
                "Jenis Barang",
                "Aduan Kerusakan",
                "Analisa Pemeriksa",
                "Tindak Lanjut",
                "Hasil Akhir",
              ],
              data: [
                for (int i = 0; i < filteredData.length; i++)
                  [
                    "${i + 1}",
                    filteredData[i]['no_aduan'] ?? "-",
                    filteredData[i]['tanggal'] ?? "-",
                    filteredData[i]['nama_user'] ?? "-",
                    filteredData[i]['kode_barang'] ?? "-",
                    filteredData[i]['nama_barang'] ?? "-",
                    filteredData[i]['nama_kelompok'] ?? "-",
                    filteredData[i]['problem'] ?? "-", // Aduan Kerusakan
                    filteredData[i]['analisa'] ?? "-",
                    filteredData[i]['follow_up'] ?? "-",
                    filteredData[i]['result'] ?? "-",
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

            pw.SizedBox(height: 40),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      await showPopup(context, "Gagal mencetak laporan: $e");
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
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("Tahun"),
                  value: durasi == "tahun",
                  onChanged: (v) {
                    setState(() {
                      durasi = v == true ? "tahun" : null;
                    });
                  },
                ),
              ],
            ),

            if (durasi == "bulan")
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Pilih Bulan"),
                value: bulan,
                items: bulanList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => bulan = v),
              ),

            if (durasi != null)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Pilih Tahun"),
                value: tahun,
                items: tahunList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
