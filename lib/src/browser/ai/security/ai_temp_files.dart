import 'package:belnet_lib/belnet_lib.dart';
import 'package:flutter/foundation.dart';

/// Deletes temporary files created by the AI chat.
///
/// Covered (Android, see BelnetLibPlugin.purgeAiTempFiles):
///   * attachment copies from the pickers (chat_*)
///   * metadata-stripped images (chatimg_*)
///   * per-document text files sent to the AI (chatdoc_*)
///   * camera captures left by image_picker
///   * read-aloud WAVs in the app cache (beldex_ai_*.wav)
///   * read-aloud WAVs the TTS engine left in shared media storage
///   * generated images written for the share sheet
///
/// Called on app start and whenever the chat is reset.
class AiTempFiles {
  AiTempFiles._();

  /// [keepPaths] are not deleted, e.g. the WAV that is playing now.
  static Future<void> purge({List<String> keepPaths = const []}) async {
    final int deleted =
        await BelnetLib.purgeAiTempFiles(keepPaths: keepPaths);

    debugPrint('AI temp files deleted: $deleted');
  }
}
