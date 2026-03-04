import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class KinerjaSupirApi {
  static Future<List<Map<String, dynamic>>> getKinerjaSupir(int supirId) async {
    final res = await http.get(
      ApiConfig.uri("gethistorysupir.php", {"supirId": "$supirId"}),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
