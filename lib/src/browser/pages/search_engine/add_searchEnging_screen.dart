import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:beldex_browser/constants_key.dart';
import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/security/api_key_manager.dart';
import 'package:beldex_browser/src/browser/models/search_engine_model.dart';
import 'package:beldex_browser/src/browser/pages/search_engine/add_searchengine_provider.dart';
import 'package:beldex_browser/src/browser/pages/settings/search_settings_page.dart';
import 'package:beldex_browser/src/utils/show_message.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

enum AIModelType {
  chatgpt,
  deepseek,
  mistral,
  gemini,
}

class AddSearchEngineScreen extends StatefulWidget {
  final SearchEngineModel? editEngine;
  const AddSearchEngineScreen({super.key, this.editEngine});

  @override
  State<AddSearchEngineScreen> createState() => _AddSearchEngineScreenState();
}

class _AddSearchEngineScreenState extends State<AddSearchEngineScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController homepageController = TextEditingController();
  final TextEditingController queryUrlController = TextEditingController();
  bool isSearchEngine = false;
  String searchEngineName = '';
  String iconUrl = ''; //Timer? _debounce;
  String homepageurl = '';
  String searchQuery = '';
  String searchNameError = '';
  String homepageUrlError = '';
  List<dynamic> searchEnginesList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editEngine != null) {
    // Editing Mode
    nameController.text = widget.editEngine!.name;
    homepageController.text = widget.editEngine!.url;
    queryUrlController.text = widget.editEngine!.searchUrl;

    searchEngineName = widget.editEngine!.name;
    homepageurl = widget.editEngine!.url;
    searchQuery = widget.editEngine!.searchUrl;
    iconUrl = widget.editEngine!.assetIcon;
    isSearchEngine = true;
  }
   // fetchSearchEnginesList(); // Fetch once
  }



AIModelType getRandomModel() {
  final models = AIModelType.values;
  return models[Random().nextInt(models.length)];
}


Future<Map<String, dynamic>?> callRandomAIModel(String engineName) async {
  final selectedModel = getRandomModel();

  print("Random Model Selected: $selectedModel");

  switch (selectedModel) {
    case AIModelType.chatgpt:
      return await callChatGPT(engineName);

    case AIModelType.deepseek:
      return await callDeepSeek(engineName);

    case AIModelType.mistral:
      return await callMistral(engineName);

    case AIModelType.gemini:
      return await fetchEngineDataFromGemini(engineName);
  }
}





  /// Fetch search engine list
  // Future<void> fetchSearchEnginesList() async {
  //   try {
  //     final url = Uri.parse(
  //         "https://raw.githubusercontent.com/singhvishal0209/search-engine-database/main/engines.json");

  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       searchEnginesList = jsonDecode(response.body);
  //       print("Search engine list loaded: ${searchEnginesList.length}");
  //     }
  //   } catch (e) {
  //     print("Failed to load search engines: $e");
  //   }
  // }

  Future<void> onSearchEngineNameChanged(String name) async {
    if (name.trim().isEmpty) return;

    final result = await callRandomAIModel(name); //callMistral(name); // fetchEngineDataFromGemini(name);

    if (result != null) {
      setState(() {
        homepageurl = result["homepage_url"] ?? "";
        // homepageController.text = result["homepage_url"] ?? "";
        // queryUrlController.text = result["search_query_url"] ?? "";
        searchQuery = result["search_query_url"] ?? "";
        isSearchEngine = result["isSearchEngine"];
        searchEngineName = result["name"];
      });
      await getSearchEnginIcon();
    }
  }

  getSearchEnginIcon() {
    debugPrint('Search Engin name ${homepageurl}');
    setState(() {
      if (homepageurl.isNotEmpty) {
        final url = Uri.parse(homepageurl.trim());
        debugPrint('Search Engine host ${url.toString()}');

        iconUrl =
            'https://www.google.com/s2/favicons?sz=64&domain_url=${url.host}';
      }
    });
  }



