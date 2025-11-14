import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AduanTikApi {
  static Future<List<Map<String, dynamic>>> getJenisTik() async {
    final res = await http.get(ApiConfig.uri("getjenistik.php"));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Gagal memuat data jenis barang (${res.statusCode})");
    }
  }

  static Future<List<Map<String, dynamic>>> getAduanTIKData({
    required String role,
    required int userId,
    required int divisi,
  }) async {
    final res = await http.get(
      ApiConfig.uri("getaduantik.php", {
        "role": role,
        "userId": userId.toString(),
        "divisi": divisi.toString(),
      }),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Gagal memuat data Aduan TIK (${res.statusCode})");
    }
  }

  static Future<List<Map<String, dynamic>>> getItAssetByJenisTIK(
    int jenistikId,
  ) async {
    final url = ApiConfig.uri("getinventaristik.php?jenistik_id=$jenistikId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == 'success') {
          final List<dynamic> data = result['data'];
          return List<Map<String, dynamic>>.from(data);
        } else {
          return [];
        }
      } else {
        print("❌ Gagal memuat data: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("⚠️ Error getItAssetByJenisTIK: $e");
      return [];
    }
  }

  Future<void> tambahAduanTik({
    required String noAduan,
    required String tanggal,
    required int usersId,
    required int divisiId,
    required int itassetId,
    required String trouble,
  }) async {
    final url = ApiConfig.uri('addaduantik.php');

    final response = await http.post(
      url,
      body: {
        'no_aduan': noAduan,
        'tanggal': tanggal,
        'users_id': usersId.toString(),
        'divisi_id': divisiId.toString(),
        'itasset_id': itassetId.toString(),
        'trouble': trouble,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        print('✅ Aduan berhasil ditambahkan: ${data['insert_id']}');
      } else {
        print('⚠️ Gagal menambah aduan: ${data['message']}');
      }
    } else {
      print('❌ Error server (${response.statusCode})');
    }
  }

  static Future<String> generateNoAduanTik() async {
    final uri = ApiConfig.uri("generatenoaduantik.php");
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

  static Future<Map<String, dynamic>> updateAduanTik({
    required int id,
    required String role,
    String? trouble,
    String? status,
    String? analisa,
    String? followUp,
    String? result,
    String? analyzeDate,
    String? followupDate,
    String? resultDate,
    int? petugasId,
    int? itassetId,
  }) async {
    final url = ApiConfig.uri("updateaduantik.php");

    final body = {
      "id": id,
      "role": role,
      "trouble": trouble,
      "status": status,
      "analisa": analisa,
      "follow_up": followUp,
      "result": result,
      "analyze_date": analyzeDate,
      "followup_date": followupDate,
      "result_date": resultDate,
      "petugas_id": petugasId,
      "itasset_id": itassetId,
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<bool> softDeleteAduanTIK(int id) async {
    final url = ApiConfig.uri(
      "batalkanaduantik.php",
    ); // Pastikan sesuai API kamu

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
