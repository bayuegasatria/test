import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class TokenApi {
  static Future<bool> saveToken({
    required int userId,
    required String token,
    required String appId,
  }) async {
    final uri = ApiConfig.uri('savetoken.php');
    final res = await http.post(
      uri,
      body: {'user_id': userId.toString(), 'token': token, 'app_id': appId},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('🔹 Save token response: $data');
      return data['success'] == true;
    } else {
      print('❌ Gagal kirim token: ${res.body}');
      return false;
    }
  }

  static Future<String?> getToken(int userId) async {
    final uri = ApiConfig.uri('gettoken.php', {'user_id': userId.toString()});
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('📦 Get token response: $data');
      if (data['success'] == true) {
        return data['fcm_token'];
      }
    } else {
      print('❌ Gagal ambil token: ${res.body}');
    }
    return null;
  }

  static Future<bool> deleteToken(int userId) async {
    final uri = ApiConfig.uri('hapustoken.php');
    final res = await http.post(uri, body: {'user_id': userId.toString()});

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('🗑️ Delete token response: $data');
      return data['success'] == true;
    } else {
      print('❌ Gagal hapus token: ${res.body}');
      return false;
    }
  }
}
