import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../parish/data/providers/parish_providers.dart';
import '../../../parish/domain/usecases/get_parishes_usecase.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_basic_info_section.dart';
import '../widgets/profile_parish_info_section.dart';
import '../widgets/profile_sacrament_dates_section.dart';
import '../widgets/profile_godparent_section.dart';
import '../widgets/user_search_sheet.dart';
import '../widgets/parish_search_sheet.dart';

/// 프로필 편집 화면
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController? _baptismalNameController;
  bool _isSaving = false;
  int? _feastDayMonth;
  int? _feastDayDay;
  String? _selectedParishId;
  String? _selectedParishName;
  DateTime? _baptismDate;
  DateTime? _confirmationDate;
  List<String> _godchildren = [];
  String? _godparentId;
  Map<String, UserEntity> _godchildrenMap = {}; // userId -> UserEntity
  UserEntity? _godparent;
  String? _profileImageUrl; // 새로 업로드한 프로필 이미지 URL

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    _nicknameController = TextEditingController(
      text: currentUser?.nickname ?? '',
    );
    // 세례명 컨트롤러: 항상 생성 (미설정일 때만 입력 가능하지만, 설정되어 있어도 표시)
    _baptismalNameController = TextEditingController(
      text: currentUser?.baptismalName ?? '',
    );
    // feastDayId 형식: "이름:월-일" 또는 "월-일" (예: "ペトロ:6-29" 또는 "6-29")
    if (currentUser?.feastDayId != null) {
      final feastDayId = currentUser!.feastDayId!;
      if (feastDayId.contains(':')) {
        final colonParts = feastDayId.split(':');
        final dateParts = colonParts[1].split('-');
        if (dateParts.length == 2) {
          _feastDayMonth = int.tryParse(dateParts[0]);
          _feastDayDay = int.tryParse(dateParts[1]);
        }
      } else {
        final parts = feastDayId.split('-');
        if (parts.length == 2) {
          _feastDayMonth = int.tryParse(parts[0]);
          _feastDayDay = int.tryParse(parts[1]);
        }
      }
    }
    _selectedParishId = currentUser?.mainParishId;
    _baptismDate = currentUser?.baptismDate;
    _confirmationDate = currentUser?.confirmationDate;
    _godchildren = List<String>.from(currentUser?.godchildren ?? []);
    _godparentId = currentUser?.godparentId;
    _loadParish();
    _loadGodchildren();
    _loadGodparent();
  }

  Future<void> _loadGodchildren() async {
    if (_godchildren.isEmpty) return;

    final repository = ref.read(authRepositoryProvider);
    final loadedMap = <String, UserEntity>{};

    for (final userId in _godchildren) {
      final result = await repository.searchUser(userId: userId);
      result.fold((_) {}, (user) {
        if (user != null) {
          loadedMap[userId] = user;
        }
      });
    }

    if (mounted) {
      setState(() {
        _godchildrenMap = loadedMap;
      });
    }
  }

  Future<void> _loadGodparent() async {
    if (_godparentId == null) return;

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.searchUser(userId: _godparentId);

    if (mounted) {
      result.fold((_) {}, (user) {
        if (user != null) {
          setState(() {
            _godparent = user;
          });
        }
      });
    }
  }

  Future<void> _loadParish() async {
    if (_selectedParishId == null) return;

    final repository = ref.read(parishRepositoryProvider);
    final useCase = GetParishByIdUseCase(repository);
    final result = await useCase.call(_selectedParishId!);

    result.fold((_) {}, (parish) {
      if (mounted) {
        setState(() {
          _selectedParishName = parish.name;
        });
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _baptismalNameController?.dispose();
    super.dispose();
  }

  int _getDaysInMonth(int month) {
    const daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile.editProfile),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.common.save,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileImagePicker(
              primaryColor: primaryColor,
              previewImageUrl: _profileImageUrl,
              onImageSelected: (imageUrl) {
                setState(() {
                  _profileImageUrl = imageUrl;
                });
              },
            ),
            const SizedBox(height: 32),
            ProfileBasicInfoSection(
              nicknameController: _nicknameController,
              email: currentUser?.email,
              userId: currentUser?.userId,
              baptismalName: currentUser?.baptismalName,
              baptismalNameController: _baptismalNameController,
              feastDayMonth: _feastDayMonth,
              feastDayDay: _feastDayDay,
              onMonthChanged: (value) {
                setState(() {
                  _feastDayMonth = value;
                  // 월이 변경되면 일수 확인
                  if (_feastDayDay != null && value != null) {
                    final maxDay = _getDaysInMonth(value);
                    if (_feastDayDay! > maxDay) {
                      _feastDayDay = maxDay;
                    }
                  }
                });
              },
              onDayChanged: (value) {
                setState(() {
                  _feastDayDay = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ProfileParishInfoSection(
              selectedParishName: _selectedParishName,
              onParishTap: () =>
                  _showParishSearchBottomSheet(context, ref, primaryColor),
            ),
            const SizedBox(height: 16),
            ProfileSacramentDatesSection(
              baptismDate: _baptismDate,
              confirmationDate: _confirmationDate,
              onBaptismDateTap: () => _selectDate(context, true),
              onConfirmationDateTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),
            ProfileGodparentSection(
              primaryColor: primaryColor,
              godparent: _godparent,
              godchildren: _godchildren,
              godchildrenMap: _godchildrenMap,
              onGodparentTap: () => _showUserSearchBottomSheet(
                context,
                ref,
                primaryColor,
                l10n.profile.godparent.add,
                (user) {
                  setState(() {
                    _godparentId = user.userId;
                    _godparent = user;
                  });
                },
              ),
              onAddGodchildTap: () => _showUserSearchBottomSheet(
                context,
                ref,
                primaryColor,
                l10n.profile.godparent.addGodchild,
                (user) {
                  if (!_godchildren.contains(user.userId)) {
                    setState(() {
                      _godchildren.add(user.userId);
                      _godchildrenMap[user.userId] = user;
                    });
                  }
                },
              ),
              onRemoveGodparent: () {
                setState(() {
                  _godparentId = null;
                  _godparent = null;
                });
              },
              onRemoveGodchild: (userId) {
                setState(() {
                  _godchildren.remove(userId);
                  _godchildrenMap.remove(userId);
                });
              },
            ),
            const SizedBox(height: 24),
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.common.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isBaptism) async {
    final initialDate = isBaptism ? _baptismDate : _confirmationDate;
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now();
    final locale = ref.read(localeProvider);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: locale,
    );

    if (pickedDate != null) {
      setState(() {
        if (isBaptism) {
          _baptismDate = pickedDate;
        } else {
          _confirmationDate = pickedDate;
        }
      });
    }
  }

  void _showUserSearchBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    String title,
    void Function(UserEntity) onUserSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return UserSearchSheet(
          primaryColor: primaryColor,
          title: title,
          onUserSelected: (user) {
            Navigator.pop(context);
            onUserSelected(user);
          },
        );
      },
    );
  }

  /// 세례명 처음 저장 시 확인 모달
  Future<bool> _showBaptismalNameConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String baptismalName,
  ) async {
    final l10n = ref.read(appLocalizationsSyncProvider);
    final primaryColor = ref.read(liturgyPrimaryColorProvider);
    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.profile.baptismalNameChange.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 입력한 세례명 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                baptismalName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profile.baptismalNameChange.message,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profile.baptismalNameChange.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.common.cancel,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.common.confirm),
          ),
        ],
      ),
    );

    return result == true;
  }

  void _showParishSearchBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return ParishSearchSheet(
              scrollController: scrollController,
              primaryColor: primaryColor,
              selectedParishId: _selectedParishId,
              onParishSelected: (parishId, parishName) {
                setState(() {
                  _selectedParishId = parishId;
                  _selectedParishName = parishName;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = ref.read(appLocalizationsSyncProvider);
    final currentUser = ref.read(currentUserProvider);

    // 세례명 처리: 새로 입력하는 경우 확인 모달 표시
    String? baptismalName;
    final trimmedName = _baptismalNameController?.text.trim() ?? '';

    if (trimmedName.isNotEmpty) {
      // 기존 세례명이 없고 새로 입력하는 경우
      if (currentUser?.baptismalName == null ||
          currentUser!.baptismalName!.isEmpty) {
        // 확인 모달 표시
        final confirmed = await _showBaptismalNameConfirmDialog(
          context,
          ref,
          trimmedName,
        );
        if (!confirmed) {
          // 취소하면 저장하지 않고 리턴
          return;
        }
        baptismalName = trimmedName;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);

      // mainParishId가 변경되면 favoriteParishIds도 업데이트
      List<String>? updatedFavorites;
      if (_selectedParishId != null &&
          _selectedParishId != currentUser?.mainParishId) {
        updatedFavorites = List<String>.from(
          currentUser?.favoriteParishIds ?? [],
        );
        // 기존 mainParishId가 있으면 제거 (선택사항)
        if (currentUser?.mainParishId != null) {
          updatedFavorites.remove(currentUser!.mainParishId!);
        }
        // 새로운 mainParishId 추가 (없으면)
        if (!updatedFavorites.contains(_selectedParishId)) {
          updatedFavorites.add(_selectedParishId!);
        }
      }

      // feastDayId 생성: "월-일" 형식
      String? feastDayId;
      if (_feastDayMonth != null && _feastDayDay != null) {
        feastDayId = '$_feastDayMonth-$_feastDayDay';
      }

      final result = await repository.updateProfile(
        nickname: _nicknameController.text.trim(),
        mainParishId: _selectedParishId,
        profileImageUrl: _profileImageUrl,
        feastDayId: feastDayId,
        baptismalName: baptismalName,
        baptismDate: _baptismDate,
        confirmationDate: _confirmationDate,
        godchildren: _godchildren,
        godparentId: _godparentId,
        favoriteParishIds: updatedFavorites, // mainParishId 변경 시 자동 업데이트
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (updatedUser) {
          // authStateProvider를 직접 업데이트하여 즉시 UI 반영
          ref.read(authStateProvider.notifier).state = updatedUser;
          ref.invalidate(authStateStreamProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profile.profileUpdated),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profile.updateFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
