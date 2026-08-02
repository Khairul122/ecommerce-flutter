import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

/// Exception dengan pesan yang berarti (kode status + pesan dari server),
/// menggantikan `Exception('Error: $e')` generik yang sebelumnya menelan
/// detail error (mis. 401/422 dari backend) menjadi pesan tak berguna.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://backend-ecommerce.synectra.xyz/api';

  static const Duration _timeout = Duration(seconds: 15);

  final TokenStorage _tokenStorage;

  ApiService({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? const TokenStorage(FlutterSecureStorage());

  Future<Map<String, String>> _headers({
    bool auth = true,
    bool withContentType = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (withContentType) headers['Content-Type'] = 'application/json';
    if (auth) {
      final token = await _tokenStorage.read();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool auth = true}) {
    return _send(() async {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout);
      return response;
    });
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) {
    return _send(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return response;
    });
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) {
    return _send(() async {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return response;
    });
  }

  Future<Map<String, dynamic>> delete(String endpoint, {bool auth = true}) {
    return _send(() async {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout);
      return response;
    });
  }

  /// Upload file (foto profil/produk) via multipart/form-data.
  /// Menggantikan firebase_storage. Field default "file" sesuai kontrak
  /// `POST /upload` -> `{url}`.
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String field = 'file',
  }) {
    return _send(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(await _headers(withContentType: false));
      request.files.add(await http.MultipartFile.fromPath(field, file.path));
      final streamed = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamed);
    });
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request();
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Koneksi ke server timeout. Periksa jaringan Anda atau alamat '
        'baseUrl di api_service.dart.',
      );
    } on SocketException catch (e) {
      throw ApiException('Tidak dapat terhubung ke server: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kesalahan tak terduga: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Respons server tidak valid (kode ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final isSuccess = response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['status'] != 'error';

    if (isSuccess) return data;

    final message = (data['message'] as String?) ??
        'Terjadi kesalahan (kode ${response.statusCode})';
    throw ApiException(
      message,
      statusCode: response.statusCode,
      errors: data['errors'] as Map<String, dynamic>?,
    );
  }
}
