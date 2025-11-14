import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserApi {
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final res = await http.get(ApiConfig.uri("getusers.php"));
    final body = jsonDecode(res.body);

    if (body is Map && body['data'] is List) {
      return (body['data'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }
}
