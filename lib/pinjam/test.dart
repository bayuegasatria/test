import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class PengajuanPage extends StatelessWidget {
  const PengajuanPage({super.key});

  Future<List<Map<String, dynamic>>> _loadData() async {
    final db = DatabaseHelper();
    return await db.getAllPengajuan();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "disetujui":
        return Colors.green;
      case "ditolak":
        return Colors.red;
      case "baru":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Pengajuan")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada data pengajuan.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final status = item['status'] ?? "-";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: Text(
                      item['id'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    "No. Pengajuan: ${item['no_pengajuan'] ?? '-'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Tujuan: ${item['tujuan'] ?? '-'}\n"
                    "Tanggal: ${item['tanggal_berangkat'] ?? '-'} - ${item['tanggal_kembali'] ?? '-'}\n"
                    "Status: ${item['status'] ?? '-'}\n"
                    "dibaca ${item['perlu_supir'] ?? '-'}",
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Detail Pengajuan"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("No Pengajuan: ${item['no_pengajuan']}"),
                            Text("Tujuan: ${item['tujuan']}"),
                            Text("Jenis Kendaraan: ${item['jenis_kendaraan']}"),
                            Text("Perlu Supir: ${item['perlu_supir']}"),
                            Text("Pengemudi: ${item['pengemudi']}"),
                            Text(
                              "Tanggal Berangkat: ${item['tanggal_berangkat']}",
                            ),
                            Text("Tanggal Kembali: ${item['tanggal_kembali']}"),
                            Text("Jumlah Pengguna: ${item['jumlah_pengguna']}"),
                            Text("Keterangan: ${item['keterangan']}"),
                            Text("Catatan: ${item['catatan']}"),
                            Text("Status: ${item['status']}"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Tutup"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
