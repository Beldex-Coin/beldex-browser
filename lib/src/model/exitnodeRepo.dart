import 'dart:async';

import 'package:beldex_browser/src/model/exitnodeCategoryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'exitnodeModel.dart';
import 'package:http/http.dart' as http;

/// Latency audit fix 7: the exit-node lists used to be fetched fresh from S3
/// on every app launch with no timeout, and the full multi-hundred-KB JSON
/// response was print()ed to the console on the UI isolate. The lists are
/// now cached in SharedPreferences with a 6-hour TTL, all requests have a
/// 5-second timeout, and a stale cache is used as a fallback when the
/// network request fails — so a slow CDN can no longer stall startup or the
/// connect flow.
class DataRepo {
  static const Duration _httpTimeout = Duration(seconds: 5);
  static const Duration _cacheTtl = Duration(hours: 6);

  /// Fetch [url] with caching. Returns the freshest body available:
  /// fresh cache -> network (updating the cache) -> stale cache -> null.
  Future<String?> _getWithCache(String url, String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    final cachedAtMs = prefs.getInt('$cacheKey.time') ?? 0;
    final isFresh = DateTime.now().millisecondsSinceEpoch - cachedAtMs <
        _cacheTtl.inMilliseconds;

    if (cached != null && cached.isNotEmpty && isFresh) {
      return cached;
    }

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(_httpTimeout);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        await prefs.setString(cacheKey, response.body);
        await prefs.setInt(
            '$cacheKey.time', DateTime.now().millisecondsSinceEpoch);
        return response.body;
      }
    } catch (_) {
      // Fall through to the stale cache below.
    }
    return cached;
  }

  Future<List<ExitnodeList>> getDataFromNet() async {
    final body = await _getWithCache(
        'https://deb.beldex.io/Beldex-projects/Belnet/exitlist.json',
        'cache.exitlist');
    if (body == null) {
      throw Exception('Exit-node list unavailable (no network, no cache)');
    }
    return exitnodeListFromJson(body);
  }

  Future<List<ExitNodeDataList>> getListData() async {
    final body = await _getWithCache(
        'https://belnet-exitnode.s3.ap-south-1.amazonaws.com/exitnode-bns-list/exitnode-bns-list.json',
        'cache.exitnodeBnsList');
    if (body == null) {
      throw Exception('Exit-node list unavailable (no network, no cache)');
    }
    return exitNodeDataListFromJson(body);
  }

  Future<List<ExitNodeDataList>> getExitnodeInfoListData() async {
    final body = await _getWithCache(
        'https://belnet-exitnode.s3.ap-south-1.amazonaws.com/exitnode-bns-list/exitnode_info_list.json',
        'cache.exitnodeInfoList');
    if (body == null) {
      throw Exception('Exit-node list unavailable (no network, no cache)');
    }
    return exitNodeDataListFromJson(body);
  }
}
