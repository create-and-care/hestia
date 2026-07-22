import 'dart:convert';

import 'package:http/http.dart' as http;

/// HTTP client for Hestia's `api/v1` API. No business logic
/// here: the mobile client only relays calls, every business rule lives
/// server-side to guarantee identical behavior with the web.
class ApiClient {
  ApiClient({required this.baseUrl, this.token});

  /// Ex. https://mon-instance-hestia.example.com/api/v1
  final String baseUrl;
  String? token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic> body = const {}]) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode == 401) {
      throw ApiUnauthorizedException();
    }
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}

class ApiUnauthorizedException extends ApiException {
  ApiUnauthorizedException() : super(401, 'unauthorized');
}
