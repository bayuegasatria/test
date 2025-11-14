import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> cetakDBR(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  // ✅ Data dari perpindahan_dbr.dart dengan fallback ke format lain
  final kodeBarang = data["kode_barang"] ?? data["kodeBarang"] ?? "-";
  final namaBarang = data["nama_barang"] ?? data["namaBarang"] ?? "-";
  final nup = data["kode_bmn"] ?? "-";
  final merk = data["merk"] ?? data["merk_tipe"] ?? "-";
  final keterangan = data["keterangan"] ?? "-";
  final tanggal = data["tanggal"] ?? "-";
  final noAduan = data["no_aduan"] ?? data["noAduan"] ?? data["no"] ?? "-";

  // ✅ Data ruangan diambil langsung dari API perpindahan_dbr
  final kodeRuanganBaru =
      data["new_lokasi"]?.toString() ?? "-"; // ID lokasi baru
  final namaRuanganBaru = data["nama_lokasi_baru"] ?? "-";

  final namaPelapor = data["nama_pelapor"] ?? data["namaPelapor"] ?? "-";
  final nipPelapor = data["nip_pelapor"] ?? data["nipPelapor"] ?? "-";

  // ✅ Data default/statis (bisa diganti sesuai kebutuhan)
  final uapb = "BADAN PENGAWAS OBAT DAN MAKANAN";
  final uapbEl = "BADAN PENGAWAS OBAT DAN MAKANAN";
  final uapbW =
      "BALAI BESAR PENGAWAS OBAT DAN MAKANAN DI BANJARMASIN KORWIL BANJARMASIN";

  final kodeUakpb = "570123"; // Sesuaikan dengan kode UAKPB lu
  final namaUakpb = "Balai Besar POM di Banjarmasin";

  final penanggungJawabAsal = "Penanggung Jawab";
  final kepalaPOMAsal = "Kepala Balai Besar POM di Banjarmasin";
  final namaPJAsal = "Drs. Leonard Duma, Apt., MM";
  final nipPJAsal = "196510141993031001";

  final kotaTujuan = "KOTA BANJARMASIN";
  final penanggungJawabTujuan = "Penanggung Jawab Ruangan";
  final namaPJTujuan = "Ghea Chalida Andhita, S.Farm, Apt";
  final nipPJTujuan = "199110152019032005";

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // 🔹 Nomor formulir di pojok kiri atas
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.Text(
            'POM-14.01/CFM.01/SOP.01/IK.17A.01/F.04',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),

        pw.SizedBox(height: 30),
        // ======= HEADER =======
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text("UAPB: $uapb", style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                "UAPB-EL: $uapbEl",
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                "UAPB-W: $uapbW",
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 15),

        pw.Center(
          child: pw.Text(
            "DAFTAR BARANG RUANGAN",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),

        pw.SizedBox(height: 15),

        // ======= INFO KODE DAN NAMA =======
        _infoRow("Kode UAKPB", kodeUakpb),
        _infoRow("Nama UAKPB", namaUakpb),
        _infoRow("Kode Ruangan", kodeRuanganBaru),
        _infoRow("Nama Ruangan", namaRuanganBaru),
        _infoRow("No. Aduan", noAduan),
        _infoRow("Tanggal", tanggal),
        _infoRow("Pelapor", "$namaPelapor (NIP: $nipPelapor)"),

        pw.SizedBox(height: 15),

        // ======= TABEL BARANG =======
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headers: [
            'No',
            'Kode Barang',
            'Nama Barang',
            'NUP',
            'Merk/Tipe',
            'Keterangan',
          ],
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: const pw.FixedColumnWidth(25),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2.5),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1.5),
            5: const pw.FlexColumnWidth(2),
          },
          data: [
            ["1", kodeBarang, namaBarang, nup, merk, keterangan],
          ],
        ),

        pw.SizedBox(height: 20),

        // ======= TANDA TANGAN =======
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Kolom Kiri - Asal
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    penanggungJawabAsal,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    kepalaPOMAsal,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 35),
                  pw.Text(namaPJAsal, style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(nipPJAsal, style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),

            // Kolom Kanan - Tujuan
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "$kotaTujuan${tanggal.isNotEmpty && tanggal != '-' ? ', $tanggal' : ''}",
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.right,
                  ),
                  pw.Text(
                    penanggungJawabTujuan,
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.right,
                  ),
                  pw.SizedBox(height: 35),
                  pw.Text(
                    namaPJTujuan,
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.right,
                  ),
                  pw.Text(
                    nipPJTujuan,
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

// ===================== Helper Widgets =====================
pw.Widget _infoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text("$label:", style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
    ),
  );
}
