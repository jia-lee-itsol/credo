import 'package:flutter/material.dart';
import '../../../../core/utils/app_localizations.dart';
import 'pdf_viewer_screen.dart';

/// 게시글 PDF 파일 섹션
class PostDetailPdfs extends StatelessWidget {
  final List<String> pdfUrls;

  const PostDetailPdfs({super.key, required this.pdfUrls});

  void _openPdf(BuildContext context, String pdfUrl, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PdfViewerScreen(pdfUrl: pdfUrl, fileName: fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pdfUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.community.pdfFiles,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...pdfUrls.map((pdfUrl) {
          final fileName = pdfUrl.split('/').last.split('?').first;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _openPdf(context, pdfUrl, fileName),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.community.tapToOpen,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
