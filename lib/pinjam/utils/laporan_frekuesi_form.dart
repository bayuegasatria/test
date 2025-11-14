import 'package:flutter/material.dart';
import 'package:newapp/api/laporan_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanFrekuensiForm extends StatefulWidget {
  final String userRole;
  final String userDivisi;

  const LaporanFrekuensiForm({
    super.key,
    required this.userRole,
    required this.userDivisi,
  });

  @override
  State<LaporanFrekuensiForm> createState() => _LaporanFrekuensiFormState();
}

class _LaporanFrekuensiFormState extends State<LaporanFrekuensiForm> {
  String? kelompok;
  String? selectedDivisi;
  String? durasi;
  String? bulan;
  String? tahun;

  List<Map<String, dynamic>> divisiList = [];
  bool _isLoadingDivisi = false;

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

  // 🔹 Ambil list divisi dari API
  Future<void> _loadDivisiList() async {
    setState(() => _isLoadingDivisi = true);
    try {
      final list = await LaporanApi.getDivisiList();
      setState(() {
        divisiList = list;
      });
    } catch (e) {
      await showPopup(context, "Gagal mengambil data divisi: $e");
    } finally {
      setState(() => _isLoadingDivisi = false);
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

  // 🔹 Cetak laporan
  void _cetakLaporan() async {
    if (kelompok == null) {
      await showPopup(context, "Pilih kelompok laporan terlebih dahulu");
      return;
    }

    if (durasi == null || tahun == null) {
      await showPopup(context, "Lengkapi pilihan periode laporan");
      return;
    }

    try {
      // 🔹 Ambil data laporan
      final res = await LaporanApi.getLaporanFrekuensi(
        kelompok: kelompok!,
        divisi: selectedDivisi,
        durasi: durasi!,
        bulan: bulan,
        tahun: tahun!,
      );

      if (res == null || res.isEmpty) {
        await showPopup(context, "Data laporan kosong");
        return;
      }

      // 🔹 Siapkan dokumen PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          build: (context) {
            final isKelompokDivisi = kelompok == "bidang";

            // 🔹 Judul utama dokumen
            final title = "LAPORAN JUMLAH PEMINJAMAN KENDARAAN";

            // 🔹 Header gambar
            final headerSection = pw.Center(
              child: pw.Text(
                "BALAI BESAR POM  DI BANJARBARU",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.times(),
                ),
              ),
            );

            // 🔹 Info laporan
            final infoSection = [
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: pw.Font.times(),
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Kelompok : ${kelompok?.toUpperCase() ?? '-'}",
                      style: pw.TextStyle(fontSize: 11, font: pw.Font.times()),
                    ),
                    if (isKelompokDivisi && selectedDivisi != null)
                      pw.Text(
                        "Bidang   : $selectedDivisi",
                        style: pw.TextStyle(
                          fontSize: 11,
                          font: pw.Font.times(),
                        ),
                      ),
                    pw.Text(
                      "Periode  : ${(bulan ?? '').toString()} ${(tahun ?? '').toString()}",
                      style: pw.TextStyle(fontSize: 11, font: pw.Font.times()),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
            ];

            // 🔹 Jika data kosong
            if (res == null ||
                (res is List && res.isEmpty) ||
                (res is Map && (res['data']?.isEmpty ?? true))) {
              return [
                headerSection,
                ...infoSection,
                pw.Center(
                  child: pw.Text(
                    "Tidak ada data untuk periode ini.",
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ),
              ];
            }

            // 🔹 Tabel laporan (menyesuaikan jenis kelompok)
            late pw.Widget tableSection;

            if (isKelompokDivisi) {
              // ✅ Mode "Divisi"
              final dataList = (res is List) ? res : [];
              final headers = ["No", "Nama", "Jumlah Pemakaian"];

              final dataRows = [
                for (int i = 0; i < dataList.length; i++)
                  [
                    "${i + 1}",
                    dataList[i]['nama_pengaju'] ?? "-",
                    (dataList[i]['frekuensi_pemakaian'] ?? "0").toString(),
                  ],
              ];

              // Tambahkan total jika ada
              String? totalDivisi;
              if (dataList.isNotEmpty &&
                  dataList[0]['total_per_divisi'] != null) {
                totalDivisi = dataList[0]['total_per_divisi'].toString();
              }

              if (totalDivisi != null) {
                dataRows.add(["", "Total", totalDivisi]);
              }

              tableSection = pw.TableHelper.fromTextArray(
                headers: headers,
                data: dataRows,
                border: pw.TableBorder.all(
                  width: 0.5,
                  color: PdfColors.grey600,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                  font: pw.Font.times(),
                ),
                cellStyle: pw.TextStyle(fontSize: 10, font: pw.Font.times()),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellHeight: 22,
              );
            } else {
              // ✅ Mode "Kendaraan"
              final divisiHeaders =
                  (res['divisi_headers'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];
              final dataList = (res['data'] as List?) ?? [];

              final headers = ["No", "Kendaraan", ...divisiHeaders];

              final dataRows = [
                for (int i = 0; i < dataList.length; i++)
                  [
                    "${i + 1}",
                    dataList[i]['nama_kendaraan'] ?? "-",
                    ...List.generate(
                      divisiHeaders.length,
                      (j) => (dataList[i]['frekuensi_divisi']?[j] ?? "0")
                          .toString(),
                    ),
                  ],
              ];

              tableSection = pw.TableHelper.fromTextArray(
                headers: headers,
                data: dataRows,
                border: pw.TableBorder.all(
                  width: 0.5,
                  color: PdfColors.grey600,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  font: pw.Font.times(),
                ),
                cellStyle: pw.TextStyle(fontSize: 9, font: pw.Font.times()),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.center,
                cellHeight: 20,
              );
            }

            return [headerSection, ...infoSection, tableSection];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      await showPopup(context, "Gagal mencetak laporan: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    selectedDivisi = widget.userDivisi;

    // 🔹 Load data divisi dari API
    _loadDivisiList();
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
              "Pilih Kelompok Laporan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // 🔹 Dropdown kelompok laporan
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Kelompok Laporan"),
              value: kelompok,
              items: const [
                DropdownMenuItem(value: "bidang", child: Text("Bidang")),
                DropdownMenuItem(value: "kendaraan", child: Text("Kendaraan")),
              ],
              onChanged: (v) => setState(() {
                kelompok = v;
                selectedDivisi = null;
              }),
            ),

            if (kelompok == "bidang") ...[
              const SizedBox(height: 10),
              _isLoadingDivisi
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Pilih Bidang",
                      ),
                      value: selectedDivisi,
                      items: divisiList
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e['nama'] ?? '',
                              child: Text(e['nama'] ?? '-'),
                            ),
                          )
                          .toList(),
                      onChanged:
                          (widget.userRole == "Admin" ||
                              widget.userDivisi == "Tata Usaha")
                          ? (v) => setState(() => selectedDivisi = v)
                          : null,
                    ),
            ],

            const SizedBox(height: 10),
            const Text(
              "Periode",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Wrap(
              spacing: 20,
              children: [
                CheckboxListTile(
                  title: const Text("Bulan"),
                  value: durasi == "bulan",
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        durasi = "bulan";
                        tahun = null;
                      } else {
                        durasi = null;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text("Tahun"),
                  value: durasi == "tahun",
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        durasi = "tahun";
                        bulan = null;
                      } else {
                        durasi = null;
                      }
                    });
                  },
                ),
              ],
            ),

            if (durasi == "bulan") ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Pilih Bulan"),
                value: bulan,
                items: bulanList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => bulan = v),
              ),
            ],

            if (durasi != null) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Pilih Tahun"),
                value: tahun,
                items: tahunList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => tahun = v),
              ),
            ],

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