String buildSearchEnginePrompt(String engineName) {
  return """
You MUST output only valid JSON. 
No markdown. No backticks. No explanation. No placeholder

JSON format:
{
  "isSearchEngine": true or false,
  "name": "",
  "homepage_url": "",
  "search_query_url": ""
}

Rules:
1. "isSearchEngine" must be true ONLY if the given name refers to a real search engine.
2. If isSearchEngine = false:
     - homepage_url must be null
     - search_query_url must be null
3. If isSearchEngine = true:
     - homepage_url must be the exact search engine homepage (https://....)
     - search_query_url must be the real query URL using ?q= or the engine-specific pattern.
4. Do NOT include any extra characters or formatting.

Return JSON for: "$engineName"
""";
}










  Future<Map<String, dynamic>?> fetchEngineDataFromGemini(
      String engineName) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${ApiKeyManager.instance.getKey('gemini')}",
    );

//   final payload = {
//     "contents": [
//       {
//         "parts": [
//           {
//             "text": """
// You MUST output only valid JSON.
// No backticks. No markdown. No explanation. No placeholder

// Correct output format:

// {
//   "name": "",
//   "homepage_url": "",
//   "search_query_url": ""
// }

// Generate JSON for: "$engineName"
// """
//           }
//         ]
//       }
//     ],
//     "generationConfig": {
//       "responseModalities": ["TEXT"],
//       "temperature": 0.0
//     }
//   };

    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text": buildSearchEnginePrompt(engineName)
//               """
// You MUST output only valid JSON. 
// No markdown. No backticks. No explanation. No placeholder

// JSON format:
// {
//   "isSearchEngine": true or false,
//   "name": "",
//   "homepage_url": "",
//   "search_query_url": ""
// }

// Rules:
// 1. "isSearchEngine" must be true ONLY if the given name refers to a real search engine.
// 2. If isSearchEngine = false:
//      - homepage_url must be null
//      - search_query_url must be null
// 3. If isSearchEngine = true:
//      - homepage_url must be the exact search engine homepage (https://....)
//      - search_query_url must be the real query URL using ?q= or the engine-specific pattern.
// 4. Do NOT include any extra characters or formatting.

// Return JSON for: "$engineName"
// """
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.0,
        "topP": 0.1,
        "maxOutputTokens": 256
      }
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      debugPrint("Gemini API error: ${res.body}");
      return null;
    }

    final data = jsonDecode(res.body);

    try {
      final raw = extractGeminiText(data);
      debugPrint("RAW TEXT FROM GEMINI:\n$raw");

      final clean = raw.replaceAll("```", "").replaceAll("json", "").trim();

      return jsonDecode(clean);
    } catch (e) {
      debugPrint("Gemini JSON parse error: $e");
      return null;
    }
  }

  String extractGeminiText(dynamic response) {
    final candidates = response["candidates"];
    if (candidates == null || candidates.isEmpty) {
      throw "No candidates returned";
    }

    final content = candidates[0]["content"];
    if (content == null) throw "No content returned";

    final parts = content["parts"];
    if (parts == null || parts.isEmpty) throw "No parts returned";

    // FIX: merge all chunks
    final buffer = StringBuffer();

    for (var part in parts) {
      if (part is Map && part.containsKey("text")) {
        buffer.write(part["text"]);
      } else if (part is String) {
        buffer.write(part);
      }
    }

    return buffer.toString();
  }




//// Chatgpt for searchengine details
///
Future<Map<String, dynamic>?> callChatGPT(
    String engineName) async {
  try {
    final res = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer ${ApiKeyManager.instance.getKey('openai')}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4-turbo",
        "messages": [
          {
            "role": "user",
            "content": buildSearchEnginePrompt(engineName),
          }
        ],
        "temperature": 0.0
      }),
    );

    if (res.statusCode != 200) return null;

    final raw =
        jsonDecode(res.body)["choices"]?[0]?["message"]?["content"];
     print('ChatGpt Response $raw');
     if (raw == null || raw.trim().isEmpty) return null;
     final json = extractSearchEngineJson(raw);
    return json;
  } catch (e) {
    debugPrint("ChatGPT error: $e");
    return null;
  }
}


