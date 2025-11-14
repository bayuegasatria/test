class ApiConfig {
  static const String baseUrl = "http://192.168.0.119/API";

  static Uri uri(String endpoint, [Map<String, String>? params]) {
    final url = Uri.parse("$baseUrl/$endpoint");
    return params != null ? url.replace(queryParameters: params) : url;
  }
}
