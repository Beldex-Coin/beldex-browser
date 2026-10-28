import 'dart:math' as math;

import 'package:flutter/material.dart';

class VoiceWaveform extends StatelessWidget {
  final double soundLevel;
  final bool isDark;

  const VoiceWaveform({
    super.key,
    required this.soundLevel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const int barCount = 32;

    return SizedBox(
      height: 30,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              barCount,
              (index) {
                final centre = (barCount - 1) / 2;

                final distance =
                    (index - centre).abs();

                final positionFactor =
                    1 - (distance / centre);

                final waveFactor =
                    math.max(
                  0.15,
                  positionFactor,
                );

                // Your original dynamic calculation.
                final baseHeight =
                    4.0 +
                    (soundLevel *
                        28.0 *
                        waveFactor);

                // Your original variation.
                final variation =
                    1 +
                    ((index % 5) * 0.08);

                final height =
                    (baseHeight * variation)
                        .clamp(4.0, 34.0);

                // --------------------------------
                // FADE AT BOTH SIDES
                // --------------------------------

                final normalized =
                    index / (barCount - 1);

                double fade;

                if (normalized < 0.18) {
                  // Left fade.
                  fade = normalized / 0.18;
                } else if (normalized > 0.82) {
                  // Right fade.
                  fade =
                      (1.0 - normalized) / 0.18;
                } else {
                  fade = 1.0;
                }

                // Prevent bars from becoming completely
                // invisible.
                fade = fade.clamp(0.15, 1.0);

                final color =
                    (isDark
                            ? Colors.white
                            : Colors.black87)
                        .withOpacity(fade);

                return SizedBox(
                  width: constraints.maxWidth /
                      barCount,
                  child: Center(
                    child: AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 70,
                      ),
                      curve: Curves.easeOut,
                      width: 2,
                      height: height,
                      decoration:
                          BoxDecoration(
                        color: color,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
