import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:newapp/pinjam/splashpage.dart';
import 'package:newapp/pinjam/user_provider.dart';
import 'package:newapp/services/notification_service.dart';
import 'package:newapp/services/app_id_manager.dart';
import 'package:newapp/pinjam/session_manager.dart';
import 'package:newapp/api/logout_api.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// ==========================================================
// 🔹 Background handler (force logout tetap bisa jalan)
// ==========================================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Pesan diterima di background: ${message.messageId}');
  print('Data: ${message.data}');
  await Firebase.initializeApp();
  final type = message.data['type'];
  if (type == 'force_logout') {
    print("🚫 FORCE LOGOUT (background) diterima");

    try {
      final user = await SessionManager.getUser();
      if (user != null) {
        final userId = user['id'] ?? '';
        final appId = await AppIdManager.getAppId();
        await LogoutApi.logout(userId, appId);
        await SessionManager.clearUser();

        print("✅ Session user $userId berhasil dihapus (background)");
      }
    } catch (e) {
      print("⚠️ Gagal menjalankan force logout di background: $e");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp();

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().init();

  final appId = await AppIdManager.getAppId();
  print("📱 APP ID aktif: $appId");

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NewApp',
        navigatorKey: navigatorKey, // ✅ penting untuk logout navigation
        navigatorObservers: [routeObserver],
        home: const SplashPage(),
      ),
    );
  }
}
