import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:beldex_browser/src/browser/pages/tab_settings/glassmorph_widget.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'read_aloud_controller.dart';

import 'dart:math' as math;


class FloatingReadAloudPlayer extends StatelessWidget {
  const FloatingReadAloudPlayer(
    {
    super.key,
    required this.controller, required this.model,
  });

  final ReadAloudController controller;
  final ChatViewModel model;

  @override
  Widget build(BuildContext context) {
    if (!controller.isVisible) {
      return const SizedBox.shrink();
    }

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 8,
          ),
          child: Material(
            color: isDark ? Color(0xff0B0B0B): Color(0xffEBEBEB),
            child: Container(
             // color: isDark ? Color(0xff444444).withOpacity(0.2) : Color(0xffEBEBEB),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 7,
                ),
                decoration:
                    BoxDecoration(
                  color: isDark
                      ?  Colors.transparent //(0xffEEEEEE)
                      : const Color(0xffEBEBEB),
                  // borderRadius:
                  //     BorderRadius.circular(30),
                  border: Border.all(color: isDark ? Color(0xff444444) : Color(0xff737373)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.18),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    controller.isGeneratingAudio ? Container(
          width: 30,
          height: 30,
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xff222222)
                : Color(0xffFFFFFF),
            shape: BoxShape.circle,
          ),
             child: CircularProgressIndicator(color: Color(0xff8D8D8D),),
          ) :
                    _controlButton(
                      identifier:
                          'ai_read_aloud_floating_play_pause',
                      icon: controller.isPlaying ?'pause_read.svg'
                             : 'Play_button.svg',
                          // controller.isGeneratingAudio
                          //     ? 
                          //     Icons
                          //         .hourglass_empty_rounded
                          //     : controller.isPlaying
                          //         ? Icons.pause_rounded
                          //         : Icons.play_arrow_rounded,
                      onTap:
                          controller.isGeneratingAudio || model.isListening
                              ? null
                              : controller
                                  .togglePlayPause,
                      
                      isDark: isDark
                    ),
              
                    const SizedBox(
                      width: 4,
                    ),
              
                    _controlButton(
                      identifier:
                          'ai_read_aloud_floating_rewind',
                      icon: 'backward_10.svg', // Icons.replay,
                      onTap:
                          controller.isGeneratingAudio
                              ? null
                              : controller.rewind10,
                    isDark: isDark
                    ),
              
                    const SizedBox(
                      width: 2,
                    ),
              
                    _controlButton(
                      identifier:
                          'ai_read_aloud_floating_forward',
                      icon:'forward_10.svg',  // Icons.forward,
                      onTap:
                          controller.isGeneratingAudio
                              ? null
                              : controller.forward10,
                      isDark: isDark
                    ),
              
                    const SizedBox(
                      width: 4,
                    ),
              
                    GestureDetector(
                      onTap:
                          controller.isGeneratingAudio
                              ? null
                              : controller
                                  .changePlaybackSpeed,
                      child: 
                       Container(
                              width: 30,
                              height: 30,
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xff222222)
                                    : Color(0xffFFFFFF),
                                shape: BoxShape.circle,
                              ),
                               alignment:
                            Alignment.center,
                      // Container(
                      //   height: 36,
                      //   padding:
                      //       const EdgeInsets
                      //           .symmetric(
                      //     horizontal: 9,
                      //   ),
                      //   alignment:
                      //       Alignment.center,
                        child: Text(
                          '${controller.playbackSpeed % 1 == 0 ? controller.playbackSpeed.toInt() : controller.playbackSpeed}x',
                          style:
                               TextStyle(
                            fontFamily:
                                'Inter',
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                            color: isDark ? Color(0xffEBEBEB) :
                                Color(0xff0B0B0B),
                          ),
                        ),
                      ),
                    ),
              
                    // const SizedBox(
                    //   width: 4,
                    // ),
                   Flexible(
  fit: FlexFit.tight,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: AudioPlaybackWaveform(
      position: controller.position,
      duration: controller.duration,
      isPlaying: controller.isPlaying,
      isDark: isDark,
    ),
  ),
),
                    Text(
                      controller
                              .isGeneratingAudio
                          ? '...'
                          : controller
                              .formatDuration(
                              controller.position,
                            ),
                      style:
                           TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        color: isDark ? Color(0xffEBEBEB) : 
                            Color(0xff0B0B0B),
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
              
                    const SizedBox(
                      width: 4,
                    ),
              
                    _controlButton(
                      identifier:
                          'ai_read_aloud_floating_close',
                      icon: 'close_mic.svg',
                          //Icons.close_rounded,
                      onTap:
                          controller.close,
                      isDark: isDark,
                      filled: true
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required String identifier,
    required String icon,
    required VoidCallback? onTap,
    bool filled = false,
    
    required bool isDark
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff222222)
              : Color(0xffFFFFFF),
          shape:filled ? BoxShape.rectangle : BoxShape.circle,
        ),
        child: SvgPicture.asset('assets/images/ai-icons/new/$icon',color:  isDark ? Colors.white : Colors.black)
        //  Icon(
        //   icon,
        //   size: 21,
        //   color: onTap == null
        //       ? const Color(0xffAAAAAA)
        //       : const Color(0xff222222),
        // ),
      ),
    );
  }
}



class AudioPlaybackWaveform extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isDark;

  const AudioPlaybackWaveform({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isDark,
  });

  @override
  State<AudioPlaybackWaveform> createState() =>
      _AudioPlaybackWaveformState();
}