/// deepseek for search engine details

Future<Map<String, dynamic>?> callDeepSeek(
    String engineName) async {
  try {
    final res = await http.post(
      Uri.parse("https://api.deepseek.com/chat/completions"),
      headers: {
        "Authorization": "Bearer ${ApiKeyManager.instance.getKey('deepseek')}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "deepseek-chat",
        "messages": [
          {
            "role": "user",
            "content": buildSearchEnginePrompt(engineName),
          }
        ],
        "temperature": 0.0
      }),
    );

    if (res.statusCode != 200){
      print("DeepSeek data error ${res.statusCode}");
     return null;
    } 

    final raw =
        jsonDecode(res.body)["choices"]?[0]?["message"]?["content"];

    return jsonDecode(raw.trim());
  } catch (e) {
    debugPrint("DeepSeek error: $e");
    return null;
  }
}








Future<Map<String, dynamic>?> callMistral(
    String engineName) async {
  try {
    final res = await http.post(
      Uri.parse("https://api.mistral.ai/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer ${ApiKeyManager.instance.getKey('mistral')}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "mistral-small-latest", // best for JSON tasks
        "messages": [
          {
            "role": "user",
            "content": buildSearchEnginePrompt(engineName),
          }
        ],
        "temperature": 0.0
      }),
    );

    if (res.statusCode != 200) {
      debugPrint("Mistral HTTP error: ${res.body}");
      return null;
    }

    final data = jsonDecode(res.body);
    final raw =
        data["choices"]?[0]?["message"]?["content"];

    if (raw == null || raw.trim().isEmpty) return null;
     final json = extractSearchEngineJson(raw);
    return json;
   // return jsonDecode(raw.trim());
  } catch (e) {
    debugPrint("Mistral error: $e");
    return null;
  }
}

Map<String, dynamic> extractSearchEngineJson(String raw) {
  // 1. Remove markdown fences
  raw = raw
      .replaceAll("```json", "")
      .replaceAll("```", "")
      .trim();

  // 2. Find JSON object boundaries
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');

  if (start == -1 || end == -1 || end <= start) {
    throw const FormatException("Search engine JSON not found");
  }

  final jsonString = raw.substring(start, end + 1);

  final decoded = jsonDecode(jsonString);

  // 3. Strict validation (VERY IMPORTANT)
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException("Invalid JSON structure");
  }

  if (!decoded.containsKey("isSearchEngine") ||
      !decoded.containsKey("name") ||
      !decoded.containsKey("homepage_url") ||
      !decoded.containsKey("search_query_url")) {
    throw const FormatException("Missing required keys");
  }

  return decoded;
}











////// Basic Validations 

bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.host.isNotEmpty;
}






bool doesNameMatchHost(String name, String url) {
  try {
    final uri = Uri.parse(url.trim());
    final host = uri.host.toLowerCase();     // e.g. "www.google.com"
    final engineName = name.trim().toLowerCase();

    // Remove spaces in name → "duck duck go" should match "duckduckgo.com"
    final cleanedName = engineName.replaceAll(' ', '');

    return host.contains(cleanedName);
  } catch (e) {
    return false;
  }
}



Future<bool> isUrlReachable(String url) async {
  try {
    final uri = Uri.parse(url.trim());

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5);

    final request = await client.headUrl(uri);
    final response = await request.close();

    return response.statusCode >= 200 && response.statusCode < 400;
  } catch (e) {
    return false;
  }
}




