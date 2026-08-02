// api_service.dart
//
// Klien HTTP terpusat untuk berbicara dengan backend Laravel (lihat
// backend_laravel/API_CONTRACT.md). Firebase (Auth/Firestore/Messaging/
// Crashlytics) sudah dihapus total dari aplikasi ini; seluruh data (auth,
// keranjang, alamat, pesanan, chat) sekarang lewat REST API ini dengan token
// Sanctum yang disimpan oleh AuthService.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

/// Exception dengan pesan error yang sudah diformat dari server (status code +
/// pesan asli), supaya UI bisa menampilkan sesuatu yang berarti alih-alih
/// "Exception: Error GET: ..." generik seperti sebelumnya.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  // GANTI dengan alamat IP LAN komputer yang menjalankan `php artisan serve`
  // (bukan localhost/127.0.0.1 kalau diuji dari HP fisik/emulator berbeda
  // jaringan). Contoh: 'http://192.168.1.10:8000/api'
  static const String baseUrl = 'https://backend-ecommerce.synectra.xyz/api';

  static const Duration _timeout = Duration(seconds: 15);

  final TokenStorage _tokenStorage;

  ApiService({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? const TokenStorage(FlutterSecureStorage());

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _tokenStorage.read();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      return {};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = _decode(response);
    final isOk = response.statusCode >= 200 && response.statusCode < 300;
    final serverStatus = data['status'];

    if (isOk && (serverStatus == null || serverStatus == 'success')) {
      return data;
    }

    final dataPayload = data['data'];
    String? serverMsg = data['message']?.toString() ?? data['error']?.toString();
    if (serverMsg == null && dataPayload is Map) {
      serverMsg = dataPayload['message']?.toString() ?? dataPayload['error']?.toString();
    }

    String message = serverMsg ?? _fallbackMessageForStatus(response.statusCode);
    throw ApiException(message, statusCode: response.statusCode);
  }

  String _fallbackMessageForStatus(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Sesi berakhir, silakan masuk kembali.';
      case 403:
        return 'Anda tidak memiliki akses untuk aksi ini.';
      case 404:
        return 'Data tidak ditemukan.';
      case 422:
        return 'Data yang dikirim tidak valid.';
      case 500:
      case 502:
      case 503:
        return 'Server sedang bermasalah, coba lagi nanti.';
      default:
        return 'Terjadi kesalahan (kode $statusCode).';
    }
  }

  ApiException _wrapNetworkError(Object e) {
    if (e is ApiException) return e;
    if (e is TimeoutException) {
      return ApiException('Koneksi ke server timeout. Periksa jaringan Anda.');
    }
    if (e is SocketException) {
      return ApiException('Tidak dapat terhubung ke server. Periksa koneksi/alamat server.');
    }
    return ApiException('Terjadi kesalahan: $e');
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool withAuth = true}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: await _headers(withAuth: withAuth))
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) debugPrint('GET $endpoint failed: $e');
      throw _wrapNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {bool withAuth = true}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(withAuth: withAuth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) debugPrint('POST $endpoint failed: $e');
      throw _wrapNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body, {bool withAuth = true}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(withAuth: withAuth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) debugPrint('PUT $endpoint failed: $e');
      throw _wrapNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {Map<String, dynamic>? body, bool withAuth = true}) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(withAuth: withAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) debugPrint('DELETE $endpoint failed: $e');
      throw _wrapNetworkError(e);
    }
  }
}
