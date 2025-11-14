import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/pinjam/accpage.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../api/pengajuan_api.dart';
import '../api/driver_api.dart';
import '../api/mobil_api.dart';

import 'widgets/read_only_field.dart';
import 'widgets/status_badge.dart';
import 'widgets/approval_form.dart';
import 'utils/acc_detail_helper.dart';

class AccDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String status;

  const AccDetailPage({super.key, required this.data, required this.status});

  @override
  State<AccDetailPage> createState() => _AccDetailPageState();
}

class _AccDetailPageState extends State<AccDetailPage> {
  String? selectedKendaraan;
  String? selectedSupir;
  final TextEditingController catatanController = TextEditingController();

  List<Map<String, dynamic>> kendaraanList = [];
  List<Map<String, dynamic>> supirList = [];
  Map<String, dynamic>? detailAcc;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.status.toLowerCase() == "y") {
      _loadDetailAcc();
    }
  }

  Future<void> _loadDropdownData() async {
    final tglBerangkat = DateTime.parse(widget.data["tanggal_berangkat"]);
    final tglKembali = DateTime.parse(widget.data["tanggal_kembali"]);
    final type = widget.data["jenis_kendaraan"];

    final mobil = await MobilApi.getAvailableMobil(
      tglBerangkat,
      tglKembali,
      type,
    );
    final supir = await DriverApi.getAvailableSupir(tglBerangkat, tglKembali);

    setState(() {
      kendaraanList = mobil;
      supirList = supir;
    });
  }

  Future<void> _loadDetailAcc() async {
    final res = await PengajuanApi.getDetailAcc(
      int.parse(widget.data["id"].toString()),
    );
    if (res != null) {
      setState(() {
        detailAcc = res;
      });
    }
  }

  Future<void> _handleTolak() async {
    await PengajuanApi.tolakPengajuan(
      pengajuanId: int.parse(widget.data["id"].toString()),
      catatan: catatanController.text,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccPage()),
      );
    }
  }

  Future<void> _handleBatalkan() async {
    await PengajuanApi.batalkanPengajuan(
      pengajuanId: int.parse(widget.data["id"].toString()),
      catatan: catatanController.text,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccPage()),
      );
    }
  }

  Future<void> _handleAcc() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false);

      final perluSupir =
          widget.data["perlu_supir"]?.toString().toLowerCase() == "y";

      if (selectedKendaraan == null ||
          (perluSupir && (selectedSupir == null || selectedSupir!.isEmpty))) {
        await showPopup(context, "Pilih kendaraan dan supir terlebih dahulu");
        return;
      }

      final int idMobil = int.parse(selectedKendaraan!);
      final int? idSupir =
          (perluSupir && selectedSupir != null && selectedSupir!.isNotEmpty)
          ? int.parse(selectedSupir!)
          : null;

      final bool success = await PengajuanApi.accPengajuan(
        idMobil: idMobil,
        idSupir: idSupir,
        catatan: catatanController.text,
        idPengajuan: int.parse(widget.data["id"].toString()),
        idUserLogin: int.parse(user.id),
      );

      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted && success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccPage()),
        );
      } else {
        await showPopup(context, "Gagal menyetujui pengajuan");
      }
    } catch (e) {
      await showPopup(context, "Terjadi kesalahan: $e");
    }
  }

  void _unfocusAll() {
    try {
      FocusScope.of(context).unfocus();
    } catch (_) {}

    try {
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (_) {}

    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final bool isAtasan = user.role == "Admin";
    final bool isFinal = ["y", "n", "c"].contains(widget.status.toLowerCase());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 91,
          title: const Text(
            "Persetujuan Peminjaman",
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                status: widget.status,
                getStatusColor: getStatusColor,
              ),
              const SizedBox(height: 20),

              ReadOnlyField(
                label: "Nomor Surat",
                value: widget.data["no_pengajuan"] ?? "-",
              ),
              ReadOnlyField(
                label: "Nama Pengaju",
                value: widget.data["nama"] ?? "-",
              ),
              ReadOnlyField(
                label: "Tujuan",
                value: widget.data["tujuan"] ?? "-",
              ),
              ReadOnlyField(
                label: "Tanggal Berangkat",
                value: widget.data["tanggal_berangkat"] ?? "-",
              ),
              ReadOnlyField(
                label: "Tanggal Kembali",
                value: widget.data["tanggal_kembali"] ?? "-",
              ),
              if (widget.data["file_url"] != null) ...[
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "File Pendukung",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          () {
                            final path = (widget.data["file_name"] ?? "")
                                .toLowerCase();
                            if (path.endsWith('.pdf')) {
                              return Icons.picture_as_pdf;
                            } else if (path.endsWith('.doc') ||
                                path.endsWith('.docx')) {
                              return Icons.description;
                            } else if (path.endsWith('.jpg') ||
                                path.endsWith('.jpeg') ||
                                path.endsWith('.png') ||
                                path.endsWith('.gif') ||
                                path.endsWith('.bmp') ||
                                path.endsWith('.webp')) {
                              return Icons.image;
                            } else {
                              return Icons.insert_drive_file;
                            }
                          }(),
                          color: () {
                            final path = (widget.data["file_name"] ?? "")
                                .toLowerCase();
                            if (path.endsWith('.pdf')) {
                              return Colors.red;
                            } else if (path.endsWith('.doc') ||
                                path.endsWith('.docx')) {
                              return Colors.blue;
                            } else if (path.endsWith('.jpg') ||
                                path.endsWith('.jpeg') ||
                                path.endsWith('.png') ||
                                path.endsWith('.gif') ||
                                path.endsWith('.bmp') ||
                                path.endsWith('.webp')) {
                              return Colors.green;
                            } else {
                              return Colors.grey;
                            }
                          }(),
                          size: 48,
                        ),
                      ),
                    ),

                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      onTap: () async {
                        _unfocusAll();
                        try {
                          final fileUrl = widget.data["file_url"];
                          final fileName =
                              widget.data["file_name"] ?? "lampiran.pdf";
                          final response = await http.get(Uri.parse(fileUrl));
                          if (response.statusCode == 200) {
                            final tempDir = await getTemporaryDirectory();
                            final filePath = '${tempDir.path}/$fileName';
                            final file = File(filePath);
                            await file.writeAsBytes(response.bodyBytes);
                            await OpenFilex.open(filePath);
                          } else {
                            await showPopup(context, "Gagal mengunduh file");
                          }
                        } catch (e) {
                          await showPopup(
                            context,
                            "Terjadi kesalahan saat membuka file",
                          );
                        }
                      },
                      leading: const Icon(
                        Icons.insert_drive_file,
                        color: Colors.blue,
                      ),
                      title: Text(
                        widget.data["file_name"] ?? "Lihat Lampiran",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Icons.open_in_new,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 20),
                const ReadOnlyField(
                  label: "Lampiran",
                  value: "Tidak ada lampiran",
                ),
              ],
              const SizedBox(height: 20),
              ReadOnlyField(
                label: "Keterangan",
                value: widget.data["keterangan"] ?? "-",
              ),

              if (widget.status.toLowerCase() == "y" && detailAcc != null) ...[
                ReadOnlyField(
                  label: "Kendaraan",
                  value: detailAcc!["nama_kendaraan"] ?? "-",
                ),
                ReadOnlyField(
                  label: "Supir",
                  value:
                      detailAcc!["nama_supir"] ??
                      (detailAcc!["pengemudi"] ?? "-"),
                ),
                ReadOnlyField(
                  label: "Catatan",
                  value: detailAcc!["catatan"] ?? "-",
                ),
              ] else if (widget.status.toLowerCase() == "n" ||
                  widget.status.toLowerCase() == "c") ...[
                ReadOnlyField(
                  label: "Catatan",
                  value: widget.data["catatan"] ?? "-",
                ),
              ] else if (widget.status.toLowerCase() == "p" && isAtasan) ...[
                ApprovalForm(
                  kendaraanList: kendaraanList,
                  supirList: supirList,
                  selectedKendaraan: selectedKendaraan,
                  selectedSupir: selectedSupir,
                  catatanController: catatanController,
                  readOnly: !isAtasan || isFinal,
                  perluSupir:
                      widget.data["perlu_supir"]?.toString().toLowerCase() ==
                      "y",
                  onKendaraanChanged: (val) =>
                      setState(() => selectedKendaraan = val),
                  onSupirChanged: (val) => setState(() => selectedSupir = val),
                ),
              ],

              const SizedBox(height: 30),
              if (!isFinal)
                Column(
                  children: [
                    if (isAtasan)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => _confirmDialog(
                                  title: "Konfirmasi Tolak Peminjaman",
                                  message: "Tolak Peminjaman?",
                                  confirmColor: Colors.red,
                                  confirmText: "Ya, Tolak",
                                ),
                              );
                              if (confirm == true) {
                                await _handleTolak();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(150, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Tolak",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => _confirmDialog(
                                  title: "Konfirmasi Acc Peminjaman",
                                  message: "Acc Peminjaman?",
                                  confirmColor: Colors.green,
                                  confirmText: "Ya, Acc",
                                ),
                              );
                              if (confirm == true) {
                                await _handleAcc();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(150, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "ACC",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => _confirmDialog(
                                title: "Konfirmasi Batalkan Pinjaman",
                                message: "Batalkan Peminjaman?",
                                confirmColor: Colors.orange,
                                confirmText: "Ya, Batalkan",
                              ),
                            );
                            if (confirm == true) {
                              await _handleBatalkan();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(320, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Batalkan",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Fungsi popup umum
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
            child: const Text("Dismiss"),
          ),
        ],
      ),
    );
  }

  // ✅ Fungsi dialog konfirmasi
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            backgroundColor: confirmColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
