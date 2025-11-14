import 'package:flutter/material.dart';
import '../api/pinjam_api.dart';

class Detailpinjampage extends StatefulWidget {
  final int idPinjam;

  const Detailpinjampage({super.key, required this.idPinjam});

  @override
  State<Detailpinjampage> createState() => _DetailpinjampageState();
}

class _DetailpinjampageState extends State<Detailpinjampage> {
  Future<Map<String, dynamic>?>? _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = PinjamApi.getDetailPinjam(widget.idPinjam);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return Colors.green;
      case "batal":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return Icons.check_circle;
      case "batal":
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return "Selesai";
      case "batal":
        return "Dibatalkan";
      default:
        return "Sedang Dipinjam";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 91,
        automaticallyImplyLeading: false,
        title: const Text(
          "History Peminjaman",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey, width: 1),
              ),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Detail Peminjaman",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final data = snapshot.data!;
          final String status = data["status"] ?? "sedang dipinjam";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _getStatusLabel(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildReadOnlyField("No Pengajuan", data["no_pengajuan"]),
                _buildReadOnlyField("Nama Peminjam", data["nama"]),
                _buildReadOnlyField(
                  "Tanggal Pengembalian",
                  data["tanggal_pengembalian"],
                ),
                _buildReadOnlyField("Tujuan", data["tujuan"]),
                _buildReadOnlyField("Nama Kendaraan", data["kendaraan"]),
                _buildReadOnlyField("Supir", data["nama_supir"]),

                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 10),

                const Text(
                  "Informasi Kilometer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _buildReadOnlyField("KM Awal", data["km_awal"]),
                _buildReadOnlyField("KM Akhir", data["km_akhir"]),
                const SizedBox(height: 10),

                if (data["foto_km_awal_url"] != null)
                  _buildImagePreview(
                    "Foto KM Awal",
                    data["foto_km_awal_url"] as String,
                  ),
                if (data["foto_km_akhir_url"] != null)
                  _buildImagePreview(
                    "Foto KM Akhir",
                    data["foto_km_akhir_url"] as String,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: value ?? "-"),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,

              // ⬇️ ANIMASI LOADING SAAT DOWNLOAD GAMBAR
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child; // selesai load

                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200], // background placeholder
                  child: const Center(child: CircularProgressIndicator()),
                );
              },

              // error handler kalau URL rusak
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                height: 200,
                child: const Center(child: Text("Gambar tidak tersedia")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
