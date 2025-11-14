import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppIdManager {
  static const String _keyAppId = "app_id";

  /// 🔹 Ambil atau buat app_id baru jika belum ada
  static Future<String> getAppId() async {
    final prefs = await SharedPreferences.getInstance();

    // Jika sudah ada app_id tersimpan, langsung return
    if (prefs.containsKey(_keyAppId)) {
      return prefs.getString(_keyAppId)!;
    }

    // Jika belum ada, buat baru pakai UUID v4
    final newAppId = const Uuid().v4();

    await prefs.setString(_keyAppId, newAppId);
    print("🆔 App ID baru dibuat: $newAppId");

    return newAppId;
  }

  /// 🔹 Hapus app_id (misal saat uninstall/reset)
  static Future<void> clearAppId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppId);
  }
}
