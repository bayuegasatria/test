import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AduanApi {
  static Future<List<Map<String, dynamic>>> getAduanData({
    required String role,
    required int userId,
    required int divisi,
  }) async {
    final res = await http.get(
      ApiConfig.uri("getaduan.php", {
        "role": role,
        "userId": userId.toString(),
        "divisi": divisi.toString(),
      }),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      // Pastikan hasilnya list of map
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Gagal memuat data aduan (${res.statusCode})");
    }
  }

  static Future<List<Map<String, dynamic>>> getJenisBarang() async {
    final res = await http.get(ApiConfig.uri("getjenisbarang.php"));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Gagal memuat data jenis barang (${res.statusCode})");
    }
  }

  static Future<List<Map<String, dynamic>>> getInventarisByJenis({
    required int jenisBarangId,
  }) async {
    final res = await http.get(
      ApiConfig.uri("getinventaris.php", {
        "jenis_barang": jenisBarangId.toString(),
      }),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(res.body);

      // Jika hasilnya status success dan ada data
      if (result["status"] == "success" && result["data"] != null) {
        final List data = result["data"];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      // Jika kosong
      if (result["status"] == "empty") {
        return [];
      }

      throw Exception(result["message"] ?? "Terjadi kesalahan tak dikenal");
    } else {
      throw Exception("Gagal memuat data inventaris (${res.statusCode})");
    }
  }

  static Future<Map<String, dynamic>> addAduan({
    required String noAduan,
    required String tanggal,
    required String aduanStatus,
    required int pegawaiId,
    required int divisiId,
    required int? inventarisId,
    required String problem,
    required int? katimId,
  }) async {
    final uri = ApiConfig.uri("addaduan.php");
    final res = await http.post(
      uri,
      body: {
        "no_aduan": noAduan,
        "tanggal": tanggal,
        "aduan_status": aduanStatus,
        "pegawai_id": pegawaiId.toString(),
        "divisi_id": divisiId.toString(),
        "inventaris_id": inventarisId?.toString() ?? '',
        "problem": problem,
        "katim": katimId.toString(),
      },
    );

    if (res.statusCode == 200) {
      final result = jsonDecode(res.body);
      if (result["success"] == true) {
        return {
          "success": true,
          "message": result["message"],
          "insert_id": result["insert_id"],
        };
      } else {
        return {
          "success": false,
          "message": result["message"] ?? "Gagal menambahkan aduan",
        };
      }
    } else {
      throw Exception("Gagal mengirim data aduan (${res.statusCode})");
    }
  }

  static Future<Map<String, dynamic>> updateAduan({
    required int id,
    required String role,
    required String problem,
    String? aduanStatus,
    String? analisa,
    String? followUp,
    String? result,
    String? analyzeDate,
    int? petugasId,
    int? inventarisId,
  }) async {
    final uri = ApiConfig.uri("updateaduan.php");

    final body = jsonEncode({
      "id": id,
      "role": role,
      "problem": problem,
      "aduan_status": aduanStatus,
      "analisa": analisa,
      "follow_up": followUp,
      "result": result,
      "analyze_date": analyzeDate,
      "petugas_id": petugasId,
      "inventaris_id": inventarisId,
    });

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (res.statusCode == 200) {
      final result = jsonDecode(res.body);
      return {
        "success": result["success"] == true,
        "message": result["message"] ?? "Tidak ada pesan dari server",
      };
    } else {
      throw Exception("Gagal update aduan (${res.statusCode})");
    }
  }

  static Future<String> generateNoAduan() async {
    final uri = ApiConfig.uri("generatenoaduan.php");
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final result = jsonDecode(res.body);
      if (result["success"] == true) {
        return result["no_aduan"];
      } else {
        throw Exception(result["message"] ?? "Gagal generate nomor aduan");
      }
    } else {
      throw Exception("Gagal menghubungi server (${res.statusCode})");
    }
  }

  static Future<List<dynamic>?> getTeamleaderByDivisi(int divisiId) async {
    try {
      final uri = ApiConfig.uri("getkatim.php?divisi_id=$divisiId");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data["status"] == "success") {
          return data["data"]; // list of teamleader
        } else {
          print("⚠️ ${data["message"]}");
          return [];
        }
      } else {
        print("❌ Gagal memuat data: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error getTeamleaderByDivisi: $e");
      return null;
    }
  }

  static Future<bool> softDeleteAduan(int id) async {
    final url = ApiConfig.uri(
      "batalkanaduan.php",
    ); // ganti sesuai nama file API kamu

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      final data = jsonDecode(response.body);
      return data["success"] == true;
    } catch (e) {
      debugPrint("❌ Error soft delete: $e");
      return false;
    }
  }
}
