// import 'dart:convert';
// import 'dart:math';
// import 'package:belnet_lib/belnet_lib.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class NodeProvider extends ChangeNotifier {
// //  bool isLoading = false;

// //   int selectedTab = 0;

// //   int? selectedNodeId;

// //   List<dynamic> beldexNodes = [];
// //   List<dynamic> contributorNodes = [];

// //   Future<void> getNodes() async {
// //     try {
// //       isLoading = true;
// //       notifyListeners();

// //       final response = await http.get(
// //         Uri.parse(
// //           "https://belnet-exitnode.s3.ap-south-1.amazonaws.com/exitnode-bns-list/exitnode_info_list.json",
// //         ),
// //       );

// //       final data = jsonDecode(response.body);

// //       beldexNodes = data[0]["node"];
// //       contributorNodes = data[1]["node"];

// //       isLoading = false;
// //       notifyListeners();
// //     } catch (e) {
// //       isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   void changeTab(int index) {
// //     selectedTab = index;
// //     notifyListeners();
// //   }

// //   void selectNode(int id) {
// //     selectedNodeId = id;
// //     notifyListeners();
// //   }

// //   List<dynamic> get currentNodes =>
// //       selectedTab == 0
// //           ? beldexNodes
// //           : contributorNodes;

// //   Map<String, List<dynamic>> get groupedNodes {
// //     final Map<String, List<dynamic>> grouped = {};

// //     for (var node in currentNodes) {
// //       final country = node["country"];

// //       grouped.putIfAbsent(
// //         country,
// //         () => [],
// //       );

// //       grouped[country]!.add(node);
// //     }

// //     return grouped;
// //   }




// }



