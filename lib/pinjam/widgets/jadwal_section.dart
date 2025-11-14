import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';

class JadwalSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> jadwalFuture;

  const JadwalSection({super.key, required this.jadwalFuture});

  Color getRandomColor(String key) {
    final hash = key.hashCode;
    final random = Random(hash);

    final hue = (random.nextInt(12) * 30) % 360;
    final saturation = 0.55 + random.nextDouble() * 0.25;
    final lightness = 0.55 + random.nextDouble() * 0.20;

    final hsl = HSLColor.fromAHSL(1.0, hue.toDouble(), saturation, lightness);
    return hsl.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat("HH:mm");
    final dayFormat = DateFormat("EEEE", 'id_ID');
    final shortDate = DateFormat("dd MMM", 'id_ID');

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

    return StickyHeader(
      header: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Center(
          child: Text(
            "Jadwal Kendaraan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      content: FutureBuilder<List<Map<String, dynamic>>>(
        future: jadwalFuture,
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

          final DateTime today = DateTime.now();
          final List<DateTime> next7Days = List.generate(
            7,
            (i) => DateTime(today.year, today.month, today.day + i),
          );

          final Map<DateTime, List<Map<String, dynamic>>> grouped = {
            for (var d in next7Days) d: [],
          };

          for (var item in data) {
            final tglBerangkat = parseTanggal(item['tanggal_berangkat']);
            final tglKembali = parseTanggal(item['tanggal_kembali']);
            if (tglBerangkat == null) continue;
            final tglEnd = tglKembali ?? tglBerangkat;

            final key =
                item['id_pinjam']?.toString() ??
                item['id']?.toString() ??
                item['nama_mobil'] ??
                Random().nextInt(999999).toString();
            final pairColor = getRandomColor(key);

            for (var d in next7Days) {
              final dayStart = DateTime(d.year, d.month, d.day);
              final dayEnd = dayStart.add(const Duration(days: 1));

              if (tglBerangkat.isBefore(dayEnd) &&
                  tglEnd.isAfter(
                    dayStart.subtract(const Duration(milliseconds: 1)),
                  )) {
                if (DateUtils.isSameDay(tglBerangkat, tglEnd)) {
                  if (DateUtils.isSameDay(d, tglBerangkat)) {
                    grouped[d]?.add({
                      ...item,
                      "status_hari": "Berangkat",
                      "waktu_hari": timeFormat.format(tglBerangkat),
                      "pair_color": pairColor,
                    });
                    grouped[d]?.add({
                      ...item,
                      "status_hari": "Kembali",
                      "waktu_hari": timeFormat.format(tglEnd),
                      "pair_color": pairColor,
                    });
                  }
                } else {
                  String status;
                  String? waktu;
                  if (DateUtils.isSameDay(d, tglBerangkat)) {
                    status = "Berangkat";
                    waktu = timeFormat.format(tglBerangkat);
                  } else if (DateUtils.isSameDay(d, tglEnd)) {
                    status = "Kembali";
                    waktu = timeFormat.format(tglEnd);
                  } else {
                    status = "Dipakai";
                    waktu = null;
                  }

                  grouped[d]?.add({
                    ...item,
                    "status_hari": status,
                    "waktu_hari": waktu,
                    "pair_color": pairColor,
                  });
                }
              }
            }
          }

          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => a.compareTo(b));

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final list = grouped[date]!;
              final hari = dayFormat.format(date);
              final tanggal = shortDate.format(date);
              final bgColor = getColorForDay(hari);

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.blueGrey, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      if (list.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            "Tidak ada jadwal mobil hari ini.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...list.map((item) {
                          final status = item['status_hari'] ?? "Dipinjam";
                          final waktu = item['waktu_hari'];
                          final warnaStatus = switch (status) {
                            "Berangkat" => Colors.green,
                            "Kembali" => Colors.orange,
                            _ => Colors.blueGrey,
                          };
                          final circleColor = item['pair_color'] as Color;

                          return Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(
                                    right: 10,
                                    top: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: circleColor,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama_mobil'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (item['nama_user'] != null &&
                                          (item['nama_user'] as String)
                                              .isNotEmpty)
                                        Text(
                                          "No : ${item['no_pengajuan']} \nDipakai oleh: ${item['nama_user']} \nTujuan: ${item['tujuan']} \nBidang : ${item['nama_divisi']} ",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                      Text(
                                        "$status${waktu != null ? ' : $waktu' : ''}",
                                        style: TextStyle(
                                          color: warnaStatus,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
    );
  }
}
