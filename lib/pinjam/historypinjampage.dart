import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/pinjam/dashboard_bmn.dart';
import 'package:newapp/pinjam/detailpinjampage.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:newapp/api/pinjam_api.dart';

class HistoryPinjamPage extends StatefulWidget {
  const HistoryPinjamPage({super.key});

  @override
  State<HistoryPinjamPage> createState() => _HistoryPinjamPageState();
}

class _HistoryPinjamPageState extends State<HistoryPinjamPage> {
  late Future<List<Map<String, dynamic>>> futureHistory;
  final DateFormat dateFormat = DateFormat("dd MMM yyyy, HH:mm");

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final user = Provider.of<UserProvider>(context, listen: false);
    final int currentUserId = int.tryParse(user.id) ?? 0;

    setState(() {
      futureHistory = PinjamApi.getHistoryPinjam(userId: currentUserId);
    });
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
        return Colors.green.shade600;
      case 'batal':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        toolbarHeight: 91,
        automaticallyImplyLeading: false,
        title: const Text(
          "History Peminjaman",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
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
                      "History Peminjaman",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawerScrimColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Tidak ada history peminjaman.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            );
          }

          final selesaiHistory = snapshot.data!;
          return ListView.builder(
            itemCount: selesaiHistory.length,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            itemBuilder: (context, index) {
              final item = selesaiHistory[index];
              final statusColor = _getStatusColor(item["status"]);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blueGrey, width: 0.5),
                ),
                elevation: 3,
                shadowColor: Colors.black26,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Detailpinjampage(idPinjam: item["id_pinjam"]),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            color: statusColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item["no_pengajuan"] ?? "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: statusColor),
                                    ),
                                    child: Text(
                                      (item["status"] ?? "-").toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Nama Peminjam: ${item["nama_user"] ?? "-"}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                "Tujuan: ${item["tujuan"] ?? "-"}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (item["tanggal_pengembalian"] != null)
                                Text(
                                  "Tanggal Pengembalian: ${dateFormat.format(DateTime.parse(item["tanggal_pengembalian"]))}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                            ],
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
    );
  }
}
