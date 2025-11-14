import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/api/aduan_tik_api.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';

class TambahAduanKerusakanTIK extends StatefulWidget {
  const TambahAduanKerusakanTIK({super.key});

  @override
  State<TambahAduanKerusakanTIK> createState() =>
      _TambahAduanKerusakanTIKState();
}

class _TambahAduanKerusakanTIKState extends State<TambahAduanKerusakanTIK> {
  String nomorAduan = "Memuat...";
  DateTime selectedDate = DateTime.now();

  String? selectedJenisTIK;
  String? selectedAsset;
  Map<String, dynamic>? selectedAssetInfo;

  List<Map<String, dynamic>> jenisTikList = [];
  List<Map<String, dynamic>> itAssetList = [];

  final TextEditingController keteranganController = TextEditingController();
  final AduanTikApi _api = AduanTikApi();

  @override
  void initState() {
    super.initState();
    _loadJenisTik();
    _generateNoAduan();
  }

  Future<void> _loadJenisTik() async {
    try {
      final data = await AduanTikApi.getJenisTik();
      if (mounted) setState(() => jenisTikList = data);
    } catch (e) {
      await showPopup(context, "Gagal memuat jenis TIK: $e");
    }
  }

  Future<void> _loadItAsset(int jenistikId) async {
    try {
      final data = await AduanTikApi.getItAssetByJenisTIK(jenistikId);
      if (mounted) {
        setState(() {
          itAssetList = data;
          selectedAsset = null;
          selectedAssetInfo = null;
        });
      }
    } catch (e) {
      await showPopup(context, "Gagal memuat data aset: $e");
    }
  }

  Future<void> _generateNoAduan() async {
    try {
      final nomor = await AduanTikApi.generateNoAduanTik();
      if (mounted) setState(() => nomorAduan = nomor);
    } catch (e) {
      setState(() => nomorAduan = "Error");
      await showPopup(context, "Gagal generate nomor aduan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
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
                  "Tambah Aduan Kerusakan TIK",
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
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                ),
                const SizedBox(height: 12),
                _buildDisabledField("Pengadu", userProvider.nama),
                const SizedBox(height: 12),
                _buildDisabledField("Bidang", userProvider.div),
              ],
            ),
            const SizedBox(height: 16),

            _buildFrame(
              title: "Barang TIK yang Diadukan",
              children: [
                _buildSearchField(
                  "Jenis Barang TIK",
                  selectedJenisTIK,
                  jenisTikList.map((e) => e['kelompok'] as String).toList(),
                  (value) {
                    final selected = jenisTikList.firstWhere(
                      (e) => e['kelompok'] == value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty) {
                      setState(() {
                        selectedJenisTIK = selected['kelompok'];
                      });
                      _loadItAsset(int.parse(selected['id'].toString()));
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSearchField(
                  "Pilih Aset TIK",
                  selectedAsset == null
                      ? null
                      : "${selectedAssetInfo?['nama_barang']} || ${selectedAssetInfo?['kode_barang'] ?? '-'}",
                  itAssetList
                      .map(
                        (e) =>
                            "${e['nama_barang']} || ${e['kode_barang'] ?? '-'}",
                      )
                      .toList(),
                  (value) {
                    final selected = itAssetList.firstWhere(
                      (e) =>
                          "${e['nama_barang']} || ${e['kode_barang'] ?? '-'}" ==
                          value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty) {
                      setState(() {
                        selectedAsset = value;
                        selectedAssetInfo = selected;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildDisabledField(
                  "Lokasi",
                  "${selectedAssetInfo?['lokasi'] ?? '-'}",
                ),
                const SizedBox(height: 12),
                _buildDisabledField(
                  "Penanggung Jawab",
                  "${selectedAssetInfo?['nama_pengguna'] ?? '-'}",
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
                onPressed: _simpanAduan,
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

  Future<void> _simpanAduan() async {
    if (selectedJenisTIK == null ||
        selectedAssetInfo == null ||
        keteranganController.text.trim().isEmpty) {
      await showPopup(context, "Harap lengkapi semua data wajib");
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await _api.tambahAduanTik(
        noAduan: nomorAduan,
        tanggal: DateFormat('yyyy-MM-dd').format(selectedDate),
        usersId: int.parse(userProvider.id),
        divisiId: int.parse(userProvider.divId),
        itassetId: int.parse(selectedAssetInfo?['id'].toString() ?? '0'),
        trouble: keteranganController.text.trim(),
      );

      await showPopup(
        context,
        "Aduan TIK berhasil disimpan",
        title: "Berhasil",
      );
      Navigator.pop(context, {
        "no_aduan": nomorAduan,
        "tanggal": DateFormat('yyyy-MM-dd').format(selectedDate),
        "status": "Belum Diproses",
        "trouble": keteranganController.text.trim(),
      });
    } catch (e) {
      await showPopup(context, "Gagal menyimpan aduan: $e");
    }
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
