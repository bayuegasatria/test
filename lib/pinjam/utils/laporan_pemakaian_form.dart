import 'package:flutter/material.dart';
import 'package:newapp/api/laporan_api.dart';
import 'package:newapp/api/mobil_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanPemakaianForm extends StatefulWidget {
  final String userRole;
  final String userDivisi;

  const LaporanPemakaianForm({
    super.key,
    required this.userRole,
    required this.userDivisi,
  });

  @override
  State<LaporanPemakaianForm> createState() => _LaporanPemakaianFormState();
}

class _LaporanPemakaianFormState extends State<LaporanPemakaianForm> {
  List<Map<String, dynamic>> mobilList = [];
  Map<String, dynamic>? selectedMobil;
  bool isLoading = true;

  String? bulan;
  String? tahun;
  String periodeMode = "bulan"; // 🔹 default: per bulan

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

  @override
  void initState() {
    super.initState();
    _loadMobil();
  }

  Future<void> _loadMobil() async {
    try {
      final res = await MobilApi.getMobil();
      setState(() {
        mobilList = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat kendaraan: $e")));
    }
  }

  Future<void> showPopup(String message, {String title = "Peringatan"}) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Future<void> _cetakLaporan() async {
    if (selectedMobil == null || tahun == null) {
      await showPopup("Pilih kendaraan dan periode terlebih dahulu");
      return;
    }

    try {
      final bulanIndex = (periodeMode == "bulan" && bulan != null)
          ? bulanList.indexOf(bulan!) + 1
          : null;

      final res = await LaporanApi.getPemakaianKendaraan(
        carId: int.parse(selectedMobil!['id'].toString()),
        bulan: bulanIndex != null ? bulanIndex.toString() : null,
        tahun: tahun,
      );

      if (res.isEmpty) {
        await showPopup("Tidak ada data untuk periode tersebut");
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          build: (context) => [
            pw.Center(
              child: pw.Text(
                "BALAI BESAR POM DI BANJARBARU",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.times(),
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                "LAPORAN PEMAKAIAN KENDARAAN DINAS",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.times(),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Kendaraan : ${selectedMobil!['merk']} (${selectedMobil!['police_number']})",
                    style: pw.TextStyle(fontSize: 11, font: pw.Font.times()),
                  ),
                  pw.Text(
                    "Periode    : ${periodeMode == "bulan" ? bulan! + " " : ""}${tahun!}",
                    style: pw.TextStyle(fontSize: 11, font: pw.Font.times()),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Table.fromTextArray(
              headers: [
                "No",
                "Nomor Peminjaman",
                "Nama Peminjam",
                "Tujuan",
                "Tanggal Pinjam",
                "Tanggal Kembali",
                "KM Awal",
                "KM Akhir",
              ],
              data: [
                for (int i = 0; i < res.length; i++)
                  [
                    "${i + 1}",
                    res[i]['no_pengajuan'] ?? "-",
                    res[i]['nama_user'] ?? "-",
                    res[i]['tujuan'] ?? "-",
                    res[i]['tanggal_berangkat'] ?? "-",
                    res[i]['tanggal_pengembalian'] ?? "-",
                    res[i]['km_awal'] ?? "-",
                    res[i]['km_akhir'] ?? "-",
                  ],
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                font: pw.Font.times(),
              ),
              cellStyle: pw.TextStyle(fontSize: 10, font: pw.Font.times()),
              border: pw.TableBorder.all(width: 0.5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      await showPopup("Gagal mencetak laporan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Card(
            color: Colors.white,
            margin: const EdgeInsets.only(top: 20),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.blueGrey),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Kendaraan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    isExpanded: true,
                    value: selectedMobil,
                    items: mobilList.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${e['merk']} (${e['police_number']})",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => selectedMobil = v),
                    decoration: InputDecoration(
                      labelText: "Pilih Mobil",
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

                  // 🔹 Radio Button: Per Bulan / Per Tahun
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Bulan"),
                          value: "bulan",
                          groupValue: periodeMode,
                          onChanged: (v) =>
                              setState(() => periodeMode = v ?? "bulan"),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Tahun"),
                          value: "tahun",
                          groupValue: periodeMode,
                          onChanged: (v) =>
                              setState(() => periodeMode = v ?? "tahun"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (periodeMode == "bulan") ...[
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
                    const SizedBox(height: 10),
                  ],

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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
