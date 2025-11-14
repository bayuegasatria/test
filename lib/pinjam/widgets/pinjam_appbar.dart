import 'package:flutter/material.dart';
import 'package:newapp/pinjam/accpage.dart';

/// 🔹 AppBar khusus untuk halaman Peminjaman Kendaraan
PreferredSizeWidget pinjamAppBar(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 91,
    title: const Text(
      "Peminjaman Kendaraan",
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.blueGrey, width: 1),
            bottom: BorderSide(color: Colors.blueGrey, width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AccPage()),
                );
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            const SizedBox(width: 10),
            const Text(
              "Tambah Peminjaman",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    ),
  );
}
