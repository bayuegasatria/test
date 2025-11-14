import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class PinjamApi {
  static Future<List<Map<String, dynamic>>> getJadwalMobil(DateTime now) async {
    final res = await http.get(
      ApiConfig.uri("getjadwalmobil.php", {"now": now.toIso8601String()}),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getStatusPinjamUser(
    int userId,
    DateTime now,
  ) async {
    final res = await http.get(
      ApiConfig.uri("getstatuspinjamuser.php", {
        "userId": "$userId",
        "now": now.toIso8601String(),
      }),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getHistoryPinjam({
    int? userId,
  }) async {
    final res = await http.get(
      ApiConfig.uri("gethistorypinjam.php", {"userId": "${userId ?? 0}"}),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getDetailAcc(int id) async {
    final res = await http.get(
      ApiConfig.uri("getdetailacc.php", {"id": "$id"}),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<Map<String, dynamic>?> getDetailPinjam(int idPinjam) async {
    final res = await http.get(
      ApiConfig.uri("getdetailpinjam.php", {"idPinjam": "$idPinjam"}),
    );

    final data = jsonDecode(res.body);

    if (data is Map && data['success'] == true && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }

    return null;
  }

  static Future<bool> updateStatusPinjamById(
    int idPinjam,
    String newStatus, {
    String? kmAwal,
    String? kmAkhir,
    File? fotoKmAwal,
    File? fotoKmAkhir,
  }) async {
    final uri = ApiConfig.uri("updatestatuspinjambyid.php");
    final request = http.MultipartRequest("POST", uri);

    request.fields["idPinjam"] = "$idPinjam";
    request.fields["newStatus"] = newStatus;
    if (kmAwal != null) request.fields["kmAwal"] = kmAwal;
    if (kmAkhir != null) request.fields["kmAkhir"] = kmAkhir;

    if (fotoKmAwal != null) {
      request.files.add(
        await http.MultipartFile.fromPath("fotoKmAwal", fotoKmAwal.path),
      );
    }
    if (fotoKmAkhir != null) {
      request.files.add(
        await http.MultipartFile.fromPath("fotoKmAkhir", fotoKmAkhir.path),
      );
    }

    final res = await request.send();
    final resBody = await res.stream.bytesToString();
    final data = jsonDecode(resBody);

    return data["success"] == true;
  }

  static Future<List<Map<String, dynamic>>> getPinjamanAktifByUser(
    int userId,
  ) async {
    final res = await http.get(
      ApiConfig.uri("getpinjamanaktifbyuser.php", {"userId": "$userId"}),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getHistoryPinjamMobil({
    int? userId,
    int? carId,
    String? role,
  }) async {
    final res = await http.get(
      ApiConfig.uri("gethistorypinjammobil.php", {
        "userId": "${userId ?? 0}",
        "carId": "${carId ?? 0}",
        "role": role ?? "",
      }),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
