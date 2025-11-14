import 'package:flutter/material.dart';

class DetailPerpindahanDBR extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPerpindahanDBR({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: const Text(
          "Sistem Perpindahan DBR",
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
                  "Detail Perpindahan DBR",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem("Nomor Aduan", data['no']),
                _buildDetailItem("Tanggal", data['tanggal']),
                _buildDetailItem("Nama Pelapor", data['nama_pelapor']),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  "Informasi Barang",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDetailItem("Kode Barang", data['kode_barang']),
                _buildDetailItem("Nama Barang", data['nama_barang']),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  "Asal Ruangan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDetailItem("Nama Ruangan Lama", data['nama_lokasi_lama']),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  "Tujuan Ruangan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDetailItem("Nama Ruangan Baru", data['nama_lokasi_baru']),
                const Divider(thickness: 1),
                _buildDetailItem("Keterangan", data['keterangan']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    final textValue = (value != null && value.toString().isNotEmpty)
        ? value.toString()
        : "-";
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label :",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              textValue,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
