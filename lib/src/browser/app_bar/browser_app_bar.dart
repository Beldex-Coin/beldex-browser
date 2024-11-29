//import 'package:beldex_browser/src/browser/app_bar/sample_webview_tab_app_bar.dart';
import 'package:beldex_browser/src/browser/app_bar/webview_tab_app_bar.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BrowserAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BrowserAppBar({Key? key,})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  State<BrowserAppBar> createState() => _BrowserAppBarState();

  @override
  final Size preferredSize;
}

class _BrowserAppBarState extends State<BrowserAppBar> {
  bool _isFindingOnPage = false;

  @override
  Widget build(BuildContext context) {
   final browserModel = Provider.of<BrowserModel>(context,listen: true);

    return WebViewTabAppBar(
            showFindOnPage: () {
              browserModel.updateFindOnPage(true);
              setState(() {
                _isFindingOnPage = true;
              });
            },
            hideFindOnPage: () {
              browserModel.updateFindOnPage(false);
              setState(() {
                _isFindingOnPage = false;
              });
            },
          );
  }
}
