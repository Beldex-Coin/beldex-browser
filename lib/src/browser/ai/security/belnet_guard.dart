import 'dart:async';

import 'package:belnet_lib/belnet_lib.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// Thrown (or wrapped in a [DioException]) when an AI request is
/// refused because the Belnet tunnel is not up.
class BelnetTunnelDownException implements Exception {
  const BelnetTunnelDownException();

  @override
  String toString() =>
      'BelnetTunnelDownException: AI request blocked, Belnet is not connected';
}

/// Fail-closed gate for every AI network request.
///
/// Belnet's VpnService only admits this app, but when the tunnel is
/// down Android quietly sends our traffic over the normal network.
/// AI requests carry the user's prompts and files, so they are only
/// allowed while BOTH hold:
///   * the Belnet daemon reports it is running, and
///   * this app's active network is a VPN.
/// Any error while checking counts as "down".
class BelnetGuard {
  BelnetGuard._();

  /// Shown wherever an AI request is refused.
  static const String aiBlockedMessage =
      'Beldex AI works only over Belnet. Connect to Belnet and try '
      'again. Nothing was sent.';

  static Future<bool> isTunnelUp() async {
    try {
      final bool running = await BelnetLib.isRunning;
      if (!running) return false;

      return await BelnetLib.isVpnTransportActive;
    } catch (_) {
      return false;
    }
  }

  /// Throws [BelnetTunnelDownException] unless the tunnel is up.
  static Future<void> ensureTunnelUp() async {
    if (!await isTunnelUp()) {
      throw const BelnetTunnelDownException();
    }
  }

  /// True if [error] (possibly wrapped by Dio) is a guard refusal.
  static bool isTunnelDownError(Object? error) {
    if (error is BelnetTunnelDownException) return true;
    if (error is DioException) {
      return error.error is BelnetTunnelDownException;
    }
    return false;
  }
}

/// Rejects every Dio request while the tunnel is down. The request
/// never reaches the network.
class BelnetGuardInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (await BelnetGuard.isTunnelUp()) {
      handler.next(options);
      return;
    }

    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        error: const BelnetTunnelDownException(),
        message: 'Blocked: Belnet is not connected',
      ),
    );
  }
}

/// `http` client that refuses to send while the tunnel is down.
class BelnetGuardedHttpClient extends http.BaseClient {
  BelnetGuardedHttpClient([http.Client? inner])
      : _inner = inner ?? http.Client();

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await BelnetGuard.ensureTunnelUp();
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

/// Creates a Dio instance for AI traffic. Use this instead of `Dio()`
/// anywhere AI code talks to the network.
Dio createAiDio([BaseOptions? options]) {
  final dio = Dio(options);
  dio.interceptors.add(BelnetGuardInterceptor());
  return dio;
}

/// Shared `http` client for AI traffic. Use `aiHttp.post(...)` instead
/// of `http.post(...)`.
final BelnetGuardedHttpClient aiHttp = BelnetGuardedHttpClient();
