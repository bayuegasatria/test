import 'package:flutter/material.dart';
import 'package:newapp/api/pindahtangan_api.dart';
import 'package:newapp/perpindahan/distribusi_bmn/distribusi_bmn.dart';

class EditDistribusiBmnScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditDistribusiBmnScreen({super.key, required this.data});

  @override
  State<EditDistribusiBmnScreen> createState() =>
      _EditDistribusiBmnScreenState();
}

class _EditDistribusiBmnScreenState extends State<EditDistribusiBmnScreen> {
  final TextEditingController _noSipandaController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _noSeriController = TextEditingController();
  final TextEditingController _alamatPemilikAsalController =
      TextEditingController();
  final TextEditingController _alamatPemilikBaruController =
      TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String _lokasiLama = '';
  String? _selectedKelompok;
  String? _selectedBarang;
  String? _selectedPemilikAsal;
  String? _selectedPemilikBaru;
  String? _selectedLokasi;

  String? _inventarisId;
  String? _asalId;
  String? _baruId;
  String? _lokasiId;

  List<dynamic> _kelompokOptions = [];
  List<dynamic> _barangList = [];
  List<dynamic> _usersList = [];
  List<dynamic> _lokasiList = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    final data = widget.data;
    print("=== DATA MASUK EDIT ===");
    data.forEach((key, value) => print("$key : $value"));
    print("========================");

    _noSipandaController.text = data['nomor'] ?? '';
    _tanggalController.text = data['tanggal'] ?? '';
    _merkController.text = data['merk'] ?? '';
    _noSeriController.text = data['no_seri'] ?? '-';
    _alamatPemilikAsalController.text = data['alamat_old'] ?? '-';
    _alamatPemilikBaruController.text = data['alamat_new'] ?? '-';
    _keteranganController.text = data['ket'] ?? '';
    _lokasiLama = data['nama_lokasi'] ?? '-';

    _selectedKelompok = data['kelompok'];
    _selectedBarang =
        "${data['nama_barang'] ?? ''} || ${data['kode_barang'] ?? ''}";
    _selectedPemilikAsal = data['nama_pemilik_old'];
    _selectedPemilikBaru = data['nama_pemilik_new'];
    _selectedLokasi = data['nama_lokasi'];

    _inventarisId = data['inventaris_id']?.toString();
    _asalId = data['asal_id']?.toString();
    _baruId = data['baru_id']?.toString();
    _lokasiId = data['lokasi_baru']?.toString();

    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final jenisBarang = await PindahtanganApi.getJenisBarang();
    final users = await PindahtanganApi.getAllUsers();
    final lokasi = await PindahtanganApi.getLokasi();

    setState(() {
      _kelompokOptions = jenisBarang;
      _usersList = users["data"] ?? [];
      _lokasiList = lokasi;
    });

    // muat ulang daftar barang sesuai kelompok awal
    final selectedKelompok = _kelompokOptions.firstWhere(
      (e) => e['nama'] == _selectedKelompok,
      orElse: () => null,
    );

