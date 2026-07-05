import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Thrown when the Belnet bootstrap file cannot be downloaded/validated.
class BootstrapException implements Exception {
  final String message;
  BootstrapException(this.message);

  @override
  String toString() => 'BootstrapException: $message';
}

class BelnetLib {
  static const MethodChannel _methodChannel =
      const MethodChannel('belnet_lib_method_channel');

  static const String _bootstrapUrl =
      'https://belnet-exitnode.s3.ap-south-1.amazonaws.com/bootstrap-files/bootstrap.signed';

  /// A valid bootstrap file is expected to be well above this size; a smaller
  /// file is almost certainly a truncated/failed download.
  static const int _minBootstrapBytes = 1024;

  /// Re-download the bootstrap file in the background once it is older than
  /// this, so the relay list does not go stale.
  static const Duration _bootstrapMaxAge = Duration(days: 7);

  static const EventChannel _isConnectedEventChannel =
      const EventChannel('belnet_lib_is_connected_event_channel');

  static bool _isConnected = false;

  static bool get isConnected => _isConnected;

  static Stream<bool> _isConnectedEventStream = _isConnectedEventChannel
      .receiveBroadcastStream()
      .cast<bool>()
    ..listen((dynamic newIsConnected) => _isConnected = newIsConnected);

  static Stream<bool> get isConnectedEventStream => _isConnectedEventStream;

  static Future<File> _bootstrapFile() async {
    final path = await getApplicationDocumentsDirectory();
    return File('${path.parent.path}/files/bootstrap.signed');
  }

