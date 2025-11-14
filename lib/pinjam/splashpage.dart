import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newapp/services/app_id_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'loginpage.dart';
import 'dashboard.dart';
import 'user_provider.dart';
import '../api/token_api.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final String? nama = prefs.getString("nama");
    final String? nip = prefs.getString("nip");
    final String? role = prefs.getString("role");
    final String? id = prefs.getString("id");
    final String? div = prefs.getString("nama_divisi");
    final String? divId = prefs.getString("divisi_id");
    final String? namarole = prefs.getString("nama_role");
    print(nama);
    print(nip);
    print(role);
    print(id);
    print(div);
    print(divId);
    print(namarole);
    await Future.delayed(const Duration(seconds: 3));

    if (nama != null &&
        nip != null &&
        role != null &&
        id != null &&
        div != null &&
        divId != null &&
        namarole != null) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("📱 FCM Token baru: $fcmToken");

        try {
          final appId = await AppIdManager.getAppId();
          final success = await TokenApi.saveToken(
            userId: int.parse(id),
            token: fcmToken,
            appId: appId,
          );

          if (success) {
            print("✅ Token berhasil disimpan/diupdate di server.");
          } else {
            print("⚠️ Gagal menyimpan token ke server.");
          }
        } catch (e) {
          print("❌ Error saat kirim token: $e");
        }
      } else {
        print("⚠️ Gagal mendapatkan FCM Token dari Firebase.");
      }

      if (context.mounted) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUserData(nama, nip, role, id, div, divId, namarole);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/images/bpom_logo.png"),
              width: 200,
              height: 200,
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
