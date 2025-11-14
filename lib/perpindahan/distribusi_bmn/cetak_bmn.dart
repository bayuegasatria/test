import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> cetakBmn(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  // ✅ Ambil data dengan fallback
  final nomor = data['nomor'] ?? data['no'] ?? '-';
  final tanggal = data['tanggal'] ?? '-';
  final pihakPertama =
      data['nama_pemilik_old'] ?? data['namaPemilikOld'] ?? '-';
  final pihakKedua = data['nama_pemilik_new'] ?? data['namaPemilikNew'] ?? '-';
  final inventarisId = data['inventaris_id']?.toString() ?? '-';
  final lokasi = data['nama_lokasi_baru'] ?? '-';
  final keterangan = data['ket'] ?? data['keterangan'] ?? '-';

  // ✅ Muat gambar template kop surat
  final Uint8List imageBytes = (await rootBundle.load(
    'assets/images/Kop Surat BPOM BJB A4 Sept 2025.png',
  )).buffer.asUint8List();

  final image = pw.MemoryImage(imageBytes);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero, // agar gambar benar-benar menutupi halaman
      build: (context) {
        return pw.Stack(
          children: [
            // 🔹 Background menutupi full A4
            pw.Positioned(
              left: 0,
              top: 0,
              child: pw.Image(
                image,
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                fit: pw.BoxFit.fill, // 🔹 pastikan memenuhi seluruh area
              ),
            ),

            // 🔹 Isi surat di atas background
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(50, 110, 50, 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'BERITA ACARA DISTRIBUSI BARANG MILIK NEGARA (BMN)',
                          style: pw.TextStyle(fontSize: 12),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'BALAI BESAR PENGAWAS OBAT DAN MAKANAN DI BANJARBARU',
                          style: pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Nomor Aduan : $nomor',
                          style: pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  pw.Text(
                    'Pada hari Rabu tanggal $tanggal bertempat di Banjarmasin yang bertanda tangan di bawah ini :',
                    style: const pw.TextStyle(fontSize: 11),
                    textAlign: pw.TextAlign.justify,
                  ),
                  pw.SizedBox(height: 12),

                  // 🔹 PIHAK PERTAMA
                  pw.Text(
                    'I.  Nama : $pihakPertama',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '    Jabatan  : Pemilik Sebelumnya',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '    Alamat   : Jl. Brigjend H. Hasan Basri No. 40, Banjarmasin',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '    Selanjutnya disebut  PIHAK PERTAMA',
                    style: pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 8),

                  // 🔹 PIHAK KEDUA
                  pw.Text(
                    'II. Nama : $pihakKedua',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '     Jabatan : Pemilik Baru',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '     Alamat  : Jl. Brigjend H. Hasan Basri No. 40, Banjarmasin',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    '     Selanjutnya disebut  PIHAK KEDUA',
                    style: pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 10),

                  pw.Text(
                    'PIHAK PERTAMA menyerahkan dan PIHAK KEDUA menerima penyerahan Barang Milik Negara (BMN) dengan spesifikasi sebagai berikut :',
                    style: const pw.TextStyle(fontSize: 11),
                    textAlign: pw.TextAlign.justify,
                  ),
                  pw.SizedBox(height: 10),

                  // 🔹 Tabel
                  pw.Table(
                    border: pw.TableBorder.all(width: 1),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(25),
                      1: const pw.FixedColumnWidth(120),
                      2: const pw.FixedColumnWidth(100),
                      3: const pw.FixedColumnWidth(70),
                      4: const pw.FixedColumnWidth(70),
                      5: const pw.FlexColumnWidth(),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _cellHeader('No'),
                          _cellHeader('Asal'),
                          _cellHeader('Baru'),
                          _cellHeader('Inventaris'),
                          _cellHeader('Lokasi'),
                          _cellHeader('Keterangan'),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _cellBody('1'),
                          _cellBody(pihakPertama),
                          _cellBody(pihakKedua),
                          _cellBody(inventarisId),
                          _cellBody(lokasi),
                          _cellBody(keterangan),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 12),
                  pw.Text(
                    'PIHAK KEDUA bertanggung jawab sepenuhnya atas barang-barang tersebut. Apabila terjadi kehilangan menjadi tanggung jawab yang bersangkutan.',
                    style: const pw.TextStyle(fontSize: 11),
                    textAlign: pw.TextAlign.justify,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Demikian Berita Acara ini dibuat dengan sebenarnya untuk dipergunakan sebagaimana mestinya.',
                    style: const pw.TextStyle(fontSize: 11),
                    textAlign: pw.TextAlign.justify,
                  ),

                  pw.SizedBox(height: 30),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            'PIHAK KEDUA',
                            style: pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 40),
                          pw.Text(
                            '($pihakKedua)',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            'PIHAK PERTAMA',
                            style: pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 40),
                          pw.Text(
                            '($pihakPertama)',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  // 🔹 Mengetahui
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Mengetahui,',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          'Kepala Balai Besar POM di Banjarbaru',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          'Selaku Kuasa Pengguna Barang',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(height: 40),
                        pw.Text(
                          '(Drs. Leonard Duma, Apt., M.M.)',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  pw.Align(
                    alignment: pw.Alignment.bottomLeft,
                    child: pw.Text(
                      'POM-14.01/CFM.01/SOP.01/IK.17A.01/F.01',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

// 🔹 Helper tabel
pw.Widget _cellHeader(String text) => pw.Padding(
  padding: const pw.EdgeInsets.all(5),
  child: pw.Center(
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
    ),
  ),
);

pw.Widget _cellBody(String text) => pw.Padding(
  padding: const pw.EdgeInsets.all(5),
  child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
);
