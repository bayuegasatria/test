import 'package:flutter/material.dart';
import 'package:newapp/pinjam/dashboard.dart';

/// 🔹 Dialog saat user masih punya pinjaman aktif (dari API)
Widget pinjamanAktifDialog(BuildContext context) {
  return AlertDialog(
    title: const Text(
      "Peminjaman Aktif",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.blueAccent,
      ),
    ),
    content: const Text(
      "Anda masih mempunyai pinjaman yang belum selesai. "
      "Harap selesaikan pinjaman sebelumnya sebelum membuat pengajuan baru.",
      textAlign: TextAlign.left,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: Colors.white,
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
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        },
        child: const Text("OK"),
      ),
    ],
  );
}

/// 🔹 Dialog saat tanggal/jam tidak valid (fallback)
Widget invalidTanggalDialog(BuildContext context, {String? message}) {
  return AlertDialog(
    title: const Text(
      "Tanggal/Jam Tidak Valid",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    content: Text(message ?? "Waktu mulai tidak boleh melebihi waktu selesai."),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("OK"),
      ),
    ],
  );
}
