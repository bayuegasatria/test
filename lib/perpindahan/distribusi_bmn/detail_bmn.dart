import 'package:flutter/material.dart';

class DetailBmn extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailBmn({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: const Text(
          "Sistem Perpindahan BMN",
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
                  "Detail Pindah Tangan BMN",
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
                _buildDetailItem("Nomor BA", data['nomor']),
                _buildDetailItem("Tanggal", data['tanggal']),
                _buildDetailItem("Kelompok", data['kelompok']),
                _buildDetailItem("Nama Barang", data['nama_barang']),
                _buildDetailItem("Kode Barang", data['kode_barang']),
                _buildDetailItem("Merk / Tipe", data['merk']),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  "Asal Barang",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDetailItem("Pemilik Lama", data['nama_pemilik_old']),
                _buildDetailItem("Lokasi Lama", data['nama_lokasi_lama']),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  "Tujuan Barang",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDetailItem("Pemilik Baru", data['nama_pemilik_new']),
                _buildDetailItem("Lokasi Baru", data['nama_lokasi_baru']),
                const Divider(thickness: 1),
                _buildDetailItem("Keterangan", data['ket']),
                _buildDetailItem("Dibuat Pada", data['created_at']),
                _buildDetailItem("Diperbarui Pada", data['updated_at']),
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
