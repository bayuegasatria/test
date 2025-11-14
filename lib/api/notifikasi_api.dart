import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class NotifikasiApi {
  static Future<List<Map<String, dynamic>>> getNotifikasi(int userId) async {
    try {
      final res = await http.get(
        ApiConfig.uri("getnotifikasi.php?user_id=$userId"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> markNotifAsRead(int userId, {int? notifId}) async {
    try {
      final body = {
        "user_id": "$userId",
        if (notifId != null) "notif_id": "$notifId",
      };

      final res = await http.post(
        ApiConfig.uri("marknotifasread.php"),
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<int> getNotifCount(int userId) async {
    try {
      final res = await http.get(
        ApiConfig.uri("getnotifcount.php?user_id=$userId"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['total'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
