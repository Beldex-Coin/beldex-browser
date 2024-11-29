import 'package:beldex_browser/src/browser/animated_beldex_browser_logo.dart';
import 'package:beldex_browser/src/browser/models/browser_model.dart';
import 'package:beldex_browser/src/browser/models/webview_model.dart';
import 'package:beldex_browser/src/browser/util.dart';
import 'package:beldex_browser/src/browser/webview_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';


class ProjectInfoPopup extends StatefulWidget {
  const ProjectInfoPopup({super.key});

  @override
  State<StatefulWidget> createState() => _ProjectInfoPopupState();
}

class _ProjectInfoPopupState extends State<ProjectInfoPopup> {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      RichText(
        text: const TextSpan(children: [
          TextSpan(
            text: "Do you like this project? Give a ",
            style: TextStyle(color: Colors.black),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.star,
              size: 25,
              color: Colors.yellow,
            ),
          ),
          TextSpan(text: " to", style: TextStyle(color: Colors.black))
        ]),
      ),
      ElevatedButton.icon(
        icon: const Icon(
          MaterialCommunityIcons.github,
          size: 40.0,
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade300)),
        label: RichText(
          text: const TextSpan(children: [
            TextSpan(text: "Github: ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: "beldex-coin/beldex-browser",
                style: TextStyle(color: Colors.blue))
          ]),
        ),
        onPressed: () {
          var browserModel = Provider.of<BrowserModel>(context, listen: false);
          browserModel.addTab(WebViewTab(
            key: GlobalKey(),
            webViewModel: WebViewModel(
                url: WebUri(
                    "https://github.com/beldex-coin")),
          ));
          Navigator.pop(context);
        },
      ),
      RichText(
        text: const TextSpan(children: [
          TextSpan(text: "and to", style: TextStyle(color: Colors.black)),
        ]),
      ),
      ElevatedButton.icon(
        icon: const Icon(
          MaterialCommunityIcons.github,
          size: 40.0,
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade300)),
        label: RichText(
          text: const TextSpan(children: [
            TextSpan(text: "Github: ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: "beldex-browser",
                style: TextStyle(color: Colors.blue))
          ]),
        ),
        onPressed: () {
          var browserModel = Provider.of<BrowserModel>(context, listen: false);
          browserModel.addTab(WebViewTab(
            key: GlobalKey(),
            webViewModel: WebViewModel(
                url: WebUri(
                    "https://github.com/beldex-coin")),
          ));
          Navigator.pop(context);
        },
      ),
      const SizedBox(
        height: 20.0,
      ),
      SizedBox(
        width: 250.0,
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(children: [
            TextSpan(
              text:
                  "Also, if you want, you can support these projects with a donation. Thanks!",
              style: TextStyle(color: Colors.black),
            ),
          ]),
        ),
      ),
    ];

    if (Util.isIOS()) {
      children.addAll(<Widget>[
        const SizedBox(
          height: 20.0,
        ),
        ElevatedButton.icon(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 30.0,
          ),
          label: const Text(
            "Go Back",
            style: TextStyle(fontSize: 20.0),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]);
    }

    return Scaffold(
      body: Center(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (Orientation.landscape == orientation) {
              var rowChildren = <Widget>[
                const AnimatedBeldexBrowserLogo(),
                const SizedBox(
                  width: 80.0,
                ),
              ];
              rowChildren.add(Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ));

              return Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: rowChildren,
              );
            }

            var columnChildren = <Widget>[
              const AnimatedBeldexBrowserLogo(),
              const SizedBox(
                height: 80.0,
              ),
            ];
            columnChildren.addAll(children);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: columnChildren,
            );
          },
        ),
      ),
    );
  }
}
