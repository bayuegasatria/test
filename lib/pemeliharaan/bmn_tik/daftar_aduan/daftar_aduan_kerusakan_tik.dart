import 'package:flutter/material.dart';
import 'package:newapp/api/aduan_tik_api.dart';
import 'package:newapp/pinjam/dashboard_maintenance.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:newapp/pinjam/widgets/status_badge_aduan.dart';
import 'package:provider/provider.dart';
import 'cetak_aduan_tik.dart';
import 'tambah_aduan_kerusakan_tik.dart';
import 'edit_aduan_kerusakan_tik.dart';
import 'detail_aduan_kerusakan_tik.dart';

class DaftarAduanKerusakanTIKScreen extends StatefulWidget {
  const DaftarAduanKerusakanTIKScreen({super.key});

  @override
  State<DaftarAduanKerusakanTIKScreen> createState() =>
      _DaftarAduanKerusakanTIKScreenState();
}

class _DaftarAduanKerusakanTIKScreenState
    extends State<DaftarAduanKerusakanTIKScreen> {
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
      final userId = int.parse(userProvider.id);
      final divisi = int.parse(userProvider.divId);

      final data = await AduanTikApi.getAduanTIKData(
        role: role,
        userId: userId,
        divisi: divisi,
      );

      setState(() {
        daftarAduan = data;
        currentPage = 1;
      });
    } catch (e) {
      debugPrint("Error: $e");
      await showPopup(context, "Gagal memuat data: $e", title: "Kesalahan");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _paginatedData {
    final filtered = daftarAduan.where((aduan) {
      final q = searchQuery.toLowerCase();
      return (aduan["no_aduan"] ?? "").toLowerCase().contains(q) ||
          (aduan["nama_user"] ?? "").toLowerCase().contains(q) ||
          (aduan["status"].toString()).toLowerCase().contains(q) ||
          (aduan["nama_barang"] ?? aduan["namaBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(q) ||
          (aduan["kode_barang"] ?? aduan["kodeBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(q);
    }).toList();

    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  int get _totalPages {
    final filtered = daftarAduan.where((aduan) {
      final q = searchQuery.toLowerCase();
      return (aduan["no_aduan"] ?? "").toLowerCase().contains(q) ||
          (aduan["nama_user"] ?? "").toLowerCase().contains(q) ||
          (aduan["status"]).toLowerCase().contains(q) ||
          (aduan["nama_barang"] ?? aduan["namaBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(q) ||
          (aduan["kode_barang"] ?? aduan["kodeBarang"] ?? "")
              .toString()
              .toLowerCase()
              .contains(q);
    }).toList();
    return (filtered.length / itemsPerPage).ceil();
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
                // 🔍 Search dan Tambah
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              searchQuery = val;
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
                                  const TambahAduanKerusakanTIK(),
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

                // 🧾 List Aduan
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
                            final status = aduan["status"];

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
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailAduanTik(aduan: aduan),
                                    ),
                                  );
                                  await _loadAduanData();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StatusBadgeAduan(status: status),
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
                                                await cetakAduanTik(
                                                  aduan,
                                                ); // ← Kirim full data
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
                                                        EditAduanKerusakanTIK(
                                                          aduanData: aduan,
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
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text(
                                                      "Hapus Aduan",
                                                    ),
                                                    content: const Text(
                                                      "Yakin ingin menghapus aduan ini?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx),
                                                        child: const Text(
                                                          "Batal",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                        onPressed: () async {
                                                          Navigator.pop(ctx);
                                                          final success =
                                                              await AduanTikApi.softDeleteAduanTIK(
                                                                int.parse(
                                                                  aduan['id']
                                                                      .toString(),
                                                                ),
                                                              );

                                                          if (success) {
                                                            await showPopup(
                                                              context,
                                                              "Data berhasil dihapus",
                                                              title: "Sukses",
                                                            );
                                                            await _loadAduanData();
                                                          } else {
                                                            await showPopup(
                                                              context,
                                                              "Gagal menghapus data",
                                                              title:
                                                                  "Kesalahan",
                                                            );
                                                          }
                                                        },
                                                        child: const Text(
                                                          "Hapus",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
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

                // 📄 Pagination
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
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
                                    "$page",
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

/// Popup dialog pengganti snackbar
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