Future<void> checkAndSaveEngine(
  AddSearchEngineProvider provider,
  BuildContext context,AppLocalizations loc
) async {
  provider.updateLoader(true);

  // -------- RESET ERRORS ONLY --------
  setState(() {
    searchNameError = '';
    homepageUrlError = '';
  });

  // -------- VALIDATION --------
  if (nameController.text.trim().isEmpty) {
    provider.updateLoader(false);
    setState(() => searchNameError =loc.enterSearchEngineName //'Please enter name'
    );
    return;
  }

  if (homepageController.text.trim().isEmpty) {
    provider.updateLoader(false);
    setState(() => homepageUrlError = loc.enterSearchEngineURL //'Please enter url'
    );
    return;
  }

  if (!isValidUrl(homepageController.text.trim())) {
    provider.updateLoader(false);
    setState(() => homepageUrlError = loc.entervalidURL //'Please enter valid url'
    );
    return;
  }

  if (!doesNameMatchHost(
      nameController.text, homepageController.text)) {
    provider.updateLoader(false);
    setState(() {
      searchNameError = loc.pleaseEnterCorrectSEName;
          //'Please enter the correct search engine name associated with the given url';
    });
    return;
  }

  // -------- ASYNC CHECK --------
  if (!await isUrlReachable(homepageController.text)) {
    provider.updateLoader(false);
    setState(() {
      homepageUrlError = loc.urlUnreachable;
          //'The URL is not reachable. Please enter a working URL';
    });
    return;
  }

  // -------- TEST SEARCH ENGINE (IMPORTANT) --------
  await onSearchEngineNameChanged(nameController.text);

  // -------- SAVE --------
  _saveEngine(provider, context,loc);
}


void _saveEngine(
  AddSearchEngineProvider provider,
  BuildContext context,AppLocalizations loc
) {
  if (!isSearchEngine) {
    provider.updateLoader(false);
    showMessage(loc.notvalidSearchEngine);
    return;
  }

  if (widget.editEngine == null) {
    final exists = provider.allEngines.any(
      (e) => e.name.toLowerCase() == searchEngineName.toLowerCase(),
    );

    if (exists) {
      provider.updateLoader(false);
      showMessage(loc.searchEngineAlreadyExist);
      return;
    }

    provider.addSearchEngine(
      SearchEngineModel(
        name: searchEngineName,
        url: homepageurl,
        searchUrl: searchQuery,
        assetIcon: iconUrl,
      ),
    );

    showMessage("$searchEngineName ${loc.searchEngineAdded}");
  } else {
    provider.updateSearchEngine(
      widget.editEngine!,
      SearchEngineModel(
        name:searchEngineName, //nameController.text.trim(),
        url: homepageurl,// homepageController.text.trim(),
        searchUrl:searchQuery, //queryUrlController.text.trim(),
        assetIcon: iconUrl,
      ),
    );

    showMessage(loc.searchEngineUpdated);
  }

  provider.updateLoader(false);
  Navigator.pop(context);
}


// Timer? timer;

// Future<void> checkAndSaveEngine(
//   AddSearchEngineProvider addSearchEngineProvider,
//   BuildContext context,
// ) async {

//   // Cancel previous timer safely
//   timer?.cancel();

//   // UI reset (SYNC ONLY)
//   setState(() {
//     addSearchEngineProvider.updateLoader(true);
//     searchNameError = '';
//     homepageUrlError = '';
//     searchEngineName = '';
//     iconUrl = '';
//     homepageurl = '';
//     searchQuery = '';
//     isSearchEngine = false;
//   });

//   // -------- VALIDATION --------
//   if (nameController.text.trim().isEmpty) {
//     addSearchEngineProvider.updateLoader(false);
//     setState(() {
//       searchNameError = 'Please enter name';
//     });
//     return;
//   }

//   if (homepageController.text.trim().isEmpty) {
//     addSearchEngineProvider.updateLoader(false);
//     setState(() {
//       homepageUrlError = 'Please enter url';
//     });
//     return;
//   }

