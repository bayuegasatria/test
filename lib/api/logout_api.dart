import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LogoutApi {
  static Future<bool> logout(String userId, String appId) async {
    final res = await http.post(
      ApiConfig.uri("logout.php"),
      body: {"user_id": userId, "app_id": appId},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['status'] == "success";
    } else {
      return false;
    }
  }
}
