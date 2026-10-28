import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as path;


String getOriginalFileName(String fileName) {
  return fileName.replaceFirst(
    RegExp(r'^chat_\d+_\d+_'),
    '',
  );
}

class AttachmentPreview extends StatefulWidget {
  final File file;
  final VoidCallback onTap;

  const AttachmentPreview({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  State<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends State<AttachmentPreview> {
  PdfDocument? _pdfDocument;
  PdfPageImage? _pdfPageImage;

  bool _isPdf = false;
  bool _isLoading = false;

  String get _fileName => path.basename(widget.file.path);

  String get _extension =>
      path.extension(widget.file.path).replaceFirst('.', '').toLowerCase();

  @override
  void initState() {
    super.initState();

    _isPdf = _extension == 'pdf';

    if (_isPdf) {
      _loadPdfPreview();
    }
  }

  Future<void> _loadPdfPreview() async {
    if (!await widget.file.exists()) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final document = await PdfDocument.openFile(widget.file.path);
      final page = await document.getPage(1);

      final image = await page.render(
        width: 180,
        height: 220,
        format: PdfPageImageFormat.png,
      );

      await page.close();

      if (!mounted) {
        await document.close();
        return;
      }

      setState(() {
        _pdfDocument = document;
        _pdfPageImage = image;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PDF thumbnail error: $e');

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getFileIcon() {
    switch (_extension) {
      case 'pdf':
        return Icons.picture_as_pdf;

      case 'doc':
      case 'docx':
        return Icons.description;

      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;

      case 'ppt':
      case 'pptx':
        return Icons.slideshow;

      case 'txt':
        return Icons.text_snippet;

      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;

      case 'mp3':
      case 'wav':
      case 'm4a':
        return Icons.audio_file;

      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  void dispose() {
    _pdfDocument?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isImage = [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'bmp',
    ].contains(_extension);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white, //grey.shade900,
          //borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: isImage
            ? Image.file(
                widget.file,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFileCard(),
              )
            : 
            // _isPdf && _pdfPageImage != null
            //     ? Image.memory(
            //         _pdfPageImage!.bytes,
            //         fit: BoxFit.cover,
            //       )
            //     :
                 _buildFileCard(),
      ),
    );
  }


Color colorChoice(String extension){
   if (extension == 'pdf') {
    return Colors.red;
  } else if (['doc', 'docx'].contains(extension)) {
    return Colors.blue;
  } else if (['xls', 'xlsx', 'csv'].contains(extension)) {
    return Colors.green;
  } else if (['ppt', 'pptx'].contains(extension)) {
   return Colors.orange;
  } else if (extension == 'txt') {
    return Colors.blueGrey;
  }
  return Colors.blueGrey;
}



  Widget _buildFileCard() {
    final isPdf = _extension == 'pdf';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              _getFileIcon(),
              size: 20,
              color: colorChoice(_extension)
              // isPdf
              //     ? Colors.red.shade700
              //     : Colors.blueGrey.shade700,
            ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              _extension.isEmpty ? 'FILE' : _extension.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            
              style:  TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
             getOriginalFileName(_fileName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 7,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// void showFullScreenImagePreview(
//   BuildContext context,
//   List<File> files,
//   int initialIndex,
// ) {
//   showDialog<void>(
//     context: context,
//     barrierColor: Colors.black,
//     builder: (dialogContext) {
//       return _FullScreenImageViewer(
//         files: files,
//         initialIndex: initialIndex,
//       );
//     },
//   );
// }

// class _FullScreenImageViewer extends StatefulWidget {
//   final List<File> files;
//   final int initialIndex;

//   const _FullScreenImageViewer({
//     required this.files,
//     required this.initialIndex,
//   });

//   @override
//   State<_FullScreenImageViewer> createState() =>
//       _FullScreenImageViewerState();
// }

// class _FullScreenImageViewerState
//     extends State<_FullScreenImageViewer> {
//   late final PageController _pageController;
//   late int _currentIndex;

//   @override
//   void initState() {
//     super.initState();

//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(
//       initialPage: widget.initialIndex,
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         title: Text(
//           '${_currentIndex + 1} / ${widget.files.length}',
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.files.length,
//         onPageChanged: (index) {
//           setState(() => _currentIndex = index);
//         },
//         itemBuilder: (context, index) {
//           final file = widget.files[index];

//           return InteractiveViewer(
//             minScale: 0.5,
//             maxScale: 4,
//             child: Center(
//               child: Image.file(
//                 file,
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Icon(
//                     Icons.broken_image,
//                     color: Colors.white,
//                     size: 60,
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
