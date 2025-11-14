import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LaporanApi {
  static Future<List<Map<String, dynamic>>?> getLaporanPeminjaman({
    required String bidang,
    required String durasi,
    String? bulan,
    String? triwulan,
    required String tahun,
  }) async {
    final response = await http.post(
      ApiConfig.uri("getlaporanpeminjaman.php"),
      body: {
        "bidang": bidang,
        "durasi": durasi,
        "bulan": bulan ?? "",
        "triwulan": triwulan ?? "",
        "tahun": tahun,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getDivisiList() async {
    final url = ApiConfig.uri("getdivisi.php");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final List<dynamic> divisiData = data['data'];
        return divisiData
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception(
        "Gagal mengambil data dari server (${response.statusCode})",
      );
    }
  }

  static Future<dynamic> getLaporanFrekuensi({
    required String kelompok, // "divisi" atau "kendaraan"
    String? divisi,
    required String durasi, // "bulan" atau "tahun"
    String? bulan,
    required String tahun,
  }) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/getlaporanfrekuensi.php");
      final response = await http.post(
        url,
        body: {
          "kelompok": kelompok,
          "divisi": divisi ?? "",
          "durasi": durasi,
          "bulan": bulan ?? "",
          "tahun": tahun,
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        print("❌ getLaporanFrekuensi status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ getLaporanFrekuensi error: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getPemakaianKendaraan({
    required int carId,
    String? bulan,
    String? tahun,
  }) async {
    final params = {
      'carId': carId.toString(),
      if (bulan != null && bulan.isNotEmpty)
        'bulan': (DateTime.parse('2024-$bulan-01').month).toString(),
      if (tahun != null) 'tahun': tahun,
    };

    final uri = ApiConfig.uri("getpemakaian.php", params);
    final res = await http.get(uri);
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
