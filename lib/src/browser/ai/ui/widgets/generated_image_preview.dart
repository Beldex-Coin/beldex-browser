import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class GeneratedImageViewer extends StatelessWidget {
  final String base64Image;
  final Future<void> Function() onSave;
  final Future<void> Function() onShare;

  const GeneratedImageViewer({
    super.key,
    required this.base64Image,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final Uint8List imageBytes = base64Decode(base64Image);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen image with zoom support.
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),

            // Close button at the top-left.
            Positioned(
              top: 12,
              left: 12,
              child: Material(
                color:const Color(0xCC222222), //Colors.black54,
                //shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Close image',
                ),
              ),
            ),

            // Save and share buttons at the bottom-centre.
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Save button.
                  _buildActionButton(
                    icon: Icons.download_rounded,
                    label: 'Save',
                    onPressed: onSave,
                  ),

                  const SizedBox(width: 20),

                  // Share button.
                  _buildActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onPressed: onShare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Future<void> Function() onPressed,
  }) {
    return Material(
      color: const Color(0xCC222222),//const Color(0xFF292929),
     // borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 13,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,fontFamily: 'Inter'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}