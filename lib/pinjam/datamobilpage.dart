import 'package:flutter/material.dart';
import 'package:newapp/pinjam/dashboard_bmn.dart';
import 'package:newapp/pinjam/detailmobilpage.dart';
import '../api/mobil_api.dart';

class DataMobilPage extends StatefulWidget {
  const DataMobilPage({super.key});

  @override
  State<DataMobilPage> createState() => _DataMobilPageState();
}

class _DataMobilPageState extends State<DataMobilPage> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  Future<List<Map<String, dynamic>>>? _mobilFuture;

  @override
  void initState() {
    super.initState();
    _mobilFuture = MobilApi.getMobilWithStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          toolbarHeight: 91,
          automaticallyImplyLeading: false,
          title: const Text(
            "Data Kendaraan",
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
                              builder: (_) => const DashboardBmn(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "List Kendaraan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearchSubmit,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Ketik lalu tekan Enter...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawerScrimColor: Colors.white,
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _mobilFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada data kendaraan"));
            }

            final kendaraanList = snapshot.data!;
            final filteredKendaraan = kendaraanList.where((kendaraan) {
              return kendaraan["merk"].toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  kendaraan["nomor_inventaris"]
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: filteredKendaraan.length,
              itemBuilder: (context, index) {
                final kendaraan = filteredKendaraan[index];
                final status = kendaraan["status"] ?? "";
                final type = kendaraan["tipe"] ?? "";

                Color statusColor;
                switch (status) {
                  case "Ready":
                    statusColor = Colors.green;
                    break;
                  case "Dipakai":
                    statusColor = Colors.orange;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                String iconPath = type == "M"
                    ? 'assets/icons/bike.png'
                    : 'assets/icons/car.png';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(iconPath, fit: BoxFit.contain),
                      ),
                    ),
                    title: Text(
                      kendaraan["merk"] ?? "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No. Inventaris: ${kendaraan["nomor_inventaris"] ?? '-'}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            "DA: ${kendaraan["da"] ?? '-'}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          Row(
                            children: [
                              const Text(
                                "Status: ",
                                style: TextStyle(fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailMobilPage(mobilData: kendaraan),
                        ),
                      );
                    },
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
