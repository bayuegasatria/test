import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> cetakAduan(Map<String, dynamic> aduan) async {
  final pdf = pw.Document();

  // Fungsi konversi aman
  String safe(dynamic value) =>
      value?.toString().trim().isNotEmpty == true ? value.toString() : "-";

  // ===== Ambil data utama dari API atau form =====
  final tanggal = safe(aduan["tanggal"]);
  final nomorAduan = safe(aduan["no_aduan"] ?? aduan["nomor_aduan"]);
  final namaPegawai = safe(aduan["nama_user"] ?? aduan["namaUser"]);
  final bidang = safe(
    aduan["bidang"] ??
        aduan["nama_divisi"] ??
        aduan["divisi"] ??
        "Program dan Evaluasi (Tata Usaha)",
  );
  final jenisBarang = safe(aduan["nama_kelompok"] ?? aduan["jenis_kerusakan"]);
  final namaBarang = safe(aduan["nama_barang"] ?? aduan["namaBarang"]);
  final kodeBarang = safe(aduan["kode_barang"] ?? aduan["kodeBarang"]);
  final lokasi = safe(aduan["nama_lokasi"] ?? aduan["ruangan"]);

  // Bagian aduan
  final aduanKerusakan = safe(
    aduan["problem"] ?? aduan["deskripsi"] ?? aduan["aduan"],
  );

  final analisa = safe(aduan["analisa"] ?? aduan["analisa_kerusakan"]);
  final tindakLanjut = safe(aduan["follow_up"] ?? aduan["tindaklanjut"]);
  final hasil = safe(aduan["result"] ?? aduan["hasil_perbaikan"]);
  final tanggalAnalisis = safe(aduan["created_at"]);
  final tanggalTindakLanjut = safe(aduan["updated_at"]);
  final tanggalHasil = safe(aduan["analyze_date"]);

  // Nama & NIP pemeriksa dan pelapor
  final pemeriksa = safe(
    aduan["nama_petugas"] ?? aduan["pemeriksa"] ?? "........................",
  );
  final nipPemeriksa = safe(
    aduan["nip_petugas"] ?? aduan["nip_admin"] ?? aduan["nip_pemeriksa"] ?? "",
  );
  final pelapor = safe(aduan["nama_user"] ?? aduan["pelapor"]);
  final nipPelapor = safe(
    aduan["nip_user"] ?? aduan["nip_pelapor"] ?? aduan["nipPelapor"] ?? "",
  );

  // ===== Nomor Formulir Resmi (pojok kiri atas) =====
  const nomorFormulir =
      "Nomor Formulir: POM-14.01/CFM.01/SOP.01/IK.17A.01.F.01";

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // ===== NOMOR FORMULIR (kiri atas) =====
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            nomorFormulir,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),

        pw.SizedBox(height: 10),

        // ===== HEADER INSTANSI =====
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                "Balai Besar Pengawas Obat dan Makanan di Banjarbaru",
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Surat Permintaan Perbaikan BMN",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                "No. $nomorAduan",
                style: const pw.TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 25),

        // ===== INFORMASI PERMINTAAN =====
        _infoRow("Tanggal Permintaan", tanggal),
        _infoRow("Nama Pegawai", namaPegawai),
        _infoRow("Bag / Bid / Lab", bidang),
        _infoRow("Jenis Barang", jenisBarang),
        _infoRow(
          "Nama Barang",
          namaBarang != "-" && kodeBarang != "-"
              ? "$namaBarang (Kode: $kodeBarang)"
              : namaBarang,
        ),
        _infoRow("Lokasi", lokasi),

        pw.SizedBox(height: 15),

        // ===== BAGIAN ADUAN =====
        _sectionTitle("Aduan Kerusakan:"),
        _boxText(aduanKerusakan),

        pw.SizedBox(height: 15),
        _sectionTitle("Analisis Pemeriksa:"),
        _infoRow("Tanggal Analisis", tanggalAnalisis),
        _boxText(analisa),

        pw.SizedBox(height: 15),
        _sectionTitle("Tindak Lanjut:"),
        _infoRow("Tanggal Tindak Lanjut", tanggalTindakLanjut),
        _boxText(tindakLanjut),

        pw.SizedBox(height: 15),
        _sectionTitle("Hasil:"),
        _infoRow("Tanggal Hasil", tanggalHasil),
        _boxText(hasil),

        pw.SizedBox(height: 40),

        // ===== TANDA TANGAN =====
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _signatureColumn(
              "Kepala Bagian Tata Usaha",
              "Halida Endraswati, SF, Apt",
              "198004172005012001",
            ),
            _signatureColumn("Pemeriksa", pemeriksa, nipPemeriksa),
            _signatureColumn("Yang Meminta", pelapor, nipPelapor),
          ],
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

// ===================== WIDGET HELPER =====================

pw.Widget _infoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 150,
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
        ),
        pw.Expanded(
          child: pw.Text(": $value", style: const pw.TextStyle(fontSize: 11)),
        ),
      ],
    ),
  );
}

pw.Widget _sectionTitle(String title) {
  return pw.Text(
    title,
    style: pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      decoration: pw.TextDecoration.underline,
    ),
  );
}

pw.Widget _boxText(String text) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 0.5),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 11),
      textAlign: pw.TextAlign.justify,
    ),
  );
}

pw.Widget _signatureColumn(String title, String name, String nip) {
  return pw.Container(
    width: 150,
    alignment: pw.Alignment.topCenter,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 40),
        pw.Text(
          name,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        if (nip.isNotEmpty && nip != "-")
          pw.Text(
            "NIP. $nip",
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10),
          ),
      ],
    ),
  );
}
