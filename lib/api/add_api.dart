import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AddApi {
  static Future<bool> simpanPengajuan(
    BuildContext context, {
    required String idUser,
    required String noPengajuan,
    required String tujuan,
    required String jenisKendaraan,
    required String perluSupir,
    required String pengemudi,
    required String tanggalBerangkat,
    required String tanggalKembali,
    required String jumlahPengguna,
    required String keterangan,
    File? fileLampiran,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        ApiConfig.uri("addpengajuanapi.php"),
      );

      request.fields.addAll({
        "id_user": idUser,
        "no_pengajuan": noPengajuan,
        "tujuan": tujuan,
        "jenis_kendaraan": jenisKendaraan,
        "perlu_supir": perluSupir,
        "pengemudi": pengemudi,
        "tanggal_berangkat": tanggalBerangkat,
        "tanggal_kembali": tanggalKembali,
        "jumlah_pengguna": jumlahPengguna,
        "keterangan": keterangan,
        "status": "P",
      });

      if (fileLampiran != null && await fileLampiran.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('file', fileLampiran.path),
        );
      }

      var response = await request.send();
      var resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody);
        if (data['success'] == true) {
          return true;
        } else {
          showSnack(
            context,
            data['message'] ?? "⚠️ Gagal menyimpan pengajuan.",
          );
          return false;
        }
      } else {
        showSnack(context, "Server error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      showSnack(context, "Terjadi kesalahan koneksi: $e");
      return false;
    }
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
