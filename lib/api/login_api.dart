import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LoginApi {
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
    String appId,
    String fcmToken,
  ) async {
    final response = await http.post(
      ApiConfig.uri("login.php"),
      body: {
        "username": username,
        "password": password,
        "app_id": appId,
        "fcm_token": fcmToken,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
