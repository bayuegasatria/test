import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:newapp/services/app_id_manager.dart';

import 'user_provider.dart';
import 'package:newapp/pinjam/dashboard.dart';
import 'session_manager.dart';
import '../api/login_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// ✅ Fungsi popup umum
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

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool loading = false;
  Timer? _debounce;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      await showPopup(context, "Username dan Password harus diisi!");
      return;
    }

    setState(() => loading = true);

    try {
      final appId =
          await AppIdManager.getAppId(); // ✅ ambil app_id unik perangkat
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final result = await LoginApi.login(
        username,
        password,
        appId,
        fcmToken ?? '',
      );

      if (result == null) {
        await showPopup(context, "Gagal terhubung ke server.");
        return;
      }

      final status = result['status'];
      final message = result['message'];
      final user = result['user'];

      if (status == "success" && user != null) {
        // Simpan session user
        final userId = user['id'].toString();
        final divisiId = user['divisi_id'].toString();
        Provider.of<UserProvider>(context, listen: false).setUserData(
          user['nama'],
          user['nip'],
          user['role'],
          userId,
          user['nama_divisi'],
          divisiId,
          user['nama_role'],
        );

        await SessionManager.saveUser(
          nama: user['nama'],
          nip: user['nip'],
          role: user['role'],
          id: userId,
          div: user['nama_divisi'],
          divId: divisiId,
          namarole: user['nama_role'],
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        }
      } else {
        await showPopup(context, message ?? "Login gagal");
      }
    } catch (e) {
      await showPopup(context, "Terjadi kesalahan: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFa8e0f0), Color(0xFF7f8fa6)],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Image.asset(
                      'assets/images/bpom_logo2.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Username field
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      hintText: "Username (Email)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Password ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
