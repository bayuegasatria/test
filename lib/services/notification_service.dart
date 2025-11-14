import 'dart:collection';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newapp/services/app_id_manager.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';
import 'package:newapp/api/logout_api.dart';
import 'package:newapp/pinjam/session_manager.dart';
import 'package:newapp/pinjam/loginpage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  final Set<String> _processedMessages = HashSet();
  Function(RemoteMessage message)? onMessageCallback;

  Future<void> init() async {
    if (_isInitialized) {
      print('⚠️ NotificationService sudah diinisialisasi, lewati init ulang.');
      return;
    }
    _isInitialized = true;

    // 🔹 Init local notifikasi
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotif.initialize(initSettings);

    // 🔹 Minta izin notifikasi
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Izin notifikasi: ${settings.authorizationStatus}');

    // 🔹 Ambil token FCM
    final token = await _messaging.getToken();
    print('🔥 FCM Token: $token');

    // 🔹 Listener notifikasi (foreground & background)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 🔹 Pesan saat app dibuka dari terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
        '🚀 App dibuka dari notifikasi (terminated): ${initialMessage.data}',
      );
      _handleDataMessage(initialMessage);
    }
  }

  // ==========================================================
  // 🧩 Handle notifikasi saat app di foreground
  // ==========================================================
  void _handleForegroundMessage(RemoteMessage message) {
    final messageId =
        message.messageId ?? message.data['id'] ?? DateTime.now().toString();

    if (_processedMessages.contains(messageId)) {
      print('⚠️ Duplikat pesan diabaikan (foreground): $messageId');
      return;
    }
    _processedMessages.add(messageId);

    // 🔹 Jalankan handler untuk data.message.type (termasuk force_logout)
    _handleDataMessage(message);

    // 🔹 Tampilkan notif visual jika ada title/body
    final title = message.notification?.title ?? "Notifikasi Baru";
    final body = message.notification?.body ?? "";

    if (title.isNotEmpty || body.isNotEmpty) {
      showLocalNotification(title, body);
      showSimpleNotification(
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(body, style: const TextStyle(color: Colors.white70)),
        background: Colors.blueAccent,
        autoDismiss: true,
        duration: const Duration(seconds: 4),
        leading: const Icon(Icons.notifications, color: Colors.white),
        slideDismissDirection: DismissDirection.up,
      );
    }

    onMessageCallback?.call(message);
  }

  // ==========================================================
  // 🧩 Handler untuk notifikasi data (type)
  // ==========================================================
  Future<void> _handleDataMessage(RemoteMessage message) async {
    final data = message.data;
    if (data.isEmpty) return;

    final type = data['type'] ?? '';
    print('📨 Handle data.message.type: $type');

    if (type == 'force_logout') {
      print("🚫 FORCE LOGOUT diterima dari server.");

      try {
        final user = await SessionManager.getUser();
        if (user != null) {
          final userId = user['id'] ?? '';
          final appId = await AppIdManager.getAppId();
          await LogoutApi.logout(userId, appId);
          await SessionManager.clearUser();

          _redirectToLogin();
        }
      } catch (e) {
        print("⚠️ Gagal menjalankan force logout: $e");
      }
    }
  }

  // ==========================================================
  // 🧩 Handle jika notifikasi dibuka dari background
  // ==========================================================
  void _onMessageOpenedApp(RemoteMessage message) {
    print('📱 Notifikasi dibuka dari background: ${message.data}');
    _handleDataMessage(message);
  }

  // ==========================================================
  // 🧩 Tampilkan local notifikasi (di tray Android)
  // ==========================================================
  Future<void> showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notifikasi Penting',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notifDetails,
    );
  }

  // ==========================================================
  // 🧩 Navigasi ke halaman login
  // ==========================================================
  void _redirectToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}

// ==========================================================
// 🔹 Global Navigator Key
// ==========================================================
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