  /// Downloads the bootstrap file atomically:
  /// - writes to a temp file first, renames over the real file only on success
  /// - 15s network timeouts, 3 attempts with exponential backoff
  /// - rejects suspiciously small (truncated) downloads
  ///
  /// Throws [BootstrapException] if all attempts fail. A failed attempt can
  /// never leave a corrupt bootstrap.signed behind.
  static Future bootstrapBelnet() async {
    final target = await _bootstrapFile();
    final tmp = File('${target.path}.tmp');
    Object? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15);
      try {
        final request = await client
            .getUrl(Uri.parse(_bootstrapUrl))
            .timeout(const Duration(seconds: 15));
        final response =
            await request.close().timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw BootstrapException(
              'unexpected HTTP status ${response.statusCode}');
        }
        await response
            .pipe(tmp.openWrite())
            .timeout(const Duration(seconds: 30));
        if (!tmp.existsSync() || tmp.lengthSync() < _minBootstrapBytes) {
          throw BootstrapException(
              'downloaded file too small (${tmp.existsSync() ? tmp.lengthSync() : 0} bytes)');
        }
        tmp.renameSync(target.path);
        return;
      } catch (e) {
        lastError = e;
        try {
          if (tmp.existsSync()) tmp.deleteSync();
        } catch (_) {}
        // Exponential backoff: 1s, 2s.
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: 1 << attempt));
        }
      } finally {
        client.close(force: true);
      }
    }
    throw BootstrapException('download failed after 3 attempts: $lastError');
  }

  /// Deletes the local bootstrap file so the next [prepareConnection] fetches
  /// a fresh one. Used to self-heal after repeated connection failures caused
  /// by a stale or corrupt bootstrap.
  static Future<void> resetBootstrap() async {
    try {
      final f = await _bootstrapFile();
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  /// Best-effort background refresh of a bootstrap file older than
  /// [_bootstrapMaxAge]. Never throws and never blocks the connect flow.
  static Future<void> _refreshBootstrapIfStale() async {
    try {
      final f = await _bootstrapFile();
      if (f.existsSync() &&
          DateTime.now().difference(f.lastModifiedSync()) > _bootstrapMaxAge) {
        await bootstrapBelnet();
      }
    } catch (_) {
      // Background refresh is best-effort; the existing file keeps working.
    }
  }

  static Future<bool> prepareConnection() async {
    if (!(await isBootstrapped)) {
      // No valid bootstrap: this must succeed before we can connect.
      // BootstrapException propagates to the caller so the UI can react.
      await bootstrapBelnet();
    } else {
      // Valid bootstrap present: refresh it in the background if stale.
      // ignore: unawaited_futures
      _refreshBootstrapIfStale();
    }
    final bool prepare = await _methodChannel.invokeMethod('prepare');
    return prepare;
  }

//conncting belnet
  static Future<bool> connectToBelnet(
      //"9.9.9.9"
      {String exitNode =
          "7a4cpzri7qgqen9a3g3hgfjrijt9337qb19rhcdmx5y7yttak33o.bdx",
      String upstreamDNS = "9.9.9.9"}) async {
        print('connecting exitnode is -----> $exitNode');
    final bool connect = await _methodChannel.invokeMethod(
        'connect', {"exit_node": exitNode, "upstream_dns": upstreamDNS});

    return connect;
  }

  static Future<bool> disconnectFromBelnet() async {
    final bool disconnect = await _methodChannel.invokeMethod('disconnect');

    return disconnect;
  }

// is prepared function
  static Future<bool> get isPrepared async {
    final bool prepared = await _methodChannel.invokeMethod('isPrepared');

    return prepared;
  }

  static Future<bool> get isRunning async {
    final bool isRunning = await _methodChannel.invokeMethod('isRunning');
    return isRunning;
  }

//isbootstrap function
  static Future<bool> get isBootstrapped async {
    final f = await _bootstrapFile();
    // Existence alone is not enough: an interrupted download used to leave a
    // truncated file behind that permanently broke path building.
    return f.existsSync() && f.lengthSync() >= _minBootstrapBytes;
  }

  static Future<dynamic> get status async {
    var status = await _methodChannel.invokeMethod('getStatus') as String;
    if (status.isNotEmpty) return jsonDecode(status);
    return null;
  }

  static Future<dynamic> get upload async {
    var uploadStatus = await _methodChannel.invokeMethod('getUploadSpeed');
    return uploadStatus;
  }

  static Future<dynamic> get download async {
    var downloadStatus = await _methodChannel.invokeMethod('getDownloadSpeed');
    return downloadStatus;
  }

  static Future<String> get logDetails async {
    var logD;
    // try{
    logD = await _methodChannel.invokeMethod("logData");

    print("this is from log data $logD");

    return logD;
  }

  static Future<dynamic> get getSpeedStatus async {
    var status = await _methodChannel.invokeMethod('getDataStatus') as String;
    if (status.isNotEmpty) return jsonDecode(status);
    return null;
  }


static Future<bool> isDisconnectForBelnetNotification() async {
    final bool disconnect = await _methodChannel.invokeMethod('disconnectForNotification');

    return disconnect;
  }

static Future<dynamic>  unmapExitNode(String swapNode) async {
    final dynamic isUnmap = await _methodChannel.invokeMethod('getMap',{"swap_node": swapNode});
    return isUnmap;
  }


  static Future<dynamic> get statusUnmapExitNode async {
    final dynamic isUnmap = await _methodChannel.invokeMethod('getUnmapStatus');
    return isUnmap;
  }

  static Future<bool> setDefaultApp()async{
  final bool setApp = await _methodChannel.invokeMethod("setDefaultBrowser");
  return setApp;
}

 static Future<bool> enableScreenSecurity()async{
  final bool setScnApp = await _methodChannel.invokeMethod("enableSecure");
  return setScnApp;
}


 static Future<bool> disableScreenSecurity()async{
  final bool setScnApp = await _methodChannel.invokeMethod("disableSecure");
  return setScnApp;
}


 static Future<void> requestFocus() async {
    try {
      await _methodChannel.invokeMethod('requestAudioFocus');
    } catch (e) {
      print('Error requesting focus: $e');
    }
  }

 static Future<void> abandonFocus() async {
    try {
      await _methodChannel.invokeMethod('abandonAudioFocus');
    } catch (e) {
      print('Error abandoning focus: $e');
    }
  }

  static Future<bool> isCallActive()async{
     try {
    final result = await _methodChannel.invokeMethod<bool>('isCallActive');
    return result ?? false;
  } catch (e) {
    print('Error checking call state: $e');
    return false;
  }
   
   
   
  //   try{

  //  final bool isActive =  await _methodChannel.invokeMethod('isCallActive');
  //  return isActive;
  //   }catch(e){

  //     print('Error checking is call active: $e');
  //     return false;
  //   }
  }
}
