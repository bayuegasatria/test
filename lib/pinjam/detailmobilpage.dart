import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newapp/api/mobil_api.dart';
import 'package:newapp/api/pinjam_api.dart';
import 'package:newapp/pinjam/detailpinjampage.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:provider/provider.dart';

class DetailMobilPage extends StatefulWidget {
  final Map<String, dynamic> mobilData;

  const DetailMobilPage({super.key, required this.mobilData});

  @override
  State<DetailMobilPage> createState() => _DetailMobilPageState();
}

class _DetailMobilPageState extends State<DetailMobilPage> {
  late Future<List<Map<String, dynamic>>> futureHistory;
  late Future<List<Map<String, dynamic>>> futureJadwal;
  final DateFormat dateFormat = DateFormat("dd MMM yyyy, HH:mm");

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = Provider.of<UserProvider>(context, listen: false);
    final now = DateTime.now();

    setState(() {
      futureHistory = PinjamApi.getHistoryPinjamMobil(
        carId: widget.mobilData["id"],
        userId: int.parse(user.id),
        role: user.role,
      );
      futureJadwal = MobilApi.getJadwalMobilId(now, widget.mobilData["id"]);
    });
  }

  DateTime? parseTanggal(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(raw, true);
      } catch (_) {
        return null;
      }
    }
  }

  Color getColorForDay(String dayName) {
    final hari = dayName.toLowerCase();
    if (['sabtu', 'minggu'].contains(hari)) {
      return Colors.orange.shade50;
    } else if (hari == 'jumat') {
      return Colors.green.shade50;
    } else {
      return Colors.blue.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobil = widget.mobilData;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 91,
        automaticallyImplyLeading: false,
        title: const Text(
          "Data Kendaraan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Detail Kendaraan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Info Mobil
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Center(
                        child: Text(
                          mobil["merk"] ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nomor Inventaris: ${mobil["nomor_inventaris"] ?? "-"}",
                          ),
                          Text("Nomor Polisi: ${mobil["da"] ?? "-"}"),
                          Text("Status: ${mobil["status"] ?? "-"}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Jadwal Mobil
            const Center(
              child: Text(
                "Jadwal Kedaraan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: futureJadwal,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Tidak ada jadwal mobil."),
                    ),
                  );
                }

                final timeFormat = DateFormat("HH:mm");
                final dayFormat = DateFormat("EEEE", 'id_ID');
                final shortDate = DateFormat("dd MMM", 'id_ID');

                // 🔹 Parse tanggal aman
                DateTime? parseTanggal(String? raw) {
                  if (raw == null || raw.isEmpty) return null;
                  try {
                    return DateTime.parse(raw);
                  } catch (_) {
                    try {
                      return DateFormat("yyyy-MM-dd HH:mm:ss").parse(raw, true);
                    } catch (_) {
                      return null;
                    }
                  }
                }

                // 🔹 Group berdasarkan tanggal aktif
                final Map<DateTime, List<Map<String, dynamic>>> grouped = {};

                for (var item in data) {
                  final tglBerangkat = parseTanggal(item['tanggal_berangkat']);
                  final tglKembali = parseTanggal(item['tanggal_kembali']);
                  if (tglBerangkat == null) continue;
                  final tglEnd = tglKembali ?? tglBerangkat;

                  // 🔹 Buat rentang semua hari yang dilewati mobil
                  DateTime current = DateTime(
                    tglBerangkat.year,
                    tglBerangkat.month,
                    tglBerangkat.day,
                  );
                  while (!current.isAfter(
                    DateTime(tglEnd.year, tglEnd.month, tglEnd.day),
                  )) {
                    grouped[current] ??= [];

                    // 🔹 Jika tanggal berangkat & kembali di hari yang sama
                    if (DateUtils.isSameDay(tglBerangkat, tglEnd)) {
                      grouped[current]!.add({
                        ...item,
                        "status_hari": "Berangkat",
                        "waktu_hari": timeFormat.format(tglBerangkat),
                      });
                      grouped[current]!.add({
                        ...item,
                        "status_hari": "Kembali",
                        "waktu_hari": timeFormat.format(tglEnd),
                      });
                    } else {
                      // 🔹 Kasus normal (lebih dari 1 hari)
                      String status;
                      String? waktu;
                      if (DateUtils.isSameDay(current, tglBerangkat)) {
                        status = "Berangkat";
                        waktu = timeFormat.format(tglBerangkat);
                      } else if (DateUtils.isSameDay(current, tglEnd)) {
                        status = "Kembali";
                        waktu = timeFormat.format(tglEnd);
                      } else {
                        status = "Dipakai";
                        waktu = null;
                      }

                      grouped[current]!.add({
                        ...item,
                        "status_hari": status,
                        "waktu_hari": waktu,
                      });
                    }

                    current = current.add(const Duration(days: 1));
                  }
                }

                // 🔹 Hanya tampilkan tanggal yang punya agenda
                final filteredDates = grouped.keys.toList()
                  ..sort((a, b) => a.compareTo(b));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDates.length,
                  itemBuilder: (context, index) {
                    final date = filteredDates[index];
                    final list = grouped[date]!;
                    final hari = dayFormat.format(date);
                    final tanggal = shortDate.format(date);
                    final bgColor = getColorForDay(hari);

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Colors.blueGrey,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header tanggal
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        hari,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        tanggal,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 🔹 Tampilkan semua agenda di hari itu
                            ...list.map((item) {
                              final status = item['status_hari'] ?? "Dipinjam";
                              final waktu = item['waktu_hari'];
                              final warna = switch (status) {
                                "Berangkat" => Colors.green,
                                "Kembali" => Colors.orange,
                                _ => Colors.blueGrey,
                              };

                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama_user'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "$status${waktu != null ? ' : $waktu' : ''}",
                                      style: TextStyle(
                                        color: warna,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            // 🔹 History Mobil
            const Center(
              child: Text(
                "History Kendaraan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<Map<String, dynamic>>>(
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
                        "Belum ada history untuk kendaraan ini.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  );
                }

                final historyList = snapshot.data!;

                Color getStatusColor(String? status) {
                  switch (status?.toLowerCase()) {
                    case 'selesai':
                      return Colors.green.shade600;
                    case 'batal':
                      return Colors.red.shade600;
                    default:
                      return Colors.grey.shade600;
                  }
                }

                return ListView.builder(
                  itemCount: historyList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    final statusColor = getStatusColor(item["status"]);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: statusColor,
                                            ),
                                          ),
                                          child: Text(
                                            (item["status"] ?? "-")
                                                .toUpperCase(),
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
          ],
        ),
      ),
    );
  }
}
