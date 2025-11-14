import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newapp/api/pinjam_api.dart';

class PengembalianPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const PengembalianPage({super.key, this.data});
  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  late Future<Map<String, dynamic>?> detailFuture;
  final TextEditingController kmAwalController = TextEditingController();
  final TextEditingController kmAkhirController = TextEditingController();
  File? fotoKmAwal;
  File? fotoKmAkhir;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    final idPinjam = widget.data?["id_pinjam"];
    if (idPinjam != null) {
      detailFuture = PinjamApi.getDetailPinjam(idPinjam);
    } else {
      detailFuture = Future.value(null);
    }
  }

  Future<void> _showImageSourcePicker(bool isAwal) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              title: const Text("Buka Kamera"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera(isAwal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.green),
              title: const Text("Pilih dari Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickFile(isAwal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.red),
              title: const Text("Batal"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera(bool isAwal) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        if (isAwal) {
          fotoKmAwal = File(photo.path);
        } else {
          fotoKmAkhir = File(photo.path);
        }
      });
    }
  }

  Future<void> _pickFile(bool isAwal) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isAwal) {
          fotoKmAwal = File(result.files.single.path!);
        } else {
          fotoKmAkhir = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> showPopup(
    BuildContext context,
    String message, {
    String title = "Peringatan",
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueAccent,
          ),
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _confirmDialog({
    required String title,
    required String message,
    required Color confirmColor,
    required String confirmText,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blueAccent,
        ),
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
          ),
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Batal"),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: confirmColor,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return Colors.green;
      case "batal":
        return Colors.orangeAccent;
      case "menunggu":
        return Colors.yellow;
      case "terlambat":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return Icons.check_circle;
      case "batal":
        return Icons.cancel;
      case "menunggu":
        return Icons.schedule;
      case "terlambat":
        return Icons.warning_amber_rounded;
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
      case "menunggu":
        return "Belum Dimulai";
      case "terlambat":
        return "Terlambat";
      default:
        return "Sedang Dipinjam";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd MMM yyyy, HH:mm");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 91,
        automaticallyImplyLeading: false,
        title: const Text(
          "Pengembalian Peminjaman",
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
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }
          final data = snapshot.data!;
          final tglSelesai = DateTime.tryParse(data["tanggal_kembali"]);
          final String status = data['status'];
          final bool isSedangDipinjam = status.toLowerCase() == "berjalan";
          final bool isMenunggu = status.toLowerCase() == "menunggu";
          final now = DateTime.now();
          final bool isTerlambat =
              tglSelesai != null &&
              now.isAfter(tglSelesai) &&
              status.toLowerCase() == "berjalan";
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBadge(isTerlambat ? "terlambat" : status),
                const SizedBox(height: 20),
                _buildReadOnlyField("No Pengajuan", data["no_pengajuan"]),
                const SizedBox(height: 20),
                _buildReadOnlyField("Nama Peminjam", data["nama"]),
                const SizedBox(height: 20),
                _buildReadOnlyField(
                  "Batas Waktu Pengembalian",
                  (tglSelesai != null) ? dateFormat.format(tglSelesai) : "-",
                ),
                const SizedBox(height: 20),
                _buildReadOnlyField("Tujuan", data["tujuan"]),
                const SizedBox(height: 20),
                _buildReadOnlyField("Nama Kendaraan", data["kendaraan"]),
                const SizedBox(height: 20),
                _buildReadOnlyField("Supir", data["nama_supir"]),
                const SizedBox(height: 30),
                _judul("KM Awal"),
                TextField(
                  controller: kmAwalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Masukkan KM awal",
                  ),
                ),
                const SizedBox(height: 20),
                _judul("Upload Foto KM Awal"),
                _buildUploadBox(true),
                const SizedBox(height: 20),
                _judul("KM Akhir"),
                TextField(
                  controller: kmAkhirController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Masukkan KM akhir",
                  ),
                ),
                const SizedBox(height: 20),
                _judul("Upload Foto KM Akhir"),
                _buildUploadBox(false),
                const SizedBox(height: 30),
                if (isSedangDipinjam)
                  _buildActionButton(
                    context,
                    color: Colors.green,
                    text: "Selesai Pinjam",
                    confirmTitle: "Konfirmasi Pengembalian",
                    confirmMsg:
                        "Apakah Anda yakin ingin menyelesaikan peminjaman ini?",
                    successMsg: "Peminjaman berhasil diselesaikan.",
                    status: "selesai",
                  ),
                if (isMenunggu)
                  _buildActionButton(
                    context,
                    color: Colors.red,
                    text: "Batalkan",
                    confirmTitle: "Konfirmasi Pembatalan",
                    confirmMsg:
                        "Apakah Anda yakin ingin membatalkan peminjaman ini?",
                    successMsg: "Peminjaman berhasil dibatalkan.",
                    status: "batal",
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _judul(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
  Widget _buildStatusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    decoration: BoxDecoration(
      color: _getStatusColor(status),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getStatusIcon(status), color: Colors.white),
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
  );
  Widget _buildUploadBox(bool isAwal) {
    final file = isAwal ? fotoKmAwal : fotoKmAkhir;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showImageSourcePicker(isAwal),
          icon: const Icon(Icons.add_a_photo, color: Colors.white),
          label: const Text(
            "Ambil / Pilih Foto",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        ),
        const SizedBox(height: 10),
        if (file != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              file,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          )
        else
          const Text(
            "Belum ada foto dipilih",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String? value) => Column(
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
  );
  Widget _buildActionButton(
    BuildContext context, {
    required Color color,
    required String text,
    required String confirmTitle,
    required String confirmMsg,
    required String successMsg,
    required String status,
  }) {
    return Center(
      child: SizedBox(
        height: 60,
        width: 220,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => _confirmDialog(
                title: confirmTitle,
                message: confirmMsg,
                confirmColor: color,
                confirmText: "Ya",
              ),
            );
            if (confirm != true) return;
            final idPinjam = widget.data?["id_pinjam"];
            final success = await PinjamApi.updateStatusPinjamById(
              idPinjam,
              status,
              kmAwal: kmAwalController.text,
              kmAkhir: kmAkhirController.text,
              fotoKmAwal: fotoKmAwal,
              fotoKmAkhir: fotoKmAkhir,
            );
            if (!context.mounted) return;
            if (success) {
              await showPopup(context, successMsg, title: "Berhasil");
              Navigator.pop(context, status);
            } else {
              await showPopup(
                context,
                "Gagal memperbarui data",
                title: "Gagal",
              );
            }
          },
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
