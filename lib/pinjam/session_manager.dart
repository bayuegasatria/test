import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyNama = "nama";
  static const String keyNip = "nip";
  static const String keyRole = "role";
  static const String keyId = "id";
  static const String keyDiv = "nama_divisi";
  static const String keyDivId = "divisi_id";
  static const String keyNamaRole = "nama_role";

  static Future<void> saveUser({
    required String nama,
    required String nip,
    required String role,
    required String id,
    required String div,
    required String divId,
    required String namarole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyNama, nama);
    await prefs.setString(keyNip, nip);
    await prefs.setString(keyRole, role);
    await prefs.setString(keyId, id);
    await prefs.setString(keyDiv, div);
    await prefs.setString(keyDivId, divId);
    await prefs.setString(keyNamaRole, namarole);
  }

  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(keyId)) {
      return {
        "nama": prefs.getString(keyNama) ?? "",
        "nip": prefs.getString(keyNip) ?? "",
        "role": prefs.getString(keyRole) ?? "",
        "id": prefs.getString(keyId) ?? "",
        "nama_divisi": prefs.getString(keyDiv) ?? "",
        "divisi_id": prefs.getString(keyDivId) ?? "",
        "nama_role": prefs.getString(keyNamaRole) ?? "",
      };
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString(keyId);
    if (userId != null && userId.isNotEmpty) {
      print("🧾 Menghapus session untuk user ID: $userId");
    }

    await prefs.clear();
    print("🧹 Session cleared (tanpa API call)");
  }
}
