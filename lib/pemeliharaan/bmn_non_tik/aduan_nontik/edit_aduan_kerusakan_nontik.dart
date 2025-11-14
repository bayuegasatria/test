import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/api/aduan_api.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';

class EditAduanKerusakanNonTik extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditAduanKerusakanNonTik({super.key, required this.data});

  @override
  State<EditAduanKerusakanNonTik> createState() =>
      _EditAduanKerusakanNonTikState();
}

class _EditAduanKerusakanNonTikState extends State<EditAduanKerusakanNonTik> {
  final dateFormat = DateFormat('yyyy-MM-dd');

  late TextEditingController tanggalController;
  late TextEditingController problemController;
  late TextEditingController analisaController;
  late TextEditingController tindakController;
  late TextEditingController hasilController;
  late TextEditingController analyzeDateController;
  late TextEditingController petugasController;
  late String userId;

  late String status = widget.data['aduan_status'];
  String? selectedPetugas;
  String? selectedLeader;
  String? selectedKelompok;
  Map<String, dynamic>? selectedBarang;

  List<Map<String, dynamic>> jenisBarangList = [];
  List<Map<String, dynamic>> inventarisList = [];

  @override
  void initState() {
    super.initState();
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

    tanggalController = TextEditingController(
      text: widget.data['tanggal']?.toString() ?? '',
    );
    problemController = TextEditingController(
      text: widget.data['problem']?.toString() ?? '',
    );
    analisaController = TextEditingController(
      text: widget.data['analisa']?.toString() ?? '',
    );
    tindakController = TextEditingController(
      text: widget.data['follow_up']?.toString() ?? '',
    );
    hasilController = TextEditingController(
      text: widget.data['result']?.toString() ?? '',
    );
    analyzeDateController = TextEditingController(
      text: _formatTanggal(widget.data['analyze_date']),
    );

    // Tentukan status dari data numerik

    selectedPetugas = widget.data['nama_petugas'];
    selectedLeader = widget.data['nama_leader'];
    selectedKelompok = widget.data['nama_kelompok'];
    selectedBarang = widget.data['nama_barang'] != null
        ? {
            'nama_barang': widget.data['nama_barang'],
            'kode_barang': widget.data['kode_barang'] ?? '-',
          }
        : null;

    _initializeDropdownData();
  }

