import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/api/aduan_tik_api.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';

class EditAduanKerusakanTIK extends StatefulWidget {
  final Map<String, dynamic> aduanData;

  const EditAduanKerusakanTIK({super.key, required this.aduanData});

  @override
  State<EditAduanKerusakanTIK> createState() => _EditAduanKerusakanTIKState();
}

class _EditAduanKerusakanTIKState extends State<EditAduanKerusakanTIK> {
  final _formKey = GlobalKey<FormState>();
  late int? adminid;
  final TextEditingController _analisaController = TextEditingController();
  final TextEditingController _tindakController = TextEditingController();
  final TextEditingController _hasilController = TextEditingController();
  final TextEditingController _tanggalAnalisaController =
      TextEditingController();
  final TextEditingController _tanggalTindakController =
      TextEditingController();
  final TextEditingController _tanggalHasilController = TextEditingController();
  final TextEditingController _pemeriksaController = TextEditingController();

  // Field barang
  String? _selectedJenisTIK;
  String? _selectedAsset;
  Map<String, dynamic>? _selectedAssetInfo;
  List<Map<String, dynamic>> jenisTikList = [];
  List<Map<String, dynamic>> itAssetList = [];
  final TextEditingController _masalahController = TextEditingController();

  String? _selectedStatus;
  bool isAdmin = false;
  bool canEditBarang = false;

  @override
  void initState() {
    super.initState();
    _initDataFromWidget();
    _loadJenisTikAndAsset();
  }

  void _initDataFromWidget() {
    String _formatTanggal(dynamic value) {
      if (value == null || value.toString().isEmpty) return '';
      try {
        // Jika string-nya 0000-00-00 atau invalid date → kembalikan kosong
        if (value.toString().startsWith('0000')) return '';
        final date = DateTime.tryParse(value.toString());
        if (date == null) return '';
        return DateFormat('yyyy-MM-dd').format(date);
      } catch (_) {
        return '';
      }
    }

    final data = widget.aduanData;
    _selectedStatus = data['status']?.toString() ?? 'Belum Diproses';
    _selectedJenisTIK = data['jenis_barang'];
    _selectedAsset = data['nama_barang'];
    _pemeriksaController.text = data['pemeriksa'] ?? '';
    _analisaController.text = data['analisa'] ?? '';
    _tindakController.text = data['follow_up'] ?? '';
    _hasilController.text = data['result'] ?? '';
    _tanggalAnalisaController.text = _formatTanggal(data['analyze_date']);
    _tanggalTindakController.text = _formatTanggal(data['followup_date']);
    _tanggalHasilController.text = _formatTanggal(data['result_date']);
    _masalahController.text = data['trouble'] ?? '';

    // barang TIK
  }

  Future<void> _loadJenisTikAndAsset() async {
    try {
      final jenisData = await AduanTikApi.getJenisTik();
      if (!mounted) return;

      setState(() {
        jenisTikList = jenisData;
      });

      // cari jenis berdasarkan nama dari aduanData
      final jenisSelected = jenisData.firstWhere(
        (e) => e['kelompok'] == widget.aduanData['nama_kelompok'],
        orElse: () => {},
      );

      if (jenisSelected.isNotEmpty) {
        _selectedJenisTIK = jenisSelected['kelompok'];
        final jenisId = int.tryParse(jenisSelected['id'].toString());
        if (jenisId != null) {
          final asetData = await AduanTikApi.getItAssetByJenisTIK(jenisId);
          if (!mounted) return;

          setState(() {
            itAssetList = asetData;
          });

          // cari aset sesuai nama barang
          final asetSelected = asetData.firstWhere(
            (e) => e['nama_barang'] == widget.aduanData['nama_barang'],
            orElse: () => {},
          );

          if (asetSelected.isNotEmpty) {
            setState(() {
              _selectedAsset = asetSelected['nama_barang'];
              _selectedAssetInfo = asetSelected;
            });
          }
        }
      }
    } catch (e) {
      await showPopup(context, "Gagal memuat data TIK: $e");
    }
  }

