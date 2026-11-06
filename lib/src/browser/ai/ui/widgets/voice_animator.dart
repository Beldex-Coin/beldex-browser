import 'dart:math';

import 'package:flutter/material.dart';

class VoiceWaveform extends StatefulWidget {
  final bool isListening;
  final bool isDarkTheme;

  const VoiceWaveform({
    super.key,
    required this.isListening,
    required this.isDarkTheme,
  });

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<double> _bars = [
    0.25,
    0.45,
    0.70,
    0.40,
    0.85,
    0.55,
    0.35,
    0.75,
    0.50,
    0.30,
    0.65,
    0.45,
    0.80,
    0.40,
    0.60,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isListening && !oldWidget.isListening) {
      _controller.repeat();
    } else if (!widget.isListening && oldWidget.isListening) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _VoiceWavePainter(
            progress: _controller.value,
            bars: _bars,
            isDarkTheme: widget.isDarkTheme,
          ),
          size: const Size(double.infinity, 45),
        );
      },
    );
  }
}

class _VoiceWavePainter extends CustomPainter {
  final double progress;
  final List<double> bars;
  final bool isDarkTheme;

  _VoiceWavePainter({
    required this.progress,
    required this.bars,
    required this.isDarkTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDarkTheme
          ? Colors.white
          : Colors.black87;

    const barWidth = 3.0;
    const spacing = 5.0;

    final totalWidth =
        bars.length * (barWidth + spacing);

    final startX =
        (size.width - totalWidth) / 2;

    for (int i = 0; i < bars.length; i++) {
      final wave =
          sin((progress * 2 * pi) + i * 0.65);

      final amplitude =
          0.35 + ((wave + 1) / 2) * 0.65;

      final barHeight =
          8 + (bars[i] * amplitude * 30);

      final x =
          startX + i * (barWidth + spacing);

      final y =
          (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            y,
            barWidth,
            barHeight,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}