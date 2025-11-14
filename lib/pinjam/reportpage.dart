import 'package:flutter/material.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:newapp/pinjam/utils/laporan_frekuesi_form.dart';
import 'package:newapp/pinjam/utils/laporan_pemakaian_form.dart';
import 'package:newapp/pinjam/utils/laporan_peminjaman_form.dart';
import 'package:newapp/pinjam/utils/laporan_aduan.dart';
import 'package:newapp/pinjam/utils/laporan_aduan_tik.dart';
import 'package:newapp/pinjam/utils/laporan_distribusi_bmn.dart';
import 'package:newapp/pinjam/utils/laporan_perpindahan_dbr.dart';
import 'package:provider/provider.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? selectedJenis;

  final List<String> jenisLaporanList = [
    "Laporan Peminjaman Kendaraan",
    "Laporan Pemakaian Kendaraan",
    "Laporan Jumlah Peminjaman",
    "Laporan aduan TIK",
    "Laporan aduan Non-TIK",
    "Laporan Distribusi BMN",
    "Laporan Perpindahan DBR",
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: const Text(
          "Laporan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Halaman Laporan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Pilih Jenis Laporan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedJenis,
              items: jenisLaporanList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedJenis = value),
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
            const SizedBox(height: 30),

            // FORM SESUAI PILIHAN
            if (selectedJenis == "Laporan Peminjaman Kendaraan")
              LaporanPeminjamanForm(userRole: user.role, userDivisi: user.div),
            if (selectedJenis == "Laporan Jumlah Peminjaman")
              LaporanFrekuensiForm(userDivisi: user.div, userRole: user.role),
            if (selectedJenis == "Laporan aduan TIK")
              LaporanAduanTikForm(userDivisi: user.div, userRole: user.role),
            if (selectedJenis == "Laporan aduan Non-TIK")
              LaporanAduanNonTikForm(userDivisi: user.div, userRole: user.role),
            if (selectedJenis == "Laporan Distribusi BMN")
              LaporanDistribusiBmnForm(
                userDivisi: user.div,
                userRole: user.role,
              ),
            if (selectedJenis == "Laporan Perpindahan DBR")
              LaporanDistribusiDbrForm(
                userDivisi: user.div,
                userRole: user.role,
              ),
            if (selectedJenis == "Laporan Pemakaian Kendaraan")
              LaporanPemakaianForm(userDivisi: user.div, userRole: user.role),
          ],
        ),
      ),
    );
  }
}
