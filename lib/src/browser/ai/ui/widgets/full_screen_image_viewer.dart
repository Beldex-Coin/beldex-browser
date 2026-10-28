


import 'dart:io';

import 'package:beldex_browser/src/browser/ai/ui/widgets/attachment_preview.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';

void showFullScreenImagePreview(
  BuildContext context,
  List<File> files,
  int initialIndex,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black,
    barrierDismissible: false,
    builder: (context) {
      return _FullScreenImageViewer(
        files: files,
        initialIndex: initialIndex,
      );
    },
  );
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<File> files;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.files,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() =>
      _FullScreenImageViewerState();
}

class _FullScreenImageViewerState
    extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isImage(File file) {
    final extension = file.path.split('.').last.toLowerCase();

    return [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'bmp',
    ].contains(extension);
  }

  bool _isPdf(File file) {
    return file.path.toLowerCase().endsWith('.pdf');
  }

  Future<void> _openExternalFile(File file) async {
    try {
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint('Unable to open file: $e');
    }
  }

  Widget _buildFilePreview(File file) {
    // IMAGE PREVIEW
    if (_isImage(file)) {
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        panEnabled: true,
        scaleEnabled: true,
        child: Center(
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image_outlined,
                color: Colors.white,
                size: 80,
              );
            },
          ),
        ),
      );
    }

    // PDF PREVIEW
    if (_isPdf(file)) {
      return _PdfPreview(file: file);
    }

    // OTHER FILE TYPES
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insert_drive_file_outlined,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
             getOriginalFileName(file.path.split(Platform.pathSeparator).last),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _openExternalFile(file),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff1A1A1A)
                ),
                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   const Icon(Icons.open_in_new,size: 18,),
                   SizedBox(width: 5,),
                   const Text('Open file',style: TextStyle(color: Colors.white,fontFamily: 'Inter',fontSize: 16,fontWeight: FontWeight.w600),)
                  ],
                ),
              ),
            ),
            
            
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // FILE VIEWER
            PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildFilePreview(widget.files[index]);
              },
            ),

            // CLOSE BUTTON
            Positioned(
              top: 12,
              left: 15,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.rectangle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // FILE COUNTER
            if (widget.files.length > 1)
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.files.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _PdfPreview extends StatefulWidget {
  final File file;

  const _PdfPreview({
    required this.file,
  });

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  PdfControllerPinch? _pdfController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      if (!await widget.file.exists()) {
        throw Exception('PDF file does not exist.');
      }

      final controller = PdfControllerPinch(
        document: PdfDocument.openFile(widget.file.path),
      );

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _pdfController = controller;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to preview this PDF.';
      });

      debugPrint('PDF preview error: $e');
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (_pdfController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return PdfViewPinch(
      controller: _pdfController!,
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        pageLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        errorBuilder: (_, error) => Center(
          child: Text(
            'Unable to display PDF: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

