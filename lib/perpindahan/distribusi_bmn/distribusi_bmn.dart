import 'package:flutter/material.dart';
import 'package:newapp/api/pindahtangan_api.dart';
import 'package:newapp/perpindahan/dashboard_perpindahan.dart';
import 'tambah_distribusi_bmn.dart';
import 'edit_distribusi_bmn.dart';
import 'detail_bmn.dart';
import 'cetak_bmn.dart';

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

class DistribusiBmnScreen extends StatefulWidget {
  const DistribusiBmnScreen({super.key});

  @override
  State<DistribusiBmnScreen> createState() => _DistribusiBmnScreenState();
}

class _DistribusiBmnScreenState extends State<DistribusiBmnScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _dataDistribusi = [];

  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromApi();
  }

  Future<void> _loadDataFromApi() async {
    setState(() => _isLoading = true);

    final response = await PindahtanganApi.getAllPindahtangan();
    if (response['status'] == 'success' && response['data'] != null) {
      setState(() {
        _dataDistribusi = List<Map<String, dynamic>>.from(response['data']);
      });
    } else {
      await showPopup(
        context,
        "Gagal mengambil data: ${response['message'] ?? 'Tidak diketahui'}",
      );
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredData {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _dataDistribusi;
    return _dataDistribusi.where((item) {
      return (item['nomor'] ?? '').toLowerCase().contains(query) ||
          (item['nama_barang'] ?? '').toLowerCase().contains(query) ||
          (item['nama_pemilik_old'] ?? '').toLowerCase().contains(query) ||
          (item['nama_pemilik_new'] ?? '').toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _pagedData {
    final filtered = _filteredData;
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  int get _totalPages => (_filteredData.length / _itemsPerPage).ceil();

  Future<void> _konfirmasiHapus(int index) async {
    final item = _pagedData[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text('Yakin ingin menghapus data "${item['nomor'] ?? '-'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final globalIndex = (_currentPage - 1) * _itemsPerPage + index;
      setState(() {
        _dataDistribusi.removeAt(globalIndex);
      });
      await showPopup(context, "✅ Data berhasil dihapus", title: "Berhasil");
    }
  }

  @override
  Widget build(BuildContext context) {
    final paged = _pagedData;
    final totalPages = _totalPages;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: const Text(
          "Sistem Perpindahan BMN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPerpindahan(),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Daftar Pindah Tangan BMN",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Search dan Tombol Tambah
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() => _currentPage = 1),
                          decoration: InputDecoration(
                            hintText: "Cari nomor BA, barang, pemilik...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TambahDistribusiBmnScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Tambah",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 📄 Daftar data
                Expanded(
                  child: paged.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "Belum ada data pindahtangan",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: paged.length,
                          itemBuilder: (context, index) {
                            final item = paged[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailBmn(data: item),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nomor BA: ${item['nomor'] ?? '-'}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        "Nama Barang: ${item['nama_barang'] ?? '-'}",
                                      ),
                                      Text(
                                        "Dari: ${item['nama_pemilik_old'] ?? '-'} → ${item['nama_pemilik_new'] ?? '-'}",
                                      ),
                                      Text(
                                        "Tanggal: ${item['tanggal'] ?? '-'}",
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              await cetakBmn(item);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purple,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              "Print",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () async {
                                              await Navigator.push<
                                                Map<String, dynamic>?
                                              >(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditDistribusiBmnScreen(
                                                        data: item,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _konfirmasiHapus(index),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // 🔢 Pagination
                if (totalPages > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        ...List.generate(totalPages, (i) {
                          final page = i + 1;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _currentPage = page),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: page == _currentPage
                                      ? const Color(0xFF00C4FF)
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$page',
                                    style: TextStyle(
                                      color: page == _currentPage
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
