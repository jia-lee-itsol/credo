import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF 뷰어 화면
class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String? fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    // PDF 로드 후 초기 줌 레벨 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _pdfViewerController.zoomLevel = 1.5; // 초기 줌 레벨을 150%로 설정
        }
      });
    });
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName ?? 'PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: '확대',
            onPressed: () {
              _pdfViewerController.zoomLevel = 
                  (_pdfViewerController.zoomLevel * 1.2).clamp(0.5, 4.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: '축소',
            onPressed: () {
              _pdfViewerController.zoomLevel = 
                  (_pdfViewerController.zoomLevel / 1.2).clamp(0.5, 4.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            tooltip: '맞춤',
            onPressed: () {
              _pdfViewerController.zoomLevel = 1.0;
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        controller: _pdfViewerController,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF 로드 실패: ${details.error}'),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          // PDF 로드 완료 후 초기 줌 레벨 설정
          _pdfViewerController.zoomLevel = 1.5;
        },
      ),
    );
  }
}

