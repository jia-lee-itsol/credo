import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/data/services/saint_detail_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/saint_feast_day_providers.dart';

/// 성인 상세 정보 모달
class SaintDetailModal extends ConsumerStatefulWidget {
  final SaintFeastDayModel saint;

  const SaintDetailModal({
    super.key,
    required this.saint,
  });

  @override
  ConsumerState<SaintDetailModal> createState() => _SaintDetailModalState();
}

class _SaintDetailModalState extends ConsumerState<SaintDetailModal> {
  SaintDetailInfo? _detailInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetailInfo();
  }

  Future<void> _loadDetailInfo() async {
    final locale = ref.read(localeProvider);
    final detailService = SaintDetailService();
    final detail = await detailService.getSaintDetail(
      widget.saint,
      locale.languageCode,
    );

    if (mounted) {
      setState(() {
        _detailInfo = detail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final locale = ref.watch(localeProvider);
    final saintName = widget.saint.getName(locale.languageCode);
    final imageUrlAsync = ref.watch(saintImageUrlProvider(widget.saint));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이미지 영역
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: imageUrlAsync.when(
                      data: (imageUrl) {
                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          return GestureDetector(
                            onTap: () => _showFullScreenImage(context, imageUrl),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.account_circle,
                                    size: 100,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.account_circle,
                            size: 100,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        );
                      },
                      loading: () => Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      error: (_, __) => Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.account_circle,
                          size: 100,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 내용 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 성인 이름
                    Text(
                      saintName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 축일 정보
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.saint.month}月${widget.saint.day}日',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 상세 정보
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_detailInfo != null) ...[
                      // 생애
                      if (_detailInfo!.biography.isNotEmpty) ...[
                        _buildSectionTitle(theme, l10n.saints.biography),
                        const SizedBox(height: 8),
                        Text(
                          _detailInfo!.biography,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 주요 업적
                      if (_detailInfo!.achievements.isNotEmpty) ...[
                        _buildSectionTitle(theme, l10n.saints.achievements),
                        const SizedBox(height: 8),
                        Text(
                          _detailInfo!.achievements,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 수호 영역
                      if (_detailInfo!.patronage.isNotEmpty) ...[
                        _buildSectionTitle(theme, l10n.saints.patronage),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _detailInfo!.patronage.map((patron) {
                            return Chip(
                              label: Text(patron),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 기도문
                      if (_detailInfo!.prayer.isNotEmpty) ...[
                        _buildSectionTitle(theme, l10n.saints.prayer),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _detailInfo!.prayer,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 기리는 방법
                      if (_detailInfo!.howToHonor.isNotEmpty) ...[
                        _buildSectionTitle(theme, l10n.saints.howToHonor),
                        const SizedBox(height: 8),
                        Text(
                          _detailInfo!.howToHonor,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ],
                    ] else
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            l10n.saints.detailLoadFailed,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // 닫기 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.common.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// 이미지 전체 화면 보기
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageViewer(
            imageUrl: imageUrl,
            animation: animation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

/// 전체 화면 이미지 뷰어 위젯
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final Animation<double> animation;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 배경 (탭하면 닫힘)
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            // 이미지
            Center(
              child: GestureDetector(
                onTap: () {}, // 이미지 탭 시 닫히지 않도록
                child: Hero(
                  tag: 'saint_modal_image_$imageUrl',
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 닫기 버튼
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
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

