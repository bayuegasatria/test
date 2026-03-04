class ApiConfig {
  static const String baseUrl = "http://192.168.1.9/API";

  static Uri uri(String endpoint, [Map<String, String>? params]) {
    final url = Uri.parse("$baseUrl/$endpoint");
    return params != null ? url.replace(queryParameters: params) : url;
  }
}
