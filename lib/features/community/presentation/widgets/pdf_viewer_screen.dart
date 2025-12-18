import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF 뷰어 화면
class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String? fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName ?? 'PDF'),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
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
      ),
    );
  }
}

