import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;

/// Image builder for Markdown that renders AI-generated text.
///
/// flutter_markdown's default builder fetches `![..](https://..)`
/// automatically. A prompt-injected page or file can make the model
/// emit an image URL with chat data in its query string, and simply
/// displaying the reply would send that data to the attacker. It can
/// also read local files (`file://`) into the UI.
///
/// This builder never loads anything: no network, file, asset or
/// data URIs. It shows a small "Image not loaded" placeholder instead.
/// Generated images are unaffected; they are shown from the API's
/// base64 data by the image preview widget, not through Markdown.
Widget blockedMarkdownImage(md.MarkdownImageConfig config) {
  return const _BlockedImagePlaceholder();
}

class _BlockedImagePlaceholder extends StatelessWidget {
  const _BlockedImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).hintColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Image not loaded',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