//   if (!isValidUrl(homepageController.text.trim())) {
//     addSearchEngineProvider.updateLoader(false);
//     setState(() {
//       homepageUrlError = 'Please enter valid url';
//     });
//     return;
//   }

//   if (!doesNameMatchHost(
//       nameController.text, homepageController.text)) {
//     addSearchEngineProvider.updateLoader(false);
//     setState(() {
//       searchNameError =
//           'Please enter the correct search engine name associated with the given url';
//     });
//     return;
//   }

//   // -------- ASYNC CHECK --------
//   final reachable =
//       await isUrlReachable(homepageController.text);

//   if (!reachable) {
//     addSearchEngineProvider.updateLoader(false);
//     setState(() {
//       homepageUrlError =
//           'The URL is not reachable. Please enter a working URL';
//     });
//     return;
//   }

//   // -------- DEBOUNCE SAVE --------
//   timer = Timer(const Duration(milliseconds: 600), () {
//     saveIfSearchEngine(addSearchEngineProvider, context);
//   });
// }





// saveIfSearchEngine(AddSearchEngineProvider addSearchEngineProvider,BuildContext context){
//     //final provider = Provider.of<AddSearchEngineProvider>(context, listen: false);

//   if (!isSearchEngine) {
//     addSearchEngineProvider.updateLoader(false);
//     showMessage("This is not a valid search engine.");
//     return;
//   }
// if(isSearchEngine && (searchEngineName != '' && homepageurl != '' && searchQuery != '' && iconUrl != '')){

//   if (widget.editEngine == null) {
//     // ---------- ADD MODE ----------
//     bool alreadyExists = addSearchEngineProvider.allEngines.any(
//       (e) => e.name.toLowerCase() == searchEngineName.toLowerCase(),
//     );

//     if (alreadyExists) {
//       addSearchEngineProvider.updateLoader(false);
//       showMessage("This search engine already exists.");
//       return;
//     }

//     addSearchEngineProvider.addSearchEngine(
//       SearchEngineModel(
//         name: searchEngineName,
//         url: homepageurl,
//         searchUrl: searchQuery,
//         assetIcon: iconUrl,
//       ),
//     );
// addSearchEngineProvider.updateLoader(false);
//     showMessage("$searchEngineName added successfully!");
//   } else {
//     // ---------- EDIT MODE ----------
//     addSearchEngineProvider.updateSearchEngine(
//       widget.editEngine!,
//       SearchEngineModel(
//         name: nameController.text.trim(),
//         url: homepageController.text.trim(),
//         searchUrl: queryUrlController.text.trim(),
//         assetIcon: iconUrl,
//       ),
//     );
// addSearchEngineProvider.updateLoader(false);
//     showMessage("Search engine updated successfully!");
//   }
// }

//   Navigator.pop(context);

