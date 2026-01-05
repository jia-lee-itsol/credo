import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../core/data/services/parish_image_service.dart' as parishEdit;
import '../widgets/parish_detail_header.dart';
import '../widgets/parish_detail_basic_info.dart';
import '../widgets/parish_detail_actions.dart';
import '../widgets/parish_detail_mass_times.dart';

/// 교회 상세 화면
class ParishDetailScreen extends ConsumerStatefulWidget {
  final String parishId;

  const ParishDetailScreen({super.key, required this.parishId});

  @override
  ConsumerState<ParishDetailScreen> createState() => _ParishDetailScreenState();
}

class _ParishDetailScreenState extends ConsumerState<ParishDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isUploadingImage = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_animationController.isAnimating &&
        _animationController.status != AnimationStatus.completed) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 실제 데이터 조회
    final parishAsync = ref.watch(core.parishByIdProvider(widget.parishId));

    // 즐겨찾기 여부 확인
    final isFavorite =
        currentUser?.favoriteParishIds.contains(widget.parishId) ?? false;

    // 이미지 수정 권한 확인 (공식 인증된 유저 && 해당 성당 소속)
    // verifiedParishId가 있으면 사용, 없으면 mainParishId로 체크
    final userParishId = currentUser?.verifiedParishId ?? currentUser?.mainParishId;
    final canEditImage = currentUser != null &&
        currentUser.isVerified &&
        userParishId == widget.parishId;

    return parishAsync.when(
      data: (parish) {
        if (parish == null || parish.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.parish.detail)),
            body: Center(child: Text(l10n.parish.notFound)),
          );
        }

        // 데이터 로드 완료 시 애니메이션 시작
        _startAnimation();

        final parishName = parish['name'] as String? ?? '';

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 헤더
                  ParishDetailHeader(
                    parishName: parishName,
                    parishId: widget.parishId,
                    address: parish['address'] as String?,
                    imageUrl: parish['imageUrl'] as String?,
                    isFavorite: isFavorite,
                    canEditImage: canEditImage,
                    onFavoriteToggle: () => _toggleFavorite(
                      context,
                      ref,
                      isFavorite,
                    ),
                    onEditImage: canEditImage ? () => _handleEditImage(context) : null,
                  ),

                  // 기본 정보 (애니메이션 적용)
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ParishDetailBasicInfo(
                          parish: parish,
                          primaryColor: primaryColor,
                          l10n: l10n,
                        ),
                      ),
                    ),
                  ),

                  // 액션 버튼 (지도, 커뮤니티) - 딜레이된 애니메이션
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delayedValue = Curves.easeOutCubic.transform(
                          (_animationController.value * 1.5 - 0.2).clamp(0.0, 1.0),
                        );
                        return Opacity(
                          opacity: delayedValue,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - delayedValue)),
                            child: child,
                          ),
                        );
                      },
                      child: ParishDetailActions(
                        parish: parish,
                        parishId: widget.parishId,
                        primaryColor: primaryColor,
                        l10n: l10n,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 미사 시간 - 더 딜레이된 애니메이션
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delayedValue = Curves.easeOutCubic.transform(
                          (_animationController.value * 1.5 - 0.4).clamp(0.0, 1.0),
                        );
                        return Opacity(
                          opacity: delayedValue,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - delayedValue)),
                            child: child,
                          ),
                        );
                      },
                      child: ParishDetailMassTimes(
                        parish: parish,
                        primaryColor: primaryColor,
                        l10n: l10n,
                      ),
                    ),
                  ),

                  // 하단 여백
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
              // 업로드 중 로딩 오버레이
              if (_isUploadingImage)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          '이미지 업로드 중...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.parish.detail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.parish.detail)),
        body: Center(child: Text('${l10n.community.errorOccurred}: $error')),
      ),
    );
  }

  Future<void> _handleEditImage(BuildContext context) async {
    final l10n = ref.read(appLocalizationsSyncProvider);

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await parishEdit.ParishEditService.pickAndUploadParishImage(
        parishId: widget.parishId,
      );

      if (!mounted) return;

      if (imageUrl != null) {
        // 성공 - provider 무효화하여 새 이미지 반영
        ref.invalidate(core.parishByIdProvider(widget.parishId));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미지가 업로드되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      // imageUrl이 null이면 사용자가 취소한 경우이므로 메시지 표시 안함
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.common.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isCurrentlyFavorite,
  ) async {
    final l10n = ref.read(appLocalizationsSyncProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auth.loginRequired),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 소속 성당은 즐겨찾기에서 제거할 수 없음
    if (isCurrentlyFavorite && widget.parishId == currentUser.mainParishId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parish.cannotRemoveParish),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final repository = ref.read(authRepositoryProvider);
    final updatedFavorites = List<String>.from(currentUser.favoriteParishIds);

    if (isCurrentlyFavorite) {
      updatedFavorites.remove(widget.parishId);
    } else {
      updatedFavorites.add(widget.parishId);
    }

    final result = await repository.updateProfile(
      favoriteParishIds: updatedFavorites,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (updatedUser) {
        // authStateProvider를 직접 업데이트하여 즉시 UI 반영
        ref.read(authStateProvider.notifier).state = updatedUser;
        // StreamProvider도 무효화하여 다음 스트림 업데이트 시 최신 데이터 유지
        ref.invalidate(authStateStreamProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFavorite
                  ? l10n.common.favoriteRemoved
                  : l10n.common.favoriteAdded,
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}
