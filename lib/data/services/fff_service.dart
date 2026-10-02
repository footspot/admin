import 'dart:convert';
import 'dart:io';

import 'package:cronet_http/cronet_http.dart';
import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

final fffService = FffService();

class FffService {
  FffService._privateConstructor();
  factory FffService() => _singleton;
  static final FffService _singleton = FffService._privateConstructor();

  static const _base = 'https://api-dofa.fff.fr/api';

  // * FFF's WAF JA3-blocks Deno (edge functions) AND Dart's default HTTP
  // * client. Only a real browser fingerprint passes, so on Android we route
  // * the FFF call through Cronet (Chromium's network stack = Chrome's TLS/
  // * HTTP-2 fingerprint). The result is handed to the 'add-new-club' edge
  // * function, which only persists it. See [[fff-api-deno-ua-block]].
  http.Client _client() {
    if (Platform.isAndroid) {
      final engine = CronetEngine.build(
        userAgent:
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      );
      return CronetClient.fromCronetEngine(engine, closeEngine: true);
    }
    // * Non-Android fallback (won't bypass the WAF — Android is the target).
    return IOClient(
      HttpClient()
        ..userAgent =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    );
  }

  Map<String, String> get _headers => {
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,'
        'image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8',
    'Referer': 'https://www.fff.fr/',
  };

  // * Fetch the raw FFF club payload plus, best-effort, its logo bytes
  // * (base64). Returns null on any failure so the caller surfaces a clean
  // * "add club failed" rather than crashing.
  Future<Map<String, dynamic>?> fetchClub(int clubNbr) async {
    final client = _client();
    try {
      final res = await client.get(
        Uri.parse('$_base/clubs/$clubNbr'),
        headers: _headers,
      );

      if (res.statusCode != 200) {
        logLocal.addLog(
          LogEntity(
            message: 'FFF club fetch HTTP ${res.statusCode}',
            source: 'fffService.fetchClub($clubNbr)',
          ),
        );
        return null;
      }

      final club = jsonDecode(res.body) as Map<String, dynamic>;

      String? logoBase64;
      String? logoContentType;
      final logoUrl = club['logo'];
      if (logoUrl is String && logoUrl.isNotEmpty) {
        try {
          final logoRes = await client.get(
            Uri.parse(logoUrl),
            headers: _headers,
          );
          if (logoRes.statusCode == 200 && logoRes.bodyBytes.isNotEmpty) {
            logoBase64 = base64Encode(logoRes.bodyBytes);
            logoContentType = logoRes.headers['content-type'] ?? 'image/jpeg';
          }
        } catch (_) {
          // * Logo is optional — never block club creation on it.
        }
      }

      return {
        'fffClub': club,
        'logoBase64': logoBase64,
        'logoContentType': logoContentType,
      };
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'fffService.fetchClub($clubNbr)',
        ),
      );
      return null;
    } finally {
      client.close();
    }
  }
}