class _AudioPlaybackWaveformState
    extends State<AudioPlaybackWaveform>
    with SingleTickerProviderStateMixin {
  static const int barCount = 32;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isPlaying) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(
    covariant AudioPlaybackWaveform oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isPlaying &&
        _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        widget.isDark ? Colors.white : Colors.black87;

    final Color inactiveColor =
        widget.isDark ? Colors.white38 : Colors.black26;

    return SizedBox(
      height: 30,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final double animationValue =
              _animationController.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: List.generate(barCount, (index) {
                  final double normalized =
                      index / (barCount - 1);

                  // Keep both waveform edges sharp.
                  final double edgeFactor =
                      math.sin(normalized * math.pi);

                  // Create continuously changing bar heights.
                  final double wave1 = math.sin(
                    index * 0.65 +
                        animationValue * math.pi * 2,
                  ).abs();

                  final double wave2 = math.sin(
                    index * 1.15 -
                        animationValue * math.pi * 2,
                  ).abs();

                  final double variation =
                      (wave1 * 0.55) + (wave2 * 0.45);

                  final double height = (
                    3 + edgeFactor * variation * 24
                  ).clamp(3.0, 27.0);

                  return SizedBox(
                    width: constraints.maxWidth / barCount,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 100,
                        ),
                        width: 2,
                        height: widget.isPlaying
                            ? height
                            : 3 + edgeFactor * 5,
                        decoration: BoxDecoration(
                          color: widget.isPlaying
                              ? activeColor
                              : inactiveColor,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }
}



// class AudioPlaybackWaveform extends StatelessWidget {
//   final Duration position;
//   final Duration duration;
//   final bool isPlaying;
//   final bool isDark;

//   const AudioPlaybackWaveform({
//     super.key,
//     required this.position,
//     required this.duration,
//     required this.isPlaying,
//     required this.isDark,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const int barCount = 32;

//     final double progress = duration.inMilliseconds > 0
//         ? (position.inMilliseconds / duration.inMilliseconds)
//             .clamp(0.0, 1.0)
//         : 0.0;

//     final Color activeColor =
//         isDark ? Colors.white : Colors.black87;

//     final Color inactiveColor =
//         isDark ? Colors.white38 : Colors.black26;

//     return SizedBox(
//       height: 30,
//       //width: double.infinity,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: List.generate(barCount, (index) {
//               final double normalized = index / (barCount - 1);

// // Create sharp, symmetrical edges.
// final double edgeFactor = math.sin(
//   normalized * math.pi,
// );

// // Keep the edges short and make the centre taller.
// final double waveShape = math.pow(
//   edgeFactor,
//   0.65,
// ).toDouble();

// // Add variation to each bar.
// final double variation =
//     0.45 + (math.sin(index * 2.1).abs() * 0.55);

// // Calculate bar height.
// final double height = (
//   3.0 + (waveShape * variation * 23.0)
// ).clamp(3.0, 26.0);

// // Highlight played progress.
// final bool hasPlayed = normalized <= progress;

// final Color barColor = hasPlayed
//     ? activeColor
//     : inactiveColor;

// // Render the bar.
// return SizedBox(
//   width: constraints.maxWidth / barCount,
//   child: Center(
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 120),
//       curve: Curves.easeOut,
//       width: 2,
//       height: height,
//       decoration: BoxDecoration(
//         color: barColor,
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//   ),
// );
//               // final double normalized =
//               //     index / (barCount - 1);

//               // // Waveform shape.
//               // final double waveFactor =
//               //     0.25 +
//               //     (math.sin(index * 0.65).abs() * 0.75);

//               // final double secondaryFactor =
//               //     0.75 +
//               //     (math.sin(index * 1.37).abs() * 0.25);

//               // final double baseHeight =
//               //     5 + (waveFactor * secondaryFactor * 25);

//               // // Animate the waveform while playing.
//               // // The index creates a travelling wave effect.
//               // final double animationFactor = isPlaying
//               //     ? 1 +
//               //         (0.20 *
//               //             math.sin(
//               //               (DateTime.now()
//               //                           .millisecondsSinceEpoch /
//               //                       100.0) -
//               //                   index * 0.7,
//               //             ))
//               //     : 1.0;

//               // final double height = (baseHeight *
//               //         animationFactor)
//               //     .clamp(4.0, 34.0);

//               // // Fade the waveform at both edges.
//               // double fade;

//               // if (normalized < 0.18) {
//               //   fade = normalized / 0.18;
//               // } else if (normalized > 0.82) {
//               //   fade = (1 - normalized) / 0.18;
//               // } else {
//               //   fade = 1.0;
//               // }

//               // fade = fade.clamp(0.15, 1.0);

//               // // Highlight the played portion.
//               // final bool hasPlayed = normalized <= progress;

//               // final Color barColor = hasPlayed
//               //     ? activeColor.withOpacity(fade)
//               //     : inactiveColor.withOpacity(fade);

//               // return SizedBox(
//               //   width: constraints.maxWidth / barCount,
//               //   child: Center(
//               //     child: AnimatedContainer(
//               //       duration: const Duration(milliseconds: 120),
//               //       curve: Curves.easeOut,
//               //       width: 2,
//               //       height: height,
//               //       decoration: BoxDecoration(
//               //         color: barColor,
//               //         borderRadius: BorderRadius.circular(10),
//               //       ),
//               //     ),
//               //   ),
//               // );
//             }),
//           );
//         },
//       ),
//     );
//   }
// }