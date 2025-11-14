import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/api/pindahtangan_api.dart';

class EditPerpindahanDBR extends StatefulWidget {
  final Map<String, dynamic> item;
  const EditPerpindahanDBR({super.key, required this.item});

  @override
  State<EditPerpindahanDBR> createState() => _EditPerpindahanDBRState();
}

class _EditPerpindahanDBRState extends State<EditPerpindahanDBR> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _noAduanController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _ruanganLamaController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

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

  late int _pelaporid;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initFormData();
  }

  void _initFormData() {
    _pelaporid = widget.item['pelapor_id'] ?? '';
    _namaController.text = widget.item['nama_pelapor'] ?? '';
    _noAduanController.text = widget.item['no'] ?? '';
    _tanggalController.text = widget.item['tanggal'] ?? '';
    _keteranganController.text = widget.item['keterangan'] ?? '';
    _merkController.text = widget.item['merk'] ?? '';
    _ruanganLamaController.text = widget.item['nama_lokasi_lama'] ?? '';
    _ruanganLamaId = widget.item['old_lokasi'].toString();
    _ruanganBaruId = widget.item['new_lokasi'].toString();
    _barangId = widget.item['inventaris_id'].toString();
    _selectedRuanganBaru = widget.item['nama_lokasi_baru'] ?? '';
    _selectedBarang = widget.item['nama_barang'] ?? '';
    _selectedJenisBarang = widget.item['jenis_barang'] ?? '';
  }

  Future<void> _loadInitialData() async {
    final jenisBarang = await PindahtanganApi.getJenisBarang();
    final lokasi = await PindahtanganApi.getLokasi();

    setState(() {
      _jenisBarangList = jenisBarang;
      _ruanganList = lokasi;
    });
  }

  Future<void> _loadBarangByJenis(int jenisId) async {
    final res = await PindahtanganApi.getInventarisByJenisBarang(jenisId);
    setState(() {
      _barangList = res["data"] ?? [];
    });
  }

  Future<void> _updatePerpindahan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final response = await PindahtanganApi.updatePerpindahanDBR(
        id: widget.item['id'].toString(),
        nomor: _noAduanController.text,
        tanggal: _tanggalController.text,
        pelaporid: _pelaporid.toString(),
        barangId: _barangId,
        ruanganLamaId: _ruanganLamaId,
        ruanganBaruId: _ruanganBaruId,
        keterangan: _keteranganController.text,
      );

      setState(() => _loading = false);

      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Data berhasil diperbarui")),
          );
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Gagal memperbarui data: ${response['message']}"),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 91,
        title: const Text(
          "Edit Perpindahan DBR",
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
                  "Ubah Data Perpindahan DBR",
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
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFrame(
                      title: "Informasi Umum",
                      children: [
                        _buildDisabledField(
                          "No Perpindahan",
                          _noAduanController.text,
                        ),
                        const SizedBox(height: 12),
                        _buildDatePicker("Tanggal", _tanggalController),
                        const SizedBox(height: 12),
                        _buildDisabledField(
                          "Nama Pelapor",
                          _namaController.text,
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
                              .map((j) => j['nama'] as String)
                              .toList(),
                          (value) {
                            final jenis = _jenisBarangList.firstWhere(
                              (j) => j['nama'] == value,
                            );
                            setState(() {
                              _selectedJenisBarang = value;
                              _jenisId = jenis['id'].toString();
                              _selectedBarang = null;
                              _barangList = [];
                            });
                            _loadBarangByJenis(int.parse(_jenisId!));
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSearchField(
                          "Nama Barang",
                          _selectedBarang,
                          _barangList
                              .map((b) => b['nama_barang'] as String)
                              .toList(),
                          (value) {
                            final barang = _barangList.firstWhere(
                              (b) => b['nama_barang'] == value,
                            );
                            setState(() {
                              _selectedBarang = value;
                              _barangId = barang['id'].toString();
                              _merkController.text = barang['merk'] ?? '';
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
                        onPressed: _loading ? null : _updatePerpindahan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C4FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Simpan Perubahan",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
            isDense: true,
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(picked);
            }
          },
        ),
      ],
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
