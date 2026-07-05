
import 'dart:convert';
import 'dart:math';

import 'package:beldex_browser/src/utils/screen_secure_provider.dart';
import 'package:belnet_lib/belnet_lib.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beldex_browser/src/model/exitnodeCategoryModel.dart'
    as exitNodeModel;
class UserPosition {
  final double latitude;
  final double longitude;
  final String country;

  UserPosition({
    required this.latitude,
    required this.longitude,
    required this.country,
  });
}

///  Get user location (lat, long, country) using free IP API
// Future<UserPosition> getUserLocationFromAPI() async {
//   final response = await http.get(Uri.parse('https://ipapi.co/json/'));

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return UserPosition(
//       latitude: (data['latitude'] ?? 0).toDouble(),
//       longitude: (data['longitude'] ?? 0).toDouble(),
//       country: data['country_name'] ?? 'Unknown',
//     );
//   } else {
//     throw Exception('Failed to fetch location from IP');
//   }
// }
// Latency audit fix 7: the geo-IP lookup sat on the connect critical path
// with no timeout and no caching (and one fallback went over plain http).
// The result is now cached for 30 minutes, every request has a 5-second
// timeout, and both providers are HTTPS.
const Duration _geoHttpTimeout = Duration(seconds: 5);
const Duration _geoCacheTtl = Duration(minutes: 30);

Future<UserPosition> getUserLocationFromAPI() async {
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
    final cachedAtMs = prefs.getInt('geoIp.time') ?? 0;
    final cached = prefs.getString('geoIp.data');
    if (cached != null &&
        DateTime.now().millisecondsSinceEpoch - cachedAtMs <
            _geoCacheTtl.inMilliseconds) {
      final data = jsonDecode(cached);
      return UserPosition(
        latitude: (data['latitude'] ?? 0).toDouble(),
        longitude: (data['longitude'] ?? 0).toDouble(),
        country: data['country'] ?? 'Unknown',
      );
    }
  } catch (_) {}

  Future<UserPosition?> tryProvider(
      String url, UserPosition? Function(dynamic data) parse) async {
    try {
      final res =
          await http.get(Uri.parse(url)).timeout(_geoHttpTimeout);
      if (res.statusCode == 200) {
        return parse(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  final position = await tryProvider(
        'https://ipwho.is/',
        (data) => UserPosition(
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
          country: normalizeCountryName(data['country']),
        ),
      ) ??
      await tryProvider(
        'https://ipapi.co/json/',
        (data) => UserPosition(
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
          country: normalizeCountryName(data['country_name']),
        ),
      );

  if (position != null) {
    try {
      await prefs?.setString(
          'geoIp.data',
          jsonEncode({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'country': position.country,
          }));
      await prefs?.setInt(
          'geoIp.time', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
    return position;
  }

  // All failed -> return a safe fallback, do NOT throw
  return UserPosition(latitude: 0, longitude: 0, country: "Unknown");
}

/// Haversine formula to calculate distance in km
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Earth radius in km
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}


String normalizeCountryName(String? country) {
  if (country == null || country.trim().isEmpty) return "Unknown";
  country = country.trim();

  final replacements = {
    "The Netherlands": "Netherlands",
    "Republic of Lithuania": "Lithuania",
    "United States": "USA",
    "United Kingdom": "UK",
    "Republic of Korea": "South Korea",
    "Russian Federation": "Russia",
  };

  for (final entry in replacements.entries) {
    if (country.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }

  return country;
}


///  Main logic to find nearest node
Future<Map<String, dynamic>> findNearestNode({
  required List<exitNodeModel.ExitNodeDataList> nodeLists,
  required BasicProvider basicProvider,
}) async {
  final userPos = await getUserLocationFromAPI();

  // Flatten all nodes from all nodeLists
  final allNodes = nodeLists.expand((list) => list.node).toList();

  // Latency audit fix 7: excluding the user's own country guarantees
  // cross-border RTT even when a domestic exit exists. Keep the current
  // (privacy-friendly) behaviour as the default, but make it a preference
  // so it can be exposed as a setting.
  final prefs = await SharedPreferences.getInstance();
  final excludeOwnCountry = prefs.getBool('excludeOwnCountryNodes') ?? true;

  var filteredNodes = excludeOwnCountry
      ? allNodes.where((n) => n.country != userPos.country).toList()
      : List.of(allNodes);

  // Never fail outright: fall back to the full list instead of throwing
  // when filtering leaves nothing usable.
  if (filteredNodes.isEmpty) {
    filteredNodes = List.of(allNodes);
  }
  if (filteredNodes.isEmpty) {
    throw Exception("No exit nodes available.");
  }

  exitNodeModel.Node finalNode;

  if (basicProvider.autoConnect && BelnetLib.isConnected == false) {
    // Step 1: Keep only nodes with non-zero speedScore
    List<exitNodeModel.Node> nonZeroNodes = filteredNodes.where((n) => n.speedScore > 0).toList();

    //  If no non-zero nodes, fallback to all nodes
    if (nonZeroNodes.isEmpty) nonZeroNodes = filteredNodes;

    // Find nearest node from this filtered list
    exitNodeModel.Node nearestNode = nonZeroNodes.first;
    double minDistance = double.infinity;

    for (var node in nonZeroNodes) {
      double dist = calculateDistance(
       // 45.424721, -75.695000,
        userPos.latitude,
        userPos.longitude,
        node.lat,
        node.long,
      );
      if (dist < minDistance) {
        minDistance = dist;
        nearestNode = node;
      }
    }

    //  Get all nodes in that nearest node’s country
    List<exitNodeModel.Node> sameCountryNodes =
        nonZeroNodes.where((n) => n.country == nearestNode.country).toList();

    //  Sort by speedScore rank (1 = best) then distance.
    //  Latency audit fix 7: unrated nodes (speedScore == 0) must sort AFTER
    //  rated ones. When the earlier non-zero filter falls back to the full
    //  list, the old ascending sort put the unrated (0) nodes FIRST and the
    //  autoconnect picked one of them.
    int rankOf(exitNodeModel.Node n) =>
        n.speedScore == 0 ? 1 << 30 : n.speedScore;
    sameCountryNodes.sort((a, b) {
      int speedCompare = rankOf(a).compareTo(rankOf(b));
      if (speedCompare != 0) return speedCompare;

      double distA = calculateDistance(userPos.latitude, userPos.longitude, a.lat, a.long);
      double distB = calculateDistance(userPos.latitude, userPos.longitude, b.lat, b.long);
      return distA.compareTo(distB);
    });

    finalNode = sameCountryNodes.first;
  } else {
    // AutoConnect disabled → just find absolutely nearest node
    exitNodeModel.Node nearestNode = filteredNodes.first;
    double minDistance = double.infinity;

    for (var node in filteredNodes) {
      double dist = calculateDistance(
        //45.424721, -75.695000,
        userPos.latitude,
        userPos.longitude,
        node.lat,
        node.long,
      );
      if (dist < minDistance) {
        minDistance = dist;
        nearestNode = node;
      }
    }

//  Find all nodes within 20% distance margin of nearest
    double range = minDistance * 1.2; // 20% margin
    List<exitNodeModel.Node> nearbyNodes = filteredNodes.where((node) {
      double dist = calculateDistance(
        userPos.latitude,
        userPos.longitude,
        node.lat,
        node.long,
      );
      return dist <= range;
    }).toList();

    // Step 3: Randomly pick one
    final random = Random();
    finalNode = nearbyNodes[random.nextInt(nearbyNodes.length)];







   // finalNode = nearestNode;
  //  print('User changed country without autoconnect is ${finalNode.name} SpeedScore is ${finalNode.speedScore} country ${finalNode.country}');
  }

  return {
    "id": finalNode.id,
    "name": finalNode.name,
    "icon": finalNode.icon,
    "country": finalNode.country,
    "lat": finalNode.lat,
    "long": finalNode.long,
    "speedScore": finalNode.speedScore,
  };
}