import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/data/services/saint_detail_service.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/saint_feast_day_providers.dart';

/// 성인 상세 정보 화면
class SaintDetailScreen extends ConsumerStatefulWidget {
  final String saintId; // "month-day-hashCode" 형식

  const SaintDetailScreen({super.key, required this.saintId});

  @override
  ConsumerState<SaintDetailScreen> createState() => _SaintDetailScreenState();
}

class _SaintDetailScreenState extends ConsumerState<SaintDetailScreen> {
  SaintDetailInfo? _detailInfo;
  bool _isLoading = true;
  SaintFeastDayModel? _saint;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadSaintAndDetail();
  }

  Future<void> _loadSaintAndDetail() async {
    // saintId에서 성인 정보 찾기
    final todaySaints = await ref.read(todaySaintsProvider.future);
    final saint = todaySaints.firstWhere(
      (s) => '${s.month}-${s.day}-${s.name.hashCode}' == widget.saintId,
      orElse: () => todaySaints.first,
    );

    if (!mounted) return;

    setState(() {
      _saint = saint;
    });

    final locale = ref.read(localeProvider);
    final detailService = SaintDetailService();
    final detail = await detailService.getSaintDetail(
      saint,
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
    if (_saint == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final locale = ref.watch(localeProvider);
    final saintName = _saint!.getName(locale.languageCode);
    final imageUrlAsync = ref.watch(saintImageUrlProvider(_saint!));

    return Scaffold(
      appBar: AppBar(title: Text(saintName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 이미지 영역
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Center(
                child: imageUrlAsync.when(
                  data: (imageUrl) {
                    // 현재 이미지 URL 저장
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _currentImageUrl != imageUrl) {
                        setState(() => _currentImageUrl = imageUrl);
                      }
                    });

                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(context, imageUrl),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Padding(
                                padding: const EdgeInsets.all(30),
                                child: Image.asset(
                                  'assets/icons/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          width: 3,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                  loading: () => Container(
                    width: 200,
                    height: 200,
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
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 내용 영역
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 축일 정보
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_saint!.month}月${_saint!.day}日',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 상세 정보 카드들
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_detailInfo != null) ...[
                    // 생애 카드
                    if (_detailInfo!.biography.isNotEmpty)
                      _buildInfoCard(
                        context,
                        theme,
                        l10n.saints.biography,
                        _detailInfo!.biography,
                        Icons.person,
                      ),

                    // 주요 업적 카드
                    if (_detailInfo!.achievements.isNotEmpty)
                      _buildInfoCard(
                        context,
                        theme,
                        l10n.saints.achievements,
                        _detailInfo!.achievements,
                        Icons.star,
                      ),

                    // 수호 영역 카드
                    if (_detailInfo!.patronage.isNotEmpty)
                      _buildPatronageCard(
                        context,
                        theme,
                        l10n.saints.patronage,
                        _detailInfo!.patronage,
                      ),

                    // 기도문 카드
                    if (_detailInfo!.prayer.isNotEmpty)
                      _buildInfoCard(
                        context,
                        theme,
                        l10n.saints.prayer,
                        _detailInfo!.prayer,
                        Icons.favorite,
                        isItalic: true,
                      ),

                    // 기리는 방법 카드
                    if (_detailInfo!.howToHonor.isNotEmpty)
                      _buildInfoCard(
                        context,
                        theme,
                        l10n.saints.howToHonor,
                        _detailInfo!.howToHonor,
                        Icons.celebration,
                      ),
                  ] else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            l10n.saints.detailLoadFailed,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String content,
    IconData icon, {
    bool isItalic = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatronageCard(
    BuildContext context,
    ThemeData theme,
    String title,
    List<String> patronage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: patronage.map((patron) {
                return Chip(
                  label: Text(patron),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
          return FadeTransition(opacity: animation, child: child);
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
            Positioned.fill(child: Container(color: Colors.transparent)),
            // 이미지
            Center(
              child: GestureDetector(
                onTap: () {}, // 이미지 탭 시 닫히지 않도록
                child: Hero(
                  tag: 'saint_image_$imageUrl',
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
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
