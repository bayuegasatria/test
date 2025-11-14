import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/api/aduan_api.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';

class TambahAduanKerusakanNonTik extends StatefulWidget {
  const TambahAduanKerusakanNonTik({super.key});

  @override
  State<TambahAduanKerusakanNonTik> createState() =>
      _TambahAduanKerusakanNonTikState();
}

class _TambahAduanKerusakanNonTikState
    extends State<TambahAduanKerusakanNonTik> {
  String nomorAduan = "Memuat...";
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController penanggungJawabController =
      TextEditingController();
  final TextEditingController kelompokIdController = TextEditingController();

  DateTime? selectedDate;
  String? selectedKelompok;
  Map<String, dynamic>? selectedBarang;
  List<Map<String, dynamic>> katimList = [];
  String? selectedKATIM;
  int? selectedKatimId;

  List<Map<String, dynamic>> jenisBarangList = [];
  List<Map<String, dynamic>> inventarisList = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _generateNextNomorAduanPreview();
    _loadJenisBarang();
    _loadTeamleader();
  }

  Future<void> _loadJenisBarang() async {
    try {
      final data = await AduanApi.getJenisBarang();
      if (mounted) setState(() => jenisBarangList = data);
    } catch (e) {
      await showPopup(context, "Gagal memuat jenis barang: $e");
    }
  }

  Future<void> _loadInventaris(int jenisBarangId) async {
    try {
      final data = await AduanApi.getInventarisByJenis(
        jenisBarangId: jenisBarangId,
      );
      if (mounted) {
        setState(() {
          inventarisList = data;
          selectedBarang = null;
        });
      }
    } catch (e) {
      await showPopup(context, "Gagal memuat inventaris: $e");
    }
  }

  Future<void> _loadTeamleader() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final divisiId = int.tryParse(userProvider.divId) ?? 0;
      final data = await AduanApi.getTeamleaderByDivisi(divisiId);

      if (data != null && data.isNotEmpty) {
        setState(() {
          katimList = data.map<Map<String, dynamic>>((item) {
            return {
              'id': item['users_id'], // id yang akan disimpan
              'nama': item['nama_user'], // nama untuk ditampilkan
            };
          }).toList();
        });
      } else {
        setState(() => katimList = []);
      }
    } catch (e) {
      await showPopup(context, "Gagal memuat data KATIM: $e");
    }
  }

  Future<void> _generateNextNomorAduanPreview() async {
    final generatedNomor = await AduanApi.generateNoAduan();
    if (mounted) setState(() => nomorAduan = generatedNomor);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bidangUser = userProvider.div.isNotEmpty
        ? userProvider.div
        : "Belum Diatur";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 91,
        title: const Text(
          "Aduan Kerusakan NON-TIK",
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
                  "Tambah Aduan Kerusakan",
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
            _buildFrame(
              title: "Informasi Aduan",
              children: [
                _buildDisabledField("Nomor Aduan (Otomatis)", nomorAduan),
                const SizedBox(height: 12),
                _buildDisabledField(
                  "Tanggal",
                  DateFormat('yyyy-MM-dd').format(selectedDate!),
                ),
                const SizedBox(height: 12),
                _buildDisabledField("Pengadu", userProvider.nama),
                const SizedBox(height: 12),
                _buildDisabledField("Bidang", bidangUser),
                const SizedBox(height: 12),
                _buildSearchField(
                  "KATIM",
                  selectedKATIM,
                  katimList.map((e) => e['nama'] as String).toList(),
                  (value) {
                    final selected = katimList.firstWhere(
                      (e) => e['nama'] == value,
                      orElse: () => {'id': null, 'nama': null},
                    );
                    setState(() {
                      selectedKATIM = selected['nama'];
                      selectedKatimId = selected['id'];
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildFrame(
              title: "Barang yang Diadukan",
              children: [
                _buildSearchField(
                  "Kelompok Barang",
                  selectedKelompok,
                  jenisBarangList.map((e) => e['nama'] as String).toList(),
                  (value) {
                    final selected = jenisBarangList.firstWhere(
                      (e) => e['nama'] == value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty) {
                      setState(() {
                        selectedKelompok = selected['nama'];
                        kelompokIdController.text = selected['id'].toString();
                        selectedBarang = null;
                        inventarisList.clear();
                      });
                      _loadInventaris(int.parse(selected['id'].toString()));
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSearchField(
                  "Pilih Barang",
                  selectedBarang == null
                      ? null
                      : "${selectedBarang!['nama_barang']} || ${selectedBarang!['kode_barang'] ?? '-'}",
                  inventarisList
                      .map(
                        (e) =>
                            "${e['nama_barang']} || ${e['kode_barang'] ?? '-'}",
                      )
                      .toList(),
                  (value) {
                    final selected = inventarisList.firstWhere(
                      (e) =>
                          "${e['nama_barang']} || ${e['kode_barang'] ?? '-'}" ==
                          value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty) {
                      setState(() => selectedBarang = selected);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildDisabledField(
                  "Lokasi",
                  "${selectedBarang?['nama_lokasi'] ?? '-'}",
                ),
                const SizedBox(height: 12),
                _buildDisabledField(
                  "Penanggung Jawab",
                  "${selectedBarang?['nama_penanggungjawab'] ?? '-'}",
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  "Permasalahan",
                  keteranganController,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedKATIM == null ||
                      selectedKelompok == null ||
                      selectedBarang == null ||
                      keteranganController.text.trim().isEmpty) {
                    await showPopup(context, "Harap lengkapi data wajib");
                    return;
                  }

                  try {
                    final userProvider = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    );

                    final res = await AduanApi.addAduan(
                      noAduan: nomorAduan,
                      tanggal: DateFormat('yyyy-MM-dd').format(selectedDate!),
                      aduanStatus: "Belum Diproses",
                      pegawaiId: int.parse(userProvider.id),
                      divisiId: int.parse(userProvider.divId),
                      inventarisId: int.tryParse(
                        selectedBarang?['id'].toString() ?? '',
                      ),
                      problem: keteranganController.text.trim(),
                      katimId: selectedKatimId,
                    );

                    if (res["success"] == true) {
                      await showPopup(
                        context,
                        "Aduan berhasil disimpan",
                        title: "Berhasil",
                      );
                      Navigator.pop(context, {
                        "no_aduan": nomorAduan,
                        "tanggal": DateFormat(
                          'yyyy-MM-dd',
                        ).format(selectedDate!),
                        "status": "Belum Diproses",
                        "problem": keteranganController.text.trim(),
                      });
                    } else {
                      await showPopup(
                        context,
                        "Gagal menyimpan: ${res['message'] ?? 'Terjadi kesalahan tak terduga'}",
                      );
                    }
                  } catch (e) {
                    await showPopup(context, "Terjadi kesalahan: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C4FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrame({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[100],
          ),
          child: Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final result = await showDialog<String?>(
              context: context,
              builder: (context) => _SearchDialog(items: items, title: label),
            );
            if (result != null) onSelected(result);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value ?? "Pilih $label",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final List<String> items;
  final String title;
  const _SearchDialog({required this.items, required this.title});

  @override
  State<_SearchDialog> createState() => __SearchDialogState();
}

class __SearchDialogState extends State<_SearchDialog> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty
        ? widget.items
        : widget.items
              .where((e) => e.toLowerCase().contains(query.toLowerCase()))
              .toList();

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: "Cari ${widget.title}...",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filtered[index]),
                  onTap: () => Navigator.pop(context, filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Fungsi popup pengganti SnackBar
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
          child: const Text("Ok"),
        ),
      ],
    ),
  );
}
