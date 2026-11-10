import 'dart:math' as math;

import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageGenerationLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final int gridSize;
  final DarkThemeProvider themeProvider;

  const ImageGenerationLoader({
    super.key,
    this.size = 90,
    this.color,
    this.gridSize = 5, required this.themeProvider,
  });

  @override
  State<ImageGenerationLoader> createState() =>
      _ImageGenerationLoaderState();
}

class _ImageGenerationLoaderState extends State<ImageGenerationLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ??
        Theme.of(context).colorScheme.onSurface;
//final themeProvider = Provider.of<DarkThemeProvider>(context);
    final count = widget.gridSize;

    return SizedBox(
      width: widget.size,
      height:widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count * count,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              crossAxisSpacing: widget.size * 0.055,
              mainAxisSpacing: widget.size * 0.055,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ count;
              final column = index % count;

              final distance = math.sqrt(
                math.pow(row - (count - 1) / 2, 2) +
                    math.pow(column - (count - 1) / 2, 2),
              );

              final phase =
                  (_controller.value * 2 * math.pi) -
                  (distance * 0.75);

              final wave = (math.sin(phase) + 1) / 2;

              final opacity = 0.2 + (wave * 0.8);
              final dotSize = 0.35 + (wave * 0.65);

              return Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: dotSize,
                    child: Container(
                      width: widget.size / (count + 1.5),
                      height: widget.size / (count + 1.5),
                      decoration: BoxDecoration(
                        color:widget.themeProvider.darkTheme ? dotColor : Colors.white,// dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