  Future<void> _loadItAsset(int jenistikId) async {
    try {
      final data = await AduanTikApi.getItAssetByJenisTIK(jenistikId);
      if (mounted) {
        setState(() {
          itAssetList = data;
          _selectedAsset = null;
          _selectedAssetInfo = null;
        });
      }
    } catch (e) {
      await showPopup(context, "Gagal memuat data aset: $e");
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _confirmDialog(
        title: "Konfirmasi",
        message: "Apakah Anda yakin ingin menyimpan perubahan data aduan ini?",
        confirmColor: Colors.green,
        confirmText: "Ya, Simpan",
      ),
    );
    return result ?? false;
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

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Provider.of<UserProvider>(context, listen: false);
    final id = widget.aduanData['id'];

    try {
      final response = await AduanTikApi.updateAduanTik(
        id: int.parse(id),
        role: user.role,
        trouble: _masalahController.text,
        status: _selectedStatus,
        analisa: _analisaController.text.trim(),
        followUp: _tindakController.text.trim(),
        result: _hasilController.text.trim(),
        analyzeDate: _tanggalAnalisaController.text,
        followupDate: _tanggalTindakController.text,
        resultDate: _tanggalHasilController.text,
        petugasId: adminid,
        itassetId: _selectedAssetInfo?['id'],
      );

      if (response['success'] == true) {
        await showPopup(
          context,
          "Perubahan berhasil disimpan",
          title: "Berhasil",
        );
        Navigator.pop(context, true);
      } else {
        await showPopup(
          context,
          response['message'] ?? "Gagal menyimpan perubahan",
        );
      }
    } catch (e) {
      await showPopup(context, "Gagal menyimpan perubahan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    isAdmin = user.role == "AdminTIK";
    canEditBarang = isAdmin || (_selectedStatus == "Belum Diproses");

    if (isAdmin && _pemeriksaController.text.isEmpty) {
      _pemeriksaController.text = user.nama;
      adminid = int.parse(user.id);
    }

    final data = widget.aduanData;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 91,
        title: const Text(
          "Edit Aduan TIK",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.blueGrey)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Edit Aduan Kerusakan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _frame("Informasi Aduan", [
                _staticField("Nomor Aduan", data['no_aduan'] ?? '-'),
                const SizedBox(height: 12),
                _staticField("Tanggal Aduan", data['tanggal'] ?? '-'),
                const SizedBox(height: 12),
                _staticField("Nama Pengadu", data['nama_user'] ?? '-'),
                const SizedBox(height: 12),
                _staticField("Bidang", data['nama_divisi'] ?? '-'),
              ]),
              const SizedBox(height: 16),
              _frame("Barang TIK yang Diadukan", [
                _searchField(
                  "Jenis Barang TIK",
                  _selectedJenisTIK,
                  jenisTikList.map((e) => e['kelompok'] as String).toList(),
                  (value) {
                    if (!canEditBarang) return;
                    final selected = jenisTikList.firstWhere(
                      (e) => e['kelompok'] == value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty) {
                      setState(() {
                        _selectedJenisTIK = selected['kelompok'];
                      });
                      _loadItAsset(int.parse(selected['id'].toString()));
                    }
                  },
                  enabled: canEditBarang,
                ),
                const SizedBox(height: 12),
                _searchField(
                  "Pilih Aset TIK",
                  _selectedAsset,
                  itAssetList.map((e) => e['nama_barang'] as String).toList(),
                  (value) {
                    if (!canEditBarang) return;
                    final selected = itAssetList.firstWhere(
                      (e) => e['nama_barang'] == value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty) {
                      setState(() {
                        _selectedAsset = selected['nama_barang'];
                        _selectedAssetInfo = selected;
                      });
                    }
                  },
                  enabled: canEditBarang,
                ),
                const SizedBox(height: 12),
                _staticField(
                  "Lokasi",
                  _selectedAssetInfo?['lokasi'] ?? data['lokasi'] ?? '-',
                ),
                const SizedBox(height: 12),
                _staticField(
                  "Penanggung Jawab",
                  _selectedAssetInfo?['nama_pengguna'] ?? '-',
                ),
                const SizedBox(height: 12),
                _textArea(
                  "Masalah / Trouble",
                  _masalahController,
                  enabled: canEditBarang,
                ),
              ]),
              if (isAdmin) ...[
                const SizedBox(height: 24),
                _frame("Analisa & Tindak Lanjut", [
                  _dropdownField(
                    "Status",
                    _selectedStatus,
                    const [
                      {"value": "Belum Diproses", "label": "Belum Diproses"},
                      {"value": "Sedang Diproses", "label": "Sedang Diproses"},
                      {
                        "value": "Selesai Diproses",
                        "label": "Selesai Diproses",
                      },
                    ],
                    (v) => setState(() => _selectedStatus = v),
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    "Pemeriksa",
                    _pemeriksaController,
                    enabled: isAdmin,
                  ),
                  const SizedBox(height: 12),
                  _dateField("Tanggal Analisa", _tanggalAnalisaController),
                  _textArea("Analisa", _analisaController),
                  const SizedBox(height: 12),
                  _dateField("Tanggal Tindak Lanjut", _tanggalTindakController),
                  _textArea("Tindak Lanjut", _tindakController),
                  const SizedBox(height: 12),
                  _dateField("Tanggal Hasil", _tanggalHasilController),
                  _textArea("Hasil", _hasilController),
                ]),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await _showConfirmDialog();
                    if (confirm) {
                      _simpanPerubahan();
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C4FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  // === Widget helper ===

  Widget _frame(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _staticField(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(value),
      ),
    ],
  );

  Widget _dropdownField(
    String label,
    String? value,
    List<Map<String, String>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e['value'],
                  child: Text(e['label']!),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _textField(
    String label,
    TextEditingController c, {
    bool enabled = true,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      TextFormField(
        controller: c,
        enabled: enabled,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    ],
  );

  Widget _textArea(
    String label,
    TextEditingController c, {
    bool enabled = true,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      TextFormField(
        controller: c,
        enabled: enabled,
        maxLines: 3,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    ],
  );

  Widget _dateField(String label, TextEditingController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(controller),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
      ),
    ],
  );

  Widget _searchField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onSelected, {
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: !enabled
          ? null
          : () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) => _SearchDialog(items: items, title: label),
              );
              if (result != null) onSelected(result);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.white : Colors.grey[100],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? "Pilih $label",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (enabled) const Icon(Icons.search),
          ],
        ),
      ),
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
              onChanged: (v) => setState(() => query = v),
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
              itemBuilder: (c, i) => ListTile(
                title: Text(filtered[i]),
                onTap: () => Navigator.pop(context, filtered[i]),
              ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
