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

class _ParishDetailScreenState extends ConsumerState<ParishDetailScreen> {
  bool _isUploadingImage = false;

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

                  // 기본 정보
                  SliverToBoxAdapter(
                    child: ParishDetailBasicInfo(
                      parish: parish,
                      primaryColor: primaryColor,
                      l10n: l10n,
                    ),
                  ),

                  // 액션 버튼 (지도, 커뮤니티)
                  SliverToBoxAdapter(
                    child: ParishDetailActions(
                      parish: parish,
                      parishId: widget.parishId,
                      primaryColor: primaryColor,
                      l10n: l10n,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 미사 시간
                  SliverToBoxAdapter(
                    child: ParishDetailMassTimes(
                      parish: parish,
                      primaryColor: primaryColor,
                      l10n: l10n,
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

  /// 주소 수정 다이얼로그
  Future<void> _showEditAddressDialog(BuildContext context, String? currentAddress) async {
    final controller = TextEditingController(text: currentAddress ?? '');
    final primaryColor = ref.read(liturgyPrimaryColorProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주소 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '주소',
            hintText: '주소를 입력하세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentAddress) {
      await _updateParishField('address', result);
    }
  }

  /// 전화번호 수정 다이얼로그
  Future<void> _showEditPhoneDialog(BuildContext context, String? currentPhone) async {
    final controller = TextEditingController(text: currentPhone ?? '');
    final primaryColor = ref.read(liturgyPrimaryColorProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전화번호 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '전화번호',
            hintText: '03-1234-5678',
            helperText: '하이픈(-)을 포함하여 입력하세요',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentPhone) {
      await _updateParishField('phone', result);
    }
  }

  /// 미사 시간 수정 다이얼로그
  Future<void> _showEditMassTimesDialog(BuildContext context, String? currentMassTime) async {
    final controller = TextEditingController(text: currentMassTime ?? '');
    final primaryColor = ref.read(liturgyPrimaryColorProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('미사 시간 수정'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '형식 예시:\n日 10:00, 18:00\n土 18:00\n月-金 07:00',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '미사 시간',
                  hintText: '日 10:00, 18:00',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result != currentMassTime) {
      await _updateParishField('massTime', result);
    }
  }

  /// 외국어 미사 수정 다이얼로그
  Future<void> _showEditForeignMassDialog(BuildContext context, String? currentMassTime) async {
    // 외국어 미사 부분만 추출 (현재는 전체 텍스트에서 필터링)
    final controller = TextEditingController(text: currentMassTime ?? '');
    final primaryColor = ref.read(liturgyPrimaryColorProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('외국어 미사 수정'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '형식 예시:\n日 14:00 영어\n日 16:00 한국어\n土 19:00 스페인어',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '미사 시간 (외국어 포함)',
                  hintText: '日 14:00 영어',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result != currentMassTime) {
      await _updateParishField('massTime', result);
    }
  }

  /// 성당 정보 필드 업데이트
  Future<void> _updateParishField(String fieldName, dynamic value) async {
    try {
      await parishEdit.ParishEditService.updateParishField(
        parishId: widget.parishId,
        fieldName: fieldName,
        value: value,
      );

      // Provider 무효화하여 새 데이터 반영
      ref.invalidate(core.parishByIdProvider(widget.parishId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('정보가 업데이트되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업데이트 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
