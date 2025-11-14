import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MobilApi {
  static Future<List<Map<String, dynamic>>> getMobil() async {
    final res = await http.get(ApiConfig.uri("getmobil.php"));
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getMobilWithStatus() async {
    final res = await http.get(ApiConfig.uri("getmobilwithstatus.php"));
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getAvailableMobil(
    DateTime berangkat,
    DateTime kembali,
    String type,
  ) async {
    final res = await http.get(
      ApiConfig.uri("getavailablemobil.php", {
        "berangkat": berangkat.toIso8601String(),
        "kembali": kembali.toIso8601String(),
        "type": type,
      }),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getJadwalMobil(DateTime now) async {
    try {
      final res = await http.get(
        ApiConfig.uri("getJadwalMobil.php", {
          "now": now.toIso8601String().split("T")[0],
        }),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Gagal load jadwal: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error getJadwalMobil: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getJadwalMobilId(
    DateTime now,
    int id,
  ) async {
    try {
      final res = await http.get(
        ApiConfig.uri("getjadwalmobilwithid.php", {
          "now": now.toIso8601String().split("T")[0],
          "id": id.toString(),
        }),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Gagal load jadwal: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error getJadwalMobil: $e");
    }
  }
}
