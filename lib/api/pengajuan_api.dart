import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class PengajuanApi {
  static Future<List<Map<String, dynamic>>> getAccData(
    String role,
    int userId,
  ) async {
    final res = await http.get(
      ApiConfig.uri("getaccdata.php", {"role": role, "userId": "$userId"}),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<Map<String, dynamic>?> getPengajuanById(int id) async {
    final res = await http.get(
      ApiConfig.uri("getpengajuanbyid.php", {"id": "$id"}),
    );
    final data = jsonDecode(res.body);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  static Future<List<Map<String, dynamic>>> getAllPengajuan() async {
    final res = await http.get(ApiConfig.uri("getallpengajuan.php"));
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<bool> tolakPengajuan({
    required int pengajuanId,
    required String catatan,
  }) async {
    final res = await http.post(
      ApiConfig.uri("tolakpengajuan.php"),
      body: {"id_pengajuan": "$pengajuanId", "catatan": catatan},
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  static Future<bool> accPengajuan({
    required int idPengajuan,
    required int idMobil,
    required int? idSupir,
    required String catatan,
    required int idUserLogin,
  }) async {
    try {
      final res = await http.post(
        ApiConfig.uri("accpengajuan.php"),
        body: {
          "id_pengajuan": "$idPengajuan",
          "idMobil": "$idMobil",
          "idSupir": "$idSupir",
          "catatan": catatan,
          "id_user_login": "$idUserLogin",
        },
      );

      print("👉 Response dari API: ${res.body}");

      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (e) {
      print("❌ JSON Decode Error: $e");
      return false;
    }
  }

  static Future<bool> updateAccPengajuan({
    required int idPengajuan,
    required int idMobil,
    required int? idSupir,
    required String catatan,
    required int idUserLogin,
    required String pengemudi,
  }) async {
    try {
      final res = await http.post(
        ApiConfig.uri("updateaccpengajuan.php"),
        body: {
          "id_pengajuan": "$idPengajuan",
          "idMobil": "$idMobil",
          "idSupir": "$idSupir",
          "catatan": catatan,
          "idUserLogin": "$idUserLogin",
          "pengemudi": pengemudi,
        },
      );

      print("👉 Response dari API: ${res.body}");

      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (e) {
      print("❌ JSON Decode Error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getDetailAcc(int idPengajuan) async {
    try {
      final uri = ApiConfig.uri("getdetailacc.php", {
        "id": idPengajuan.toString(),
      });
      print("🔗 URL: $uri");

      final res = await http.get(uri);
      print("📥 Response status: ${res.statusCode}");
      print("📦 Response body: ${res.body}");

      if (res.statusCode == 200) {
        final body = res.body.trim();

        // Pastikan respon JSON valid
        if (body.startsWith('{') || body.startsWith('[')) {
          final decoded = jsonDecode(body);

          if (decoded is Map<String, dynamic>) {
            if (decoded['success'] == true && decoded['data'] != null) {
              return Map<String, dynamic>.from(decoded['data']);
            } else {
              print("⚠️ getDetailAcc: success=false atau data kosong.");
            }
          } else {
            print("⚠️ Format JSON tidak sesuai (bukan Map).");
          }
        } else {
          print("⚠️ Response bukan JSON valid: ${body.substring(0, 100)}...");
        }
      } else {
        print("❌ HTTP error status: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ getDetailAcc error: $e");
    }

    return null;
  }

  static Future<bool> batalkanPengajuan({
    required int pengajuanId,
    required String catatan,
  }) async {
    try {
      final res = await http.post(
        ApiConfig.uri("batalkanpengajuan.php"),
        body: {"id_pengajuan": "$pengajuanId", "catatan": catatan},
      );

      print("🟡 Response dari API Batalkan: ${res.body}");

      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (e) {
      print("❌ batalkanPengajuan error: $e");
      return false;
    }
  }

  static Future<String?> generateNoPengajuan() async {
    try {
      final url = ApiConfig.uri("getnopengajuan.php");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['no_pengajuan'];
        } else {
          print("Gagal generate nomor: ${data['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
    return null;
  }
}
