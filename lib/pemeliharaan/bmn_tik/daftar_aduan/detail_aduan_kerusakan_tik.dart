import 'package:flutter/material.dart';

class DetailAduanTik extends StatelessWidget {
  final Map<String, dynamic> aduan;

  const DetailAduanTik({super.key, required this.aduan});

  // 🔹 Konversi status numerik → teks
  String _statusText(dynamic status) {
    if (status == null) return "Belum Diproses";
    final s = status.toString();
    if (s == "0") return "Belum Diproses";
    if (s == "1") return "Sedang Diproses";
    if (s == "2") return "Selesai Diproses";
    return s;
  }

  // 🔹 Warna status
  Color _statusColor(dynamic status) {
    if (status == null) return Colors.red;
    if (status.toString() == "2" || status == "Selesai Diproses")
      return Colors.green;
    if (status.toString() == "1" || status == "Sedang Diproses")
      return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusText(aduan['status']);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 91,
        title: const Text(
          "Aduan Kerusakan TIK",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Detail Aduan Kerusakan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                // 🔹 STATUS
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(aduan['status']),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 DETAIL ADUAN
                _buildDetailItem("Nomor Aduan", aduan['no_aduan']),
                _buildDetailItem("Tanggal", aduan['tanggal']),
                _buildDetailItem("Pelapor", aduan['nama_user']),
                _buildDetailItem("NIP Pelapor", aduan['nip']),
                _buildDetailItem("Bidang", aduan['nama_divisi']),
                _buildDetailItem("Nama Barang", aduan['nama_barang']),
                _buildDetailItem("Kode Barang", aduan['kode_barang']),
                _buildDetailItem("Spesifikasi", aduan['merk']),
                _buildDetailItem("Lokasi", aduan['lokasi']),
                const Divider(height: 32, thickness: 1),

                // 🔹 PEMERIKSA & HASIL
                _buildDetailItem("Petugas Pemeriksa", aduan['nama_petugas']),
                _buildDetailItem("Permasalahan", aduan['trouble']),
                _buildDetailItem("Analisa", aduan['analisa']),
                _buildDetailItem("Tindak Lanjut", aduan['follow_up']),
                _buildDetailItem("Hasil", aduan['result']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Widget builder untuk setiap baris data
  Widget _buildDetailItem(String label, dynamic value) {
    final text = (value == null || value.toString().trim().isEmpty)
        ? "-"
        : value.toString();

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
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
