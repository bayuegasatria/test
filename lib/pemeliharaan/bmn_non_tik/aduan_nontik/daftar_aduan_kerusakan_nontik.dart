import 'package:flutter/material.dart';
import 'package:newapp/api/aduan_api.dart';
import 'package:newapp/pinjam/dashboard_maintenance.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:newapp/pinjam/widgets/status_badge_aduan.dart';
import 'package:provider/provider.dart';
import 'tambah_aduan_kerusakan_nontik.dart';
import 'edit_aduan_kerusakan_nontik.dart';
import 'detail_aduan_kerusakan_nontik.dart';
import 'cetak_aduan.dart';

// ✅ Tambahkan fungsi popup di atas (bisa juga import dari helper)
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

class DaftarAduanPemeliharaanScreen extends StatefulWidget {
  const DaftarAduanPemeliharaanScreen({super.key});

  @override
  State<DaftarAduanPemeliharaanScreen> createState() =>
      _DaftarAduanPemeliharaanScreenState();
}

class _DaftarAduanPemeliharaanScreenState
    extends State<DaftarAduanPemeliharaanScreen> {
  List<Map<String, dynamic>> daftarAduan = [];
  String searchQuery = "";
  int currentPage = 1;
  static const int itemsPerPage = 10;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAduanData();
  }

  Future<void> _loadAduanData() async {
    setState(() => isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final role = userProvider.role;
      final userId = userProvider.id;
      final divisi = userProvider.divId;

      final data = await AduanApi.getAduanData(
        role: role,
        userId: int.parse(userId),
        divisi: int.parse(divisi),
      );

      setState(() {
        daftarAduan = data;
        currentPage = 1;
      });
    } catch (e) {
      debugPrint("Error: $e");
      await showPopup(context, "Gagal memuat data: $e", title: "Error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _paginatedData {
    final filtered = daftarAduan.where((aduan) {
      final query = searchQuery.toLowerCase();
      return (aduan["no_aduan"] ?? "").toLowerCase().contains(query) ||
          (aduan["nama_user"] ?? "").toLowerCase().contains(query) ||
          (aduan["aduan_status"].toString()).toLowerCase().contains(query) ||
          (aduan["nama_barang"] ?? aduan["namaBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(query) ||
          (aduan["kode_barang"] ?? aduan["kodeBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(query);
    }).toList();

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  int get _totalPages {
    final filtered = daftarAduan.where((aduan) {
      final query = searchQuery.toLowerCase();
      return (aduan["no_aduan"] ?? "").toLowerCase().contains(query) ||
          (aduan["nama_user"] ?? "").toLowerCase().contains(query) ||
          (aduan["aduan_status"].toString()).toLowerCase().contains(query) ||
          (aduan["nama_barang"] ?? aduan["namaBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(query) ||
          (aduan["kode_barang"] ?? aduan["kodeBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(query);
    }).toList();
    return (filtered.length / itemsPerPage).ceil();
  }

  String _statusText(String? status) {
    switch (status) {
      case "Selesai Diproses":
        return "Selesai Diproses";
      case "Sedang Diproses":
        return "Sedang Diproses";
      default:
        return "Belum Diproses";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final role = userProvider.role;
    final paginatedData = _paginatedData;
    final totalPages = _totalPages;

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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardMaintenance(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Daftar Aduan Kerusakan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Search dan tambah aduan
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              currentPage = 1;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Cari nomor, pelapor, status...",
                            hintStyle: const TextStyle(fontSize: 12),
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
                          final hasil = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TambahAduanKerusakanNonTik(),
                            ),
                          );
                          if (hasil != null && mounted) {
                            await _loadAduanData();
                          }
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
                Expanded(
                  child: paginatedData.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "Tidak ada data ditemukan",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: paginatedData.length,
                          itemBuilder: (context, index) {
                            final aduan = paginatedData[index];
                            final status =
                                aduan["aduan_status"] ?? "Belum Diproses";

                            final isAdmin = role == "AdminTIK";
                            final bolehEdit =
                                isAdmin || status == "Belum Diproses";

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              child: InkWell(
                                onTap: () async {
                                  final updated =
                                      await Navigator.push<
                                        Map<String, String>?
                                      >(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailAduanKerusakanNonTIK(
                                                aduan: aduan,
                                              ),
                                        ),
                                      );

                                  if (updated != null && mounted) {
                                    final index = daftarAduan.indexWhere(
                                      (e) =>
                                          e["no_aduan"] == updated["no_aduan"],
                                    );
                                    if (index != -1) {
                                      setState(() {
                                        daftarAduan[index] = updated;
                                      });
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StatusBadgeAduan(
                                        status: _statusText(status),
                                      ),
                                      const SizedBox(height: 10),

                                      Text(
                                        "Nomor Aduan : ${aduan["no_aduan"] ?? "-"}",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        "Tanggal : ${aduan["tanggal"] ?? "-"}",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        "Pelapor : ${aduan["nama_user"] ?? "-"}",
                                        style: const TextStyle(fontSize: 15),
                                      ),

                                      // ✅ Tambahan — Nama Barang & Kode Barang dipisah
                                      Text(
                                        "Nama Barang : ${aduan["nama_barang"] ?? aduan["namaBarang"] ?? "-"}",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        "Kode Barang : ${aduan["kode_barang"] ?? aduan["kodeBarang"] ?? "-"}",
                                        style: const TextStyle(fontSize: 15),
                                      ),

                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          ElevatedButton(
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
                                            onPressed: () async {
                                              try {
                                                await cetakAduan(aduan);
                                                await showPopup(
                                                  context,
                                                  "✅ PDF berhasil dibuat",
                                                  title: "Berhasil",
                                                );
                                              } catch (e) {
                                                await showPopup(
                                                  context,
                                                  "Gagal mencetak PDF: $e",
                                                  title: "Error",
                                                );
                                              }
                                            },
                                            child: const Text(
                                              "Print",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (bolehEdit) ...[
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditAduanKerusakanNonTik(
                                                          data: aduan,
                                                        ),
                                                  ),
                                                );
                                                await _loadAduanData();
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                // kode hapus seperti semula
                                              },
                                            ),
                                          ],
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
                if (totalPages > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: currentPage > 1
                              ? () => setState(() => currentPage--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        ...List.generate(totalPages, (i) {
                          final page = i + 1;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => setState(() => currentPage = page),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: page == currentPage
                                      ? const Color(0xFF00C4FF)
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$page',
                                    style: TextStyle(
                                      color: page == currentPage
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
                          onPressed: currentPage < totalPages
                              ? () => setState(() => currentPage++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
