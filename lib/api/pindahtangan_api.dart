import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class PindahtanganApi {
  /// 🔹 Ambil semua data pindahtangan (JOIN inventaris, user asal, user baru, lokasi)
  static Future<Map<String, dynamic>> getAllPindahtangan() async {
    final uri = ApiConfig.uri("getpindahtangan.php");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data pindahtangan");
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  /// 🔹 Ambil daftar inventaris berdasarkan jenis_barang
  static Future<Map<String, dynamic>> getInventarisByJenisBarang(
    int jenisBarangId,
  ) async {
    final uri = ApiConfig.uri("getinventaris.php", {
      "jenis_barang": jenisBarangId.toString(),
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data inventaris");
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  /// 🔹 Ambil semua jenis barang
  static Future<List<dynamic>> getJenisBarang() async {
    final uri = ApiConfig.uri("getjenisbarang.php");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data jenis barang");
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getAllUsers() async {
    final uri = ApiConfig.uri("getusers.php");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data users");
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<List<dynamic>> getLokasi() async {
    final uri = ApiConfig.uri("getlokasi.php");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return data['data'];
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil data lokasi');
    }
  }

  static Future<Map<String, dynamic>> addPindahtangan({
    required String nomor,
    required String tanggal,
    required String kelompok,
    required String inventarisId,
    required String asalId,
    required String alamatLama,
    required String baruId,
    required String alamatBaru,
    required String ket,
    required String lokasi,
  }) async {
    final uri = ApiConfig.uri("addpindahtangan.php");
    final response = await http.post(
      uri,
      body: {
        'nomor': nomor,
        'tanggal': tanggal,
        'kelompok': kelompok,
        'inventaris_id': inventarisId,
        'asal_id': asalId,
        'alamat_lama': alamatLama,
        'baru_id': baruId,
        'alamat_baru': alamatBaru,
        'ket': ket,
        'lokasi': lokasi,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengirim data');
    }
  }

  static Future<Map<String, dynamic>> updatePindahtangan({
    required String id,
    required String nomor,
    required String tanggal,
    required String kelompok,
    required String inventarisId,
    required String asalId,
    required String alamatLama,
    required String baruId,
    required String alamatBaru,
    required String ket,
    required String lokasi,
  }) async {
    final url = ApiConfig.uri("updatepindahtangan.php");

    final response = await http.post(
      url,
      body: {
        'id': id,
        'nomor': nomor,
        'tanggal': tanggal,
        'kelompok': kelompok,
        'inventaris_id': inventarisId,
        'asal_id': asalId,
        'alamat_lama': alamatLama,
        'baru_id': baruId,
        'alamat_baru': alamatBaru,
        'ket': ket,
        'lokasi': lokasi,
      },
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (_) {
        return {'status': 'error', 'message': 'Respon server tidak valid'};
      }
    } else {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> addPerpindahanDBR({
    required String nomor,
    required String tanggal,
    required String pelaporid,
    required String barangId,
    required String ruanganBaruId,
    required String ruanganLamaId,
    required String keterangan,
  }) async {
    final url = ApiConfig.uri("addperpindahandbr.php");

    final response = await http.post(
      url,
      body: {
        "nomor": nomor,
        "tanggal": tanggal,
        "pelaporid": pelaporid,
        "barangId": barangId,
        "ruanganLamaId": ruanganLamaId,
        "ruanganBaruId": ruanganBaruId,
        "keterangan": keterangan,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengirim data perpindahan DBR.");
    }
  }

  static Future<String?> generateNomor() async {
    try {
      final url = ApiConfig.uri("generatenoperpindahandbr.php");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          return data["nomor"];
        } else {
          print("Gagal generate nomor: ${data['message']}");
          return null;
        }
      } else {
        print("Server error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error saat memanggil API generate nomor: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> getAllPerpindahanDBR() async {
    final uri = ApiConfig.uri("getperpindahandbr.php");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Gagal mengambil data perpindahan DBR");
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updatePerpindahanDBR({
    required String id,
    required String nomor,
    required String tanggal,
    required String pelaporid,
    required String barangId,
    required String ruanganBaruId,
    required String ruanganLamaId,
    required String keterangan,
  }) async {
    final url = ApiConfig.uri("updateperpindahandbr.php");

    final response = await http.post(
      url,
      body: {
        "id": id,
        "nomor": nomor,
        "tanggal": tanggal,
        "pelaporid": pelaporid,
        "barangId": barangId,
        "ruanganLamaId": ruanganLamaId,
        "ruanganBaruId": ruanganBaruId,
        "keterangan": keterangan,
      },
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {"status": "error", "message": "Respon server tidak valid"};
      }
    } else {
      return {"status": "error", "message": "Gagal menghubungi server"};
    }
  }
}
