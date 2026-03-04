import 'package:newapp/api/pinjam_api.dart';

class HistoryLaporanApi {
  static Future<List<Map<String, dynamic>>> getHistoryPinjam(int userId) async {
    return await PinjamApi.getHistoryPinjam(userId: userId);
  }
}