    if (selectedKelompok != null) {
      await _loadInventaris(int.parse(selectedKelompok['id']));
    }
  }

  Future<void> _loadInventaris(int jenisBarangId) async {
    final res = await PindahtanganApi.getInventarisByJenisBarang(jenisBarangId);
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
                  "Edit Distribusi BMN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _kelompokOptions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFrame(
                    title: "Informasi Umum",
                    children: [
                      _buildTextField(
                        "No Aduan (No SIPANDA)",
                        _noSipandaController,
                      ),
                      const SizedBox(height: 12),
                      _buildDisabledField("Tanggal", _tanggalController.text),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        "Kelompok Barang",
                        _selectedKelompok,
                        _kelompokOptions
                            .map((e) => e['nama'] as String)
                            .toList(),
                        (value) async {
                          final selected = _kelompokOptions.firstWhere(
                            (e) => e['nama'] == value,
                          );
                          final id = selected['id'];
                          setState(() {
                            _selectedKelompok = selected['nama'];
                            _selectedBarang = null;
                            _merkController.clear();
                            _noSeriController.clear();
                            _barangList = [];
                          });
                          await _loadInventaris(int.parse(id));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFrame(
                    title: "Barang yang Didistribusikan",
                    children: [
                      _buildSearchField(
                        "Nama Barang",
                        _selectedBarang,
                        _barangList
                            .map(
                              (b) =>
                                  "${b['nama_barang']} || ${b['kode_barang']}",
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
                            _inventarisId = barang['id'].toString();
                            _merkController.text = barang['merk'] ?? '-';
                            _noSeriController.text = barang['no_seri'] ?? '-';
                            _lokasiLama = barang['nama_lokasi'] ?? '-';
                            _selectedPemilikAsal =
                                "${barang['nama_penanggungjawab']} || ${barang['nip']}";
                            _asalId = barang['user_id']?.toString();
                            _alamatPemilikAsalController.text =
                                barang['alamat_penanggungjawab'] ?? '-';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDisabledField("Merk", _merkController.text),
                      const SizedBox(height: 12),
                      _buildDisabledField("No Seri", _noSeriController.text),
                      const SizedBox(height: 12),
                      _buildDisabledField("Lokasi Lama", _lokasiLama),
                      const SizedBox(height: 12),
                      _buildDisabledField(
                        "Pemilik Asal",
                        _selectedPemilikAsal ?? "-",
                      ),
                      const SizedBox(height: 12),
                      _buildDisabledField(
                        "Alamat Pemilik Asal",
                        _alamatPemilikAsalController.text,
                      ),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        "Pemilik Baru",
                        _selectedPemilikBaru,
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
                            _selectedPemilikBaru =
                                "${user['name']} || ${user['nip']}";
                            _baruId = user['id'].toString();
                            _alamatPemilikBaruController.text =
                                user['alamat'] ?? '-';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDisabledField(
                        "Alamat Pemilik Baru",
                        _alamatPemilikBaruController.text,
                      ),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        "Lokasi Baru",
                        _selectedLokasi,
                        _lokasiList.map((l) => l['nama'] as String).toList(),
                        (value) {
                          final lokasi = _lokasiList.firstWhere(
                            (l) => l['nama'] == value,
                          );
                          setState(() {
                            _selectedLokasi = value;
                            _lokasiId = lokasi['id'].toString();
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
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C4FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Perbarui",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- Helper Widgets ---
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
            overflow: TextOverflow.ellipsis,
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

  Future<void> _handleUpdate() async {
    if (_noSipandaController.text.isEmpty ||
        _inventarisId == null ||
        _asalId == null ||
        _baruId == null ||
        _lokasiId == null) {
      await showPopup(
        context,
        "Harap isi semua field wajib.",
        title: "Peringatan",
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin memperbarui data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await PindahtanganApi.updatePindahtangan(
        id: widget.data['id'].toString(),
        nomor: _noSipandaController.text,
        tanggal: _tanggalController.text,
        kelompok: _selectedKelompok ?? '',
        inventarisId: _inventarisId!,
        asalId: _asalId!,
        alamatLama: _alamatPemilikAsalController.text,
        baruId: _baruId!,
        alamatBaru: _alamatPemilikBaruController.text,
        ket: _keteranganController.text,
        lokasi: _lokasiId!,
      );

      if (result['status'] == 'success') {
        if (!mounted) return; // <- tambahkan ini
        await showPopup(context, "Data berhasil diperbarui", title: "Berhasil");
        if (!mounted) return; // <- tambahkan ini juga sebelum pop
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DistribusiBmnScreen()),
        );
      } else {
        await showPopup(
          context,
          result['message'] ?? "Gagal memperbarui data",
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
  String title = "Peringatan",
}) async {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(color: Colors.blueAccent)),
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