// }
  









  @override
  Widget build(BuildContext context) {
    final addSearchEngineProvider =
        Provider.of<AddSearchEngineProvider>(context);
        final themeProvider = Provider.of<DarkThemeProvider>(context);
         final theme = Theme.of(context);
         final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar:normalAppBar(context,widget.editEngine == null ? loc.addSearchEngine : loc.editSearchEngine ,themeProvider),
      //  AppBar(
      //   centerTitle: true,
      //   title: Text("${widget.editEngine == null ? 'Add' : 'Edit'} Search Engine",style:theme.textTheme.bodyLarge,),
      // ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:themeProvider.darkTheme ? Color(0xff292937) : Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(14.5),
                            
                  ),
                            
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric( vertical: 5.0),
                        child: Text(loc.name,style: TextStyle(fontFamily: 'Poppins',fontSize: 12)),
                      ),
                      // Search Engine Name
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color:themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA)),
                          borderRadius: BorderRadius.circular(8),
                          // color: Colors.grey
                        ),
                        child: TextField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 5),
                            hintText:loc.enterSEName,// 'Enter search engine name',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: const Color(0xff77778B),
                                fontWeight: FontWeight.w400),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchNameError = '';
                                          //                         if (widget.editEngine == null) {
                                          //   // Only auto-fetch in Add Mode
                                          //   onSearchEngineNameChanged(value);
                                          // }
                            });
                          },
                         // onChanged: onSearchEngineNameChanged,
                        ),
                      ),
                                 Text('$searchNameError',style: TextStyle(color: Colors.red,fontSize: 11),),
                     // const SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(loc.url,style: TextStyle(fontFamily: 'Poppins',fontSize: 12),),
                            ),
                      // Homepage URL
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: themeProvider.darkTheme ? Color(0xff42425F) : Color(0xffDADADA)),
                          borderRadius: BorderRadius.circular(8),
                          // color: Colors.grey
                        ),
                        child: TextField(
                            controller: homepageController,
                            keyboardType: TextInputType.url,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 5),
                              hintText:loc.enterSEURL,// 'Enter search engine home URL',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xff77778B),
                                  fontWeight: FontWeight.w400),
                            ),
                            // decoration: const InputDecoration(
                            //   labelText: "Search Engine Homepage URL",
                            //   hintText: "https://www.google.com/",
                            //   //border: OutlineInputBorder(),
                            // ),
                            onChanged: (value) {
                            setState(() {
                              homepageUrlError = '';
                            });
                          },
                            ),
                      ),
                       Text('$homepageUrlError',style: TextStyle(color: Colors.red),),
                     // const SizedBox(height: 20),
                            
                      // Search Query URL
                      // TextField(
                      //   controller: queryUrlController,
                      //   decoration: const InputDecoration(
                      //     labelText: "Search Query URL",
                      //     hintText: "https://www.google.com/search?q=",
                      //     border: OutlineInputBorder(),
                      //   ),
                      // ),
                            
                      //  const SizedBox(height: 30),
                            
                  //     Visibility(
                  //       visible: isSearchEngine && !addSearchEngineProvider.isLoading,
                  //       child: Container(
                  //         width: double.infinity,
                  //         margin: EdgeInsets.symmetric(vertical: 20),
                  //         padding: EdgeInsets.all(10),
                  //         decoration: BoxDecoration(
                  //             border: Border.all(color: Colors.green),
                  //             borderRadius: BorderRadius.circular(10)),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             CachedNetworkImage(
                  //               imageUrl: iconUrl ?? '',
                  //               width: 36,
                  //               height: 36,
                  //               errorWidget: (_, __, ___) => SearchEnginePlaceholder(name:nameController.text ,size: 36,),
                  //             ),
                  //             Expanded(
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   Text(
                  //                     'Search Engine Name:',
                  //                     style: TextStyle(
                  //                         fontWeight: FontWeight.w800, fontSize: 16),
                  //                   ),
                  //                   Text('$searchEngineName'),
                  //                   Text(
                  //                     'Search Engine Home page:',
                  //                     style: TextStyle(
                  //                         fontWeight: FontWeight.w800, fontSize: 16),
                  //                   ),
                  //                   Text(
                  //                     '$homepageurl',
                  //                     overflow: TextOverflow.ellipsis,
                  //                     maxLines: 2,
                  //                   ),
                  //                   Text(
                  //                     'Search Query:',
                  //                     style: TextStyle(
                  //                         fontWeight: FontWeight.w800, fontSize: 16),
                  //                   ),
                  //                   Text(
                  //                     '$searchQuery',
                  //                     overflow: TextOverflow.ellipsis,
                  //                     maxLines: 2,
                  //                   )
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                            
                  //     GestureDetector(
                  //       onTap: ()async {
                  //         setState(()async {
                  //           //isLoading = true;
                  //           addSearchEngineProvider.updateLoader(true);
                  //           searchNameError = ''; 
                  //           homepageUrlError = '';
                  //           searchEngineName = '';
                  //           debugPrint('Is loader is loading $isLoading');
                  //           iconUrl = ''; //Timer? _debounce;
                  //           homepageurl = '';
                  //           searchQuery = '';
                  //           isSearchEngine = false;
                  //           if (nameController.text.trim().isEmpty) {
                  //             isLoading = false;
                  //             addSearchEngineProvider.updateLoader(false);
                  //             searchNameError = 'Please Enter name';
                              
                  //             return ;
                  //         }
                          
                  //         if(homepageController.text.trim().isEmpty){
                  //          addSearchEngineProvider.updateLoader(false);
                  //            homepageUrlError = 'Please enter url'; 
                             
                  //            return ;
                  //         }else if(!isValidUrl(homepageController.text.trim())){
                  //           addSearchEngineProvider.updateLoader(false);
                  //                                   homepageurl = 'Please enter valid url';
                  
                  //           return ;
                  //         }
                           
                  //          if (!doesNameMatchHost(nameController.text, homepageController.text)) {
                  //   addSearchEngineProvider.updateLoader(false);
                  //   searchNameError = 'Please enter the correct search engine name associated with the given url';
                  //   return;
                  // }
                  //             // Check if URL actually loads
                  // if (!await isUrlReachable(homepageController.text)) {
                  //   addSearchEngineProvider.updateLoader(false);
                  //   homepageUrlError = 'The URL is not reachable. Please enter a working URL';
                  //   return;
                  // }
                  //                     debugPrint('Is loader is loading $isLoading');
                  
                  //        onSearchEngineNameChanged(nameController.text);
                            
                  //          addSearchEngineProvider.updateLoader(false);
                            
                  //                     debugPrint('Is loader is loading $isLoading');
                  
                            
                            
                  //         });
                          
                  //         // debugPrint("Name: ${nameController.text}");
                  //         // debugPrint("Homepage: ${homepageController.text}");
                  //         // debugPrint("Query URL: ${queryUrlController.text}");
                  //         // debugPrint('Is Search engine: $isSearchEngine');
                  //         // debugPrint('Icon Url : $iconUrl');
                  //         // addSearchEngineProvider.addSearchEngine(
                  //         //   SearchEngineModel(name: "${nameController.text}", url: '${homepageController.text}', searchUrl: '${queryUrlController.text}', assetIcon: '',)
                  //         // );
                  //       },
                  //       child: Container(
                  //           width: double.infinity,
                  //           padding: EdgeInsets.all(10),
                  //           margin: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  //           decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(10),
                  //               color: Colors.blue),
                  //           child: Center(child: const Text("Test Search Engine"))),
                  //     ),
                            
                  //     GestureDetector(
                  //       onTap: () {
                  //         debugPrint("Name: ${nameController.text}");
                  //         debugPrint("Homepage: ${homepageController.text}");
                  //         debugPrint("Query URL: ${queryUrlController.text}");
                  //         debugPrint('Is Search engine: $isSearchEngine');
                  //         debugPrint('Icon Url : $iconUrl');
                  // //         setState(() {
                  // //            if(isSearchEngine && (searchEngineName != '' && homepageurl != '' && searchQuery != '' && iconUrl != '')){
                  // //          final isAvailable = addSearchEngineProvider.allEngines
                  // // .any((engine) => engine.name.toLowerCase() == searchEngineName.toLowerCase());
                            
                  // //           debugPrint('Is Already available $isAvailable');
                  // //           if(!isAvailable){
                  // //                addSearchEngineProvider.addSearchEngine(
                  // //           SearchEngineModel(name: "${searchEngineName}", url: '${homepageurl}', searchUrl: '$searchQuery', assetIcon: iconUrl,)
                            
                  // //        );
                  // //        Navigator.pop(context);
                  // //              showMessage('$searchEngineName search engine added successfully');
                  
                  // //           }else if(isAvailable){
                  // //              showMessage('This Search Engine already exist in the list');
                  
                  // //           }
                  // //         }else if(!isSearchEngine){
                  // //           showMessage('$searchEngineName is not a Search Engine.Please add valid one!');
                  // //         }
                  // //         });
                         
                  //   final provider = Provider.of<AddSearchEngineProvider>(context, listen: false);
                  
                  //   if (!isSearchEngine) {
                  //     showMessage("This is not a valid search engine.");
                  //     return;
                  //   }
                  // if(isSearchEngine && (searchEngineName != '' && homepageurl != '' && searchQuery != '' && iconUrl != '')){
                  
                  //   if (widget.editEngine == null) {
                  //     // ---------- ADD MODE ----------
                  //     bool alreadyExists = provider.allEngines.any(
                  //       (e) => e.name.toLowerCase() == searchEngineName.toLowerCase(),
                  //     );
                  
                  //     if (alreadyExists) {
                  //       showMessage("This search engine already exists.");
                  //       return;
                  //     }
                  
                  //     provider.addSearchEngine(
                  //       SearchEngineModel(
                  //         name: searchEngineName,
                  //         url: homepageurl,
                  //         searchUrl: searchQuery,
                  //         assetIcon: iconUrl,
                  //       ),
                  //     );
                  
                  //     showMessage("$searchEngineName added successfully!");
                  //   } else {
                  //     // ---------- EDIT MODE ----------
                  //     provider.updateSearchEngine(
                  //       widget.editEngine!,
                  //       SearchEngineModel(
                  //         name: nameController.text.trim(),
                  //         url: homepageController.text.trim(),
                  //         searchUrl: queryUrlController.text.trim(),
                  //         assetIcon: iconUrl,
                  //       ),
                  //     );
                  
                  //     showMessage("Search engine updated successfully!");
                  //   }
                  // }
                  
                  //   Navigator.pop(context);
                  
                  
                  //       },
                  //       child: Container(
                  //           width: double.infinity,
                  //           padding: EdgeInsets.all(10),
                  //           margin: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  //           decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(10),
                  //               color: Colors.green),
                  //           child: Center(
                  //               child: const Text(
                  //             "Add Search Engine",
                  //             style: TextStyle(),
                  //           ))),
                  //     ),
                  
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: ()async{
                         checkAndSaveEngine(addSearchEngineProvider,context,loc);
                        },
                        child: Container(
                          width: 112,
                          height: 44,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                          decoration: BoxDecoration(
                            
                            borderRadius: BorderRadius.circular(10),
                            color:themeProvider.darkTheme ? Color(0xff0BA70F) : Color(0xff0BA70F),
                          ),
                          child: Center(
                            child: Text(
                             widget.editEngine == null ? loc.add : loc.save, // "Add" : "Save",
                              style: TextStyle(color: Colors.white,fontSize:14,fontWeight: FontWeight.w800,fontFamily: 'Poppins' ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  
                  
                  
                  
                  
                      // ElevatedButton(
                      //   onPressed: () {
                      //     debugPrint("Name: ${nameController.text}");
                      //     debugPrint("Homepage: ${homepageController.text}");
                      //     debugPrint("Query URL: ${queryUrlController.text}");
                      //     debugPrint('Is Search engine: $isSearchEngine');
                      //     debugPrint('Icon Url : $iconUrl');
                      //     // addSearchEngineProvider.addSearchEngine(
                      //     //   SearchEngineModel(name: "${nameController.text}", url: '${homepageController.text}', searchUrl: '${queryUrlController.text}', assetIcon: '',)
                      //     // );
                            
                      //   },
                      //   child: const Text("Add Search Engine"),
                      // ),
                            
                      //  Text('Is this a Search engine URL $isSearchEngine')
                    ],
                  ),
                ),
              ),
            ),
          ),
        
        Visibility(
          visible: addSearchEngineProvider.isLoading,
         child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3)
          ),
           child: Center(
              child: CircularProgressIndicator(
              ),
            ),
         ),
       )
        ],
      ),
    );
  }
}
