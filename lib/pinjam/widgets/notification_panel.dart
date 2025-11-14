import 'package:flutter/material.dart';
import 'package:newapp/api/notifikasi_api.dart';
import 'package:newapp/api/pengajuan_api.dart';
import 'package:newapp/pinjam/accdetailpage.dart';

void showNotificationPanel(
  BuildContext context,
  Future<List<Map<String, dynamic>>> notifFuture, {
  required int userId,
  VoidCallback? onClose,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Notification Panel",
    transitionDuration: const Duration(milliseconds: 50),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: double.infinity,
            color: Colors.white,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: notifFuture,
              builder: (context, snapshot) {
                final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 8,
                        top: 40,
                        bottom: 12,
                      ),
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Notifikasi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: hasData
                                ? () async {
                                    await NotifikasiApi.markNotifAsRead(userId);
                                    if (context.mounted) {
                                      if (onClose != null) onClose();
                                      Navigator.pop(context);
                                    }
                                  }
                                : null,
                            icon: Icon(
                              Icons.done_all,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              "Tandai\nSemua Dibaca",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasData
                                  ? Colors.blue
                                  : Colors.grey,
                              disabledBackgroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(90, 48),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Builder(
                        builder: (_) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (!hasData) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("Belum ada notifikasi"),
                              ),
                            );
                          }

                          final notifs = snapshot.data!;
                          return ListView.builder(
                            itemCount: notifs.length,
                            itemBuilder: (context, index) {
                              final notif = notifs[index];
                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Colors.blueGrey,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.notifications,
                                    color: Colors.blue,
                                  ),
                                  title: Text(
                                    notif['judul'] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(notif['pesan'] ?? ""),
                                      Text(
                                        notif['created_at'] ?? "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    final notifId = int.tryParse(
                                      notif['id']?.toString() ?? "",
                                    );
                                    await NotifikasiApi.markNotifAsRead(
                                      userId,
                                      notifId: notifId,
                                    );

                                    final detail =
                                        await PengajuanApi.getPengajuanById(
                                          int.tryParse(
                                                notif["pengajuan_id"]
                                                    .toString(),
                                              ) ??
                                              0,
                                        );

                                    if (detail != null && context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AccDetailPage(
                                            data: detail,
                                            status: detail["status"] ?? "P",
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Data tidak ditemukan"),
                                        ),
                                      );
                                    }
                                    if (onClose != null) onClose();
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
    transitionBuilder: slideFromRightTransition,
  ).whenComplete(() {
    if (onClose != null) onClose();
  });
}

Widget slideFromRightTransition(
  BuildContext context,
  Animation<double> anim1,
  Animation<double> anim2,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
    child: child,
  );
}
