import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AccApi {
  static Future<List<Map<String, dynamic>>> getAccData({
    required String role,
    required int userId,
  }) async {
    final res = await http.get(
      ApiConfig.uri("getaccdata.php", {
        "role": role,

        "userId": userId.toString(),
      }),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Gagal memuat data ACC (${res.statusCode})");
    }
  }

  static Future<Map<String, dynamic>?> getPengajuanById(int id) async {
    final res = await http.get(
      ApiConfig.uri("getpengajuanbyid.php", {"id": id.toString()}),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      if (data.isNotEmpty) {
        return Map<String, dynamic>.from(data.first);
      }
      return null;
    } else {
      throw Exception("Gagal memuat detail pengajuan (${res.statusCode})");
    }
  }
}
