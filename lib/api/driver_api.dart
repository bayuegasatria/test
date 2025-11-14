import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class DriverApi {
  static Future<List<Map<String, dynamic>>> getDriver() async {
    final res = await http.get(ApiConfig.uri("getdriver.php"));
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getAvailableSupir(
    DateTime berangkat,
    DateTime kembali,
  ) async {
    final res = await http.get(
      ApiConfig.uri("getavailablesupir.php", {
        "berangkat": berangkat.toIso8601String(),
        "kembali": kembali.toIso8601String(),
      }),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
