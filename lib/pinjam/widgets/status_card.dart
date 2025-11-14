import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pengembalianpage.dart';

class StatusCard extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> statusFuture;
  final VoidCallback onRefresh;

  const StatusCard({
    super.key,
    required this.statusFuture,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd MMM yyyy, HH:mm");

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmpty();
        }

        // 🔹 Filter status aktif (menunggu, berjalan, terlambat)
        final now = DateTime.now();
        final filteredList = snapshot.data!.where((item) {
          final status = item['status'];
          final tglKembali = DateTime.tryParse(item['tanggal_kembali'] ?? '');
          final bool isTerlambat =
              status == 'berjalan' &&
              tglKembali != null &&
              tglKembali.isBefore(now);
          return status == 'menunggu' || status == 'berjalan' || isTerlambat;
        }).toList();

        if (filteredList.isEmpty) return _buildEmpty();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: Text(
                  "Peminjaman Anda",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // 🔹 Daftar status
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final tglMulai = DateTime.tryParse(item['tanggal_berangkat']);
                final tglSelesai = DateTime.tryParse(item['tanggal_kembali']);
                final status = item['status'];

                // Cek apakah terlambat
                final bool isTerlambat =
                    status == 'berjalan' &&
                    tglSelesai != null &&
                    tglSelesai.isBefore(DateTime.now());

                // 🔹 Warna, ikon, dan label status
                late final Color statusColor;
                late final IconData iconData;
                late final String titleText;
                late final String displayStatus;

                if (isTerlambat) {
                  statusColor = Colors.red;
                  iconData = Icons.warning_amber_rounded;
                  titleText = "Terlambat Dikembalikan";
                  displayStatus = "TERLAMBAT";
                } else {
                  switch (status) {
                    case 'menunggu':
                      statusColor = Colors.orange;
                      iconData = Icons.schedule;
                      titleText = "Menunggu Dimulai";
                      displayStatus = "MENUNGGU";
                      break;
                    case 'berjalan':
                      statusColor = Colors.green;
                      iconData = Icons.directions_car_rounded;
                      titleText = "Sedang Berjalan";
                      displayStatus = "BERJALAN";
                      break;
                    default:
                      statusColor = Colors.grey;
                      iconData = Icons.info_outline;
                      titleText = "Status Tidak Dikenali";
                      displayStatus = status.toUpperCase();
                      break;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Card(
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.blueGrey, width: 0.5),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PengembalianPage(
                              data: {"id_pinjam": item['id']},
                            ),
                          ),
                        );
                        onRefresh();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Icon status
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                iconData,
                                color: statusColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // 🔹 Detail pinjaman
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Judul + badge
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          titleText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          displayStatus,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tujuan : ${item['tujuan'] ?? '-'}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Mobil   : ${item['nama_mobil'] ?? '-'}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "${tglMulai != null ? dateFormat.format(tglMulai) : '-'}"
                                    "  •  "
                                    "${tglSelesai != null ? dateFormat.format(tglSelesai) : '-'}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: Text(
              "Peminjaman Anda",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Tidak ada peminjaman aktif",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
