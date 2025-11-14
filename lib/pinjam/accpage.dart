import 'package:flutter/material.dart';
import 'package:newapp/main.dart';
import 'package:newapp/pinjam/accdetailpage.dart';
import 'package:newapp/pinjam/acceditpage.dart';
import 'package:newapp/pinjam/dashboard.dart';
import 'package:newapp/pinjam/pinjampage.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';
import '../api/acc_api.dart';
import '../api/pengajuan_api.dart';

class AccPage extends StatefulWidget {
  const AccPage({super.key});

  @override
  State<AccPage> createState() => _AccPageState();
}

class _AccPageState extends State<AccPage> with RouteAware {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _accFuture;
  final ScrollController _scrollController = ScrollController();

  int _visibleItemCount = 10; // tampilkan 10 item awal
  bool _isLoadingMore = false;

  Future<List<Map<String, dynamic>>> _fetchData(String role, int userId) async {
    return await AccApi.getAccData(role: role, userId: userId);
  }

  Icon getStatusIcon(String status) {
    switch (status) {
      case "Y":
        return const Icon(Icons.check_circle, color: Colors.green, size: 36);
      case "N":
        return const Icon(Icons.cancel, color: Colors.red, size: 36);
      case "C":
        return const Icon(Icons.delete_forever, color: Colors.orange, size: 36);
      default:
        return const Icon(Icons.access_time, color: Colors.yellow, size: 36);
    }
  }

  void _onSearchSubmit(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  void _refreshData() {
    final user = Provider.of<UserProvider>(context, listen: false);
    final int currentUserId = int.parse(user.id);
    final String role = user.role;

    setState(() {
      _accFuture = _fetchData(role, currentUserId);
      _visibleItemCount = 10; // reset ke awal
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        _loadMore();
      }
    });
  }

  void _loadMore() {
    setState(() => _isLoadingMore = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _visibleItemCount += 10; // tambah 10 item lagi
        _isLoadingMore = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
    _setupScrollListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshData();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    final String userRole = user.role;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 100,
          title: const Text(
            "Persetujuan Peminjaman",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1E88E5),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.blueGrey, width: 1),
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Dashboard(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Text(
                          "Daftar Persetujuan Peminjaman",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // 🔹 Kolom pencarian fleksibel
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _onSearchSubmit,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: "Ketik lalu tekan Enter...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 🔹 Tombol tambah dengan tinggi sejajar
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PinjamPage()),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _accFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tidak ada data pengajuan"),
                ),
              );
            }

            final filteredData = data.where((item) {
              return item["no_pengajuan"].toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  item["nama"].toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  item["tujuan"].toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
            }).toList();

            final visibleData = filteredData.take(_visibleItemCount).toList();

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount:
                  visibleData.length +
                  (_isLoadingMore ? 1 : 0), // loader di bawah
              itemBuilder: (context, index) {
                if (index >= visibleData.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = visibleData[index];
                final bool showEditIcon =
                    (item["status"].toString().toLowerCase() == "y" &&
                    userRole == "Admin");

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final detail = await PengajuanApi.getPengajuanById(
                        int.tryParse(item["id"].toString()) ?? 0,
                      );

                      if (detail != null && context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccDetailPage(
                              data: detail,
                              status: detail["status"] ?? "P",
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ikon Status
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: switch (item["status"]) {
                                "Y" => Colors.green.withOpacity(0.1),
                                "N" => Colors.red.withOpacity(0.1),
                                "C" => Colors.orange.withOpacity(0.1),
                                _ => Colors.yellow.withOpacity(0.1),
                              },
                              shape: BoxShape.circle,
                            ),
                            child: getStatusIcon(item["status"] ?? "P"),
                          ),
                          const SizedBox(width: 14),
                          // Isi card
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["no_pengajuan"] ?? "-",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Nama  :  ${item["nama"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Tujuan :  ${item["tujuan"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Dari :  ${item["tanggal_berangkat"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Sampai :  ${item["tanggal_kembali"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (showEditIcon)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final detail =
                                      await PengajuanApi.getDetailAcc(
                                        int.tryParse(item["id"].toString()) ??
                                            0,
                                      );

                                  if (detail != null && context.mounted) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AccEditPage(data: detail),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
