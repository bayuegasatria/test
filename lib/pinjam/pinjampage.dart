import 'dart:io';
import 'package:flutter/material.dart';
import 'package:newapp/api/pengajuan_api.dart';
import 'package:newapp/pinjam/accpage.dart';
import 'package:newapp/pinjam/user_provider.dart' show UserProvider;
import 'package:provider/provider.dart' show Provider;

import 'utils/pinjam_helper.dart';
import 'utils/pinjam_form.dart';
import 'widgets/pinjam_appbar.dart';

class PinjamPage extends StatefulWidget {
  const PinjamPage({super.key});

  @override
  State<PinjamPage> createState() => _PinjamPageState();
}

class _PinjamPageState extends State<PinjamPage> {
  final TextEditingController nomorAjuanController = TextEditingController();
  final TextEditingController namaPengajuController = TextEditingController();
  final TextEditingController tujuanController = TextEditingController();
  final TextEditingController pengemudiController = TextEditingController();
  final TextEditingController jumlahPenumpangController =
      TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  DateTime dariTanggal = DateTime.now();
  TimeOfDay dariJam = const TimeOfDay(hour: 7, minute: 30);
  DateTime sampaiTanggal = DateTime.now().add(const Duration(days: 1));
  TimeOfDay sampaiJam = const TimeOfDay(hour: 10, minute: 0);

  String jenisKendaraan = "Mobil";
  String supir = "Ya";
  late String jenisValue;
  String? nomor;
  late String noPengajuan;

  File? fileLampiran;
  Future<void> generateNomor() async {
    final result = await PengajuanApi.generateNoPengajuan();
    setState(() {
      nomor = result ?? "Gagal generate nomor";
    });
  }

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await generateNomor(); // ✅ tunggu generate selesai

    final now = DateTime.now();
    noPengajuan = nomor ?? "gagal";

    print("Nomor hasil generate: $noPengajuan");

    // isi ke controller setelah dapat hasil
    nomorAjuanController.text = noPengajuan;

    // set tanggal default
    dariTanggal = DateTime(now.year, now.month, now.day);
    dariJam = TimeOfDay(hour: now.hour, minute: now.minute);

    final satuJamSetelah = now.add(const Duration(hours: 1));
    sampaiTanggal = DateTime(
      satuJamSetelah.year,
      satuJamSetelah.month,
      satuJamSetelah.day,
    );
    sampaiJam = TimeOfDay(
      hour: satuJamSetelah.hour,
      minute: satuJamSetelah.minute,
    );

    // panggil setState agar widget update tampilan
    setState(() {});
  }

  Future<void> _simpanPengajuan(String userId) async {
    if (jenisKendaraan.toLowerCase() == "mobil") {
      jenisValue = "C";
    } else {
      supir = "tidak";
      jenisValue = "M";
    }
    String supirValue = supir.toLowerCase() == "ya" ? "Y" : "N";
    if (tujuanController.text.trim().isEmpty) {
      await showPopup(context, "Tujuan tidak boleh kosong.");
      return;
    }

    if (supir == "Tidak" && pengemudiController.text.trim().isEmpty) {
      await showPopup(
        context,
        "Nama pengemudi harus diisi jika tidak menggunakan supir.",
      );
      return;
    }

    final valid = await simpanPengajuanHelper(
      context: context,
      userId: userId,
      dariTanggal: dariTanggal,
      dariJam: dariJam,
      sampaiTanggal: sampaiTanggal,
      sampaiJam: sampaiJam,
      noPengajuan: noPengajuan,
      tujuan: tujuanController.text,
      jenisKendaraan: jenisValue,
      supir: supirValue,
      pengemudi: pengemudiController.text,
      jumlahPenumpang: jumlahPenumpangController.text,
      keterangan: keteranganController.text,
      fileLampiran: fileLampiran,
    );

    if (valid && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AccPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    namaPengajuController.text = user.nama;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: pinjamAppBar(context),
        body: PinjamForm(
          nomorAjuanController: nomorAjuanController,
          namaPengajuController: namaPengajuController,
          tujuanController: tujuanController,
          pengemudiController: pengemudiController,
          jumlahPenumpangController: jumlahPenumpangController,
          keteranganController: keteranganController,
          dariTanggal: dariTanggal,
          dariJam: dariJam,
          sampaiTanggal: sampaiTanggal,
          sampaiJam: sampaiJam,
          jenisKendaraan: jenisKendaraan,
          supir: supir,
          onJenisKendaraanChanged: (val) =>
              setState(() => jenisKendaraan = val),
          onSupirChanged: (val) => setState(() => supir = val),

          pilihTanggal: (isDari) => pilihTanggalHelper(
            context: context,
            isDari: isDari,
            dariTanggal: dariTanggal,
            sampaiTanggal: sampaiTanggal,
            dariJam: dariJam,
            sampaiJam: sampaiJam,
            onUpdate: (newDari, newSampai, newDariJam, newSampaiJam) {
              setState(() {
                dariTanggal = newDari;
                sampaiTanggal = newSampai;
                dariJam = newDariJam;
                sampaiJam = newSampaiJam;
              });
            },
          ),
          pilihJam: (isDari) => pilihJamHelper(
            context: context,
            isDari: isDari,
            dariTanggal: dariTanggal,
            sampaiTanggal: sampaiTanggal,
            dariJam: dariJam,
            sampaiJam: sampaiJam,
            onUpdate: (newDariJam, newSampaiJam) {
              setState(() {
                dariJam = newDariJam;
                sampaiJam = newSampaiJam;
              });
            },
          ),

          onFilePicked: (file) => setState(() {
            fileLampiran = file;
          }),

          onSelesai: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.white,
                title: const Text(
                  "Konfirmasi Pinjam",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blueAccent,
                  ),
                ),
                content: const Text(
                  "Tambahkan Peminjaman?",
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Ya, Tambahkan"),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await _simpanPengajuan(user.id);
            }
          },
        ),
      ),
    );
  }
}
