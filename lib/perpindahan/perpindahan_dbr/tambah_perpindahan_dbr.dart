import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/api/pindahtangan_api.dart';
import 'package:newapp/api/user_api.dart';

class TambahPerpindahanDBR extends StatefulWidget {
  const TambahPerpindahanDBR({super.key});

  @override
  State<TambahPerpindahanDBR> createState() => _TambahPerpindahanDBRState();
}

class _TambahPerpindahanDBRState extends State<TambahPerpindahanDBR> {
  final TextEditingController _noAduanController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _ruanganLamaController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String? _selectedJenisBarang;
  String? _selectedBarang;
  String? _selectedRuanganBaru;

  String? _jenisId;
  late String _barangId;
  late String _ruanganLamaId;
  late String _ruanganBaruId;

  List<dynamic> _jenisBarangList = [];
  List<dynamic> _barangList = [];
  List<dynamic> _ruanganList = [];

  String? _pelaporNama;
  String? _pelaporNip;
  late String _pelaporid;
  List<dynamic> _usersList = [];
  String? _selectedPelapor;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _tanggalController.text = DateFormat('yyyy-MM-dd').format(now);
    _generateNomorOtomatis();
    _loadInitialData();
  }

  Future<void> _generateNomorOtomatis() async {
    final nomor = await PindahtanganApi.generateNomor();
    if (mounted) {
      setState(() {
        _noAduanController.text = nomor ?? '';
      });
    }
  }

  Future<void> _loadInitialData() async {
    final jenisBarang = await PindahtanganApi.getJenisBarang();
    final lokasi = await PindahtanganApi.getLokasi();

    final users = await UserApi.getAllUsers(); // 🔹 ambil dari DB

    setState(() {
      _jenisBarangList = jenisBarang;
      _ruanganList = lokasi;

      _usersList = users; // 🔹 simpan data user DB
    });
  }

  Future<void> _loadBarangByJenis(int jenisId) async {
    final res = await PindahtanganApi.getInventarisByJenisBarang(jenisId);
    setState(() {
      _barangList = res["data"] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 91,
        title: const Text(
          "Sistem Perpindahan",
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
                  "Tambah Perpindahan DBR",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _jenisBarangList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFrame(
                    title: "Informasi Umum",
                    children: [
                      _buildDisabledField("No Aduan", _noAduanController.text),
                      const SizedBox(height: 12),
                      _buildDisabledField("Tanggal", _tanggalController.text),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        "Pelapor",
                        _selectedPelapor,
                        _usersList
                            .map((u) => "${u['name']} || ${u['nip']}")
                            .toList(),
                        (value) {
                          final user = _usersList.firstWhere(
                            (u) =>
                                value!.contains(u['name']) &&
                                value.contains(u['nip']),
                          );

                          setState(() {
                            _selectedPelapor =
                                "${user['name']} || ${user['nip']}";
                            _pelaporid = user['id'].toString();
                            _pelaporNama = user['name'];
                            _pelaporNip = user['nip'];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFrame(
                    title: "Informasi Barang",
                    children: [
                      _buildSearchField(
                        "Jenis Barang",
                        _selectedJenisBarang,
                        _jenisBarangList
                            .map((e) => e['nama'] as String)
                            .toList(),
                        (value) {
                          final selected = _jenisBarangList.firstWhere(
                            (e) => e['nama'] == value,
                            orElse: () => {},
                          );
                          final id = selected['id']?.toString();
                          setState(() {
                            _selectedJenisBarang = value;
                            _jenisId = id;
                            _selectedBarang = null;
                            _merkController.clear();
                            _ruanganLamaController.clear();
                            _barangList.clear();
                          });
                          if (id != null) _loadBarangByJenis(int.parse(id));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        "Nama Barang",
                        _selectedBarang,
                        _barangList
                            .map(
                              (b) =>
                                  "${b['nama_barang']} || ${b['kode_barang']} (NUP: ${b['kode_bmn']})",
                            )
                            .toList(),
                        (value) {
                          final barang = _barangList.firstWhere(
                            (b) =>
                                value!.contains(b['nama_barang']) &&
                                value.contains(b['kode_barang']),
                          );
                          setState(() {
                            _selectedBarang =
                                "${barang['nama_barang']} || ${barang['kode_barang']}";
                            _barangId = barang['id'].toString();
                            _merkController.text = barang['merk'] ?? '-';
                            _ruanganLamaController.text =
                                barang['nama_lokasi'] ?? '-';
                            _ruanganLamaId = barang['lokasi'].toString();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDisabledField("Merk", _merkController.text),
                      const SizedBox(height: 12),
                      _buildDisabledField(
                        "Kode/Nama Ruangan Lama",
                        _ruanganLamaController.text,
                      ),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        "Kode/Nama Ruangan Baru",
                        _selectedRuanganBaru,
                        _ruanganList.map((r) => r['nama'] as String).toList(),
                        (value) {
                          final ruangan = _ruanganList.firstWhere(
                            (r) => r['nama'] == value,
                          );
                          setState(() {
                            _selectedRuanganBaru = value;
                            _ruanganBaruId = ruangan['id'].toString();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Keterangan",
                        _keteranganController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSimpan,
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
            style: const TextStyle(color: Colors.black54),
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

  Future<void> _handleSimpan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menyimpan data perpindahan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Ya"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await PindahtanganApi.addPerpindahanDBR(
        nomor: _noAduanController.text,
        tanggal: _tanggalController.text,
        pelaporid: _pelaporid,
        barangId: _barangId,
        ruanganBaruId: _ruanganBaruId,
        ruanganLamaId: _ruanganLamaId,
        keterangan: _keteranganController.text,
      );

      if (result['status'] == 'success') {
        await showPopup(context, "Data berhasil disimpan.", title: "Berhasil");
        Navigator.pop(context, true);
      } else {
        await showPopup(
          context,
          result['message'] ?? 'Gagal menyimpan data.',
          title: "Gagal",
        );
      }
    } catch (e) {
      await showPopup(context, "Terjadi kesalahan: $e", title: "Error");
    }
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
  String title = "Info",
}) async {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