  /// Memuat semua data jenis barang lalu isi dropdown & inventaris sesuai data awal
  Future<void> _initializeDropdownData() async {
    try {
      final jenis = await AduanApi.getJenisBarang();
      if (!mounted) return;
      setState(() => jenisBarangList = jenis);

      if (selectedKelompok != null && selectedKelompok!.isNotEmpty) {
        final selectedJenis = jenisBarangList.firstWhere(
          (e) => e['nama'] == selectedKelompok,
          orElse: () => {},
        );

        if (selectedJenis.isNotEmpty) {
          final inventaris = await AduanApi.getInventarisByJenis(
            jenisBarangId: int.parse(selectedJenis['id'].toString()),
          );
          if (!mounted) return;
          setState(() {
            inventarisList = inventaris;

            // Isi selectedBarang berdasarkan nama_barang dari widget.data
            if (widget.data['nama_barang'] != null) {
              final match = inventaris.firstWhere(
                (e) => e['nama_barang'] == widget.data['nama_barang'],
                orElse: () => {},
              );
              if (match.isNotEmpty) selectedBarang = match;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data awal: $e")));
      }
    }
  }

  @override
  void dispose() {
    tanggalController.dispose();
    problemController.dispose();
    analisaController.dispose();
    tindakController.dispose();
    hasilController.dispose();
    petugasController.dispose();
    analyzeDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final role = userProvider.role;
    final isAdmin = role == 'AdminTIK';
    if (isAdmin) {
      petugasController = TextEditingController(text: userProvider.nama);
      userId = userProvider.id;
    }
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
                  "Edit Aduan Kerusakan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Informasi Dasar"),
            _buildInfoDasar(isAdmin),
            const SizedBox(height: 24),
            _buildSectionHeader("Detail Barang & Masalah"),
            _buildBarangSection(isAdmin),
            if (isAdmin) ...[
              const SizedBox(height: 24),
              _buildSectionHeader("Analisa & Tindak Lanjut"),
              _buildAdminSection(),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirm = await _showConfirmDialog();
                  if (confirm) {
                    _saveChanges();
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C4FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    ),
  );

  Widget _buildInfoDasar(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxBorder(),
      child: Column(
        children: [
          _buildStaticField("Nomor Aduan", widget.data['no_aduan']),
          _buildDateField("Tanggal Aduan", tanggalController, isAdmin),
          _buildStaticField("Pelapor", widget.data['nama_user']),
          _buildStaticField("Bidang", widget.data['nama_divisi']),
        ],
      ),
    );
  }

  Widget _buildBarangSection(bool isAdmin) {
    final kelompokItems = jenisBarangList
        .map((e) => e['nama'].toString())
        .toList();
    final barangItems = inventarisList
        .map((e) => "${e['nama_barang']} || ${e['kode_barang'] ?? '-'}")
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxBorder(),
      child: Column(
        children: [
          _buildAdaptiveDropdown(
            label: "Kelompok Barang",
            value: selectedKelompok,
            items: kelompokItems,
            onChanged: (v) {
              if (v == null) return;
              final selected = jenisBarangList.firstWhere(
                (e) => e['nama'] == v,
                orElse: () => {},
              );
              if (selected.isNotEmpty) {
                setState(() {
                  selectedKelompok = v;
                  selectedBarang = null;
                  inventarisList.clear();
                });
                _loadInventaris(int.parse(selected['id'].toString()));
              }
            },
          ),
          const SizedBox(height: 12),
          _buildSearchField(
            "Nama Barang",
            selectedBarang == null
                ? null
                : "${selectedBarang!['nama_barang']} || ${selectedBarang!['kode_barang'] ?? '-'}",
            barangItems,
            (value) {
              if (value == null) return;
              final selected = inventarisList.firstWhere(
                (e) =>
                    "${e['nama_barang']} || ${e['kode_barang'] ?? '-'}" ==
                    value,
              );
              setState(() => selectedBarang = selected);
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            label: "Permasalahan",
            controller: problemController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxBorder(),
      child: Column(
        children: [
          _buildAdaptiveDropdown(
            label: "Status Aduan",
            value: status,
            items: const [
              "Belum Diproses",
              "Sedang Diproses",
              "Selesai Diproses",
            ],
            onChanged: (v) => setState(() => status = v ?? status),
          ),
          const SizedBox(height: 4),
          _buildInputField(label: "Petugas", controller: petugasController),
          _buildInputField(label: "Analisa", controller: analisaController),
          _buildDateField("Tanggal Analisa", analyzeDateController, true),
          _buildInputField(
            label: "Tindak Lanjut",
            controller: tindakController,
          ),
          _buildInputField(label: "Hasil", controller: hasilController),
        ],
      ),
    );
  }

  BoxDecoration _boxBorder() => BoxDecoration(
    border: Border.all(color: const Color(0xFF374151), width: 1.5),
    borderRadius: BorderRadius.circular(12),
  );

  Widget _buildStaticField(String label, dynamic value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            (value == null || value.toString().isEmpty)
                ? "-"
                : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) => Column(
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

  Widget _buildAdaptiveDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSearchField(
    String label,
    String? value,
    List<String>? items,
    Function(String?) onSelected,
  ) {
    final cleanItems = (items ?? [])
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: cleanItems.isEmpty
              ? null
              : () async {
                  final result = await showDialog<String?>(
                    context: context,
                    builder: (context) =>
                        _SearchDialog(items: cleanItems, title: label),
                  );
                  if (result != null) onSelected(result);
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
              color: cleanItems.isEmpty ? Colors.grey.shade100 : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value ??
                        (cleanItems.isEmpty
                            ? "Data $label belum tersedia"
                            : "Pilih $label"),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cleanItems.isEmpty ? Colors.black87 : Colors.black,
                    ),
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

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    bool enabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onTap: !enabled
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(controller.text) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.text = dateFormat.format(picked);
                  }
                },
        ),
      ],
    );
  }

  Future<void> _loadInventaris(int jenisBarangId) async {
    try {
      final data = await AduanApi.getInventarisByJenis(
        jenisBarangId: jenisBarangId,
      );
      if (mounted) setState(() => inventarisList = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat inventaris: $e")));
      }
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

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.role;

    try {
      // Validasi dasar
      if (problemController.text.trim().isEmpty) {
        await showPopup(context, "Permasalahan masalah belum diisi.");
        return;
      }

      // Ambil data penting untuk update
      final id = int.parse(widget.data['id'].toString());
      final inventarisId = selectedBarang?['id'] != null
          ? int.tryParse(selectedBarang!['id'].toString())
          : null;

      // Panggil API
      final res = await AduanApi.updateAduan(
        id: id,
        role: role,
        problem: problemController.text.trim(),
        aduanStatus: status,
        analisa: analisaController.text.trim(),
        followUp: tindakController.text.trim(),
        result: hasilController.text.trim(),
        analyzeDate: analyzeDateController.text.trim(),
        petugasId: int.parse(userId),
        inventarisId: inventarisId,
      );

      if (res['success'] == true) {
        await showPopup(
          context,
          "Aduan berhasil diperbarui!",
          title: "Berhasil",
        );
        if (mounted)
          Navigator.pop(context, true); // ⬅ kembali ke halaman sebelumnya
      } else {
        await showPopup(
          context,
          res['message'] ?? "Gagal memperbarui aduan.",
          title: "Gagal",
        );
        if (mounted) Navigator.pop(context, false);
      }
    } catch (e) {
      await showPopup(context, "Terjadi kesalahan: $e", title: "Error");
      if (mounted) Navigator.pop(context, false);
    }
  }
}

class _SearchDialog extends StatefulWidget {
  final List<String> items;
  final String title;
  const _SearchDialog({required this.items, required this.title});

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late List<String> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController.addListener(_filterItems);
  }

  void _filterItems() {
    setState(() {
      filteredItems = widget.items
          .where(
            (e) =>
                e.toLowerCase().contains(searchController.text.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Cari ${widget.title}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Ketik untuk mencari...",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tutup"),
        ),
      ],
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
