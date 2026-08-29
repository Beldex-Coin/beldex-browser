
import 'package:beldex_browser/l10n/generated/app_localizations.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/downloads/download_prov.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadListScreen extends StatefulWidget {
  const DownloadListScreen({super.key});

  @override
  State<DownloadListScreen> createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
   ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  String formatFileSize(int fileSizeInBytes) {
    double kbSize = fileSizeInBytes / 1024; // Convert bytes to kilobytes
    double mbSize = kbSize / 1024; // Convert kilobytes to megabytes

    if (mbSize < 1.00) {
      // Display in KB if less than 0.01 MB
      return '${kbSize.toStringAsFixed(2)} KB';
    } else {
      // Display in MB if equal to or greater than 0.01 MB
      return '${mbSize.toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<DarkThemeProvider>(context);
    final downloadProvider = Provider.of<DownloadProvider>(context);
    final loc = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Positioned.fill(
        child:themeProvider.darkTheme ? Image.asset(
          'assets/images/ai-icons/new/background_map.gif',
          fit: BoxFit.cover,
        ): Image.asset(
          'assets/images/ai-icons/new/BG_wht_theme.gif',
          fit: BoxFit.cover,
        ),
      ),
      ],
    );
  }
}