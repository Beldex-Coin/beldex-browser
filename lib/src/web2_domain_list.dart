import 'package:flutter/services.dart' show rootBundle;


class Web2DomainList {
  Set<String> web2Tlds = {};

  ///  INIT (call once on app start)
  Future<void> init() async {
    await _loadFromAssets();

    // Safety fallback (just in case file fails)
    if (web2Tlds.isEmpty) {
      web2Tlds = {"com", "org", "net"};
      print("Fallback TLDs loaded");
    }
  }

  ///  Load from assets
  Future<void> _loadFromAssets() async {
    try {
      final data = await rootBundle.loadString('assets/tldList.txt');

      final lines = data.split("\n");

      web2Tlds = lines
          .where((line) =>
              line.trim().isNotEmpty &&
              !line.startsWith("#"))
          .map((e) => e.trim().toLowerCase())
          .toSet();

      print("Loaded ${web2Tlds.length} TLDs from assets");
    } catch (e) {
      print("Failed to load TLDs from assets: $e");
    }
  }

  /// 🌍 DOMAIN CHECK
  bool isWeb2Domain(String input) {
    if (!input.contains(".")) return false;

    final parts = input.split(".");
    final tld = parts.last.toLowerCase();

    return web2Tlds.contains(tld);
  }
}
