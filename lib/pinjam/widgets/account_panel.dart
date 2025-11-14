import 'package:flutter/material.dart';
import 'package:newapp/services/app_id_manager.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../session_manager.dart';
import '../loginpage.dart';
import '../../api/logout_api.dart';

void showAccountPanel(BuildContext context) {
  final user = Provider.of<UserProvider>(context, listen: false);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Account Panel",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // Header profil user
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    user.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [Text(user.nip), Text(user.div)],
                  ),
                ),

                const Divider(),

                // Tombol Logout
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 35,
                    ),
                    title: const Text("Logout"),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    onTap: () async {
                      final rootContext = Navigator.of(
                        context,
                        rootNavigator: true,
                      ).context;

                      // Konfirmasi Logout
                      final confirm = await showDialog<bool>(
                        context: rootContext,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: Colors.white,
                          title: const Text(
                            "Konfirmasi Logout",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blueAccent,
                            ),
                          ),
                          content: const Text(
                            "Apakah kamu yakin ingin keluar dari akun ini?",
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Batal"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Logout"),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      // Tutup panel utama
                      Navigator.pop(context);

                      // Tampilkan loading pakai root context
                      showDialog(
                        context: rootContext,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      final appId = await AppIdManager.getAppId();
                      await LogoutApi.logout(user.id, appId);
                      await SessionManager.clearUser();

                      // Tutup dialog loading
                      if (rootContext.mounted) Navigator.pop(rootContext);

                      // Tampilkan pesan

                      // Pindah ke halaman login
                      if (rootContext.mounted) {
                        Navigator.pushAndRemoveUntil(
                          rootContext,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
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
    transitionBuilder: slideFromLeftTransition,
  );
}

Widget slideFromLeftTransition(
  BuildContext context,
  Animation<double> anim1,
  Animation<double> anim2,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
    child: child,
  );
}
