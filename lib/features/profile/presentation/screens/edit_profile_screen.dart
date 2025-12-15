import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/providers/saint_feast_day_providers.dart';
import '../../domain/usecases/get_saint_feast_days_usecase.dart';
import '../../../parish/data/providers/parish_providers.dart';
import '../../../parish/domain/usecases/get_parishes_usecase.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_basic_info_section.dart';
import '../widgets/profile_parish_info_section.dart';
import '../widgets/profile_sacrament_dates_section.dart';
import '../widgets/profile_godparent_section.dart';
import '../widgets/feast_day_search_sheet.dart';
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
  bool _isSaving = false;
  String? _selectedFeastDayId;
  SaintFeastDayModel? _selectedFeastDay;
  String? _selectedParishId;
  String? _selectedParishName;
  DateTime? _baptismDate;
  DateTime? _confirmationDate;
  List<String> _godchildren = [];
  String? _godparentId;
  Map<String, UserEntity> _godchildrenMap = {}; // userId -> UserEntity
  UserEntity? _godparent;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    _nicknameController = TextEditingController(
      text: currentUser?.nickname ?? '',
    );
    _selectedFeastDayId = currentUser?.feastDayId;
    _selectedParishId = currentUser?.mainParishId;
    _baptismDate = currentUser?.baptismDate;
    _confirmationDate = currentUser?.confirmationDate;
    _godchildren = List<String>.from(currentUser?.godchildren ?? []);
    _godparentId = currentUser?.godparentId;
    _loadFeastDay();
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

  Future<void> _loadFeastDay() async {
    if (_selectedFeastDayId == null) return;

    final parts = _selectedFeastDayId!.split('-');
    if (parts.length != 2) return;

    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    if (month == null || day == null) return;

    final repository = ref.read(saintFeastDayRepositoryProvider);
    final useCase = GetSaintsForDateUseCase(repository);
    final result = await useCase.call(DateTime(2024, month, day));

    result.fold((_) {}, (saints) {
      if (saints.isNotEmpty && mounted) {
        // Entity를 Model로 변환 (기존 코드 호환성)
        final saint = saints.first;
        setState(() {
          _selectedFeastDay = SaintFeastDayModel(
            month: saint.month,
            day: saint.day,
            name: saint.name,
            nameEn: saint.nameEnglish,
            type: saint.type,
            isJapanese: saint.isJapanese,
            greeting: saint.greeting,
            description: saint.description,
          );
        });
      }
    });
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
    super.dispose();
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
            ProfileImagePicker(primaryColor: primaryColor),
            const SizedBox(height: 32),
            ProfileBasicInfoSection(
              nicknameController: _nicknameController,
              email: currentUser?.email,
              userId: currentUser?.userId,
              baptismalName: currentUser?.baptismalName,
            ),
            const SizedBox(height: 16),
            ProfileParishInfoSection(
              selectedParishName: _selectedParishName,
              selectedFeastDay: _selectedFeastDay,
              onParishTap: () =>
                  _showParishSearchBottomSheet(context, ref, primaryColor),
              onFeastDayTap: () =>
                  _showFeastDayBottomSheet(context, ref, primaryColor),
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
                '代子・代女を追加',
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
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isBaptism) async {
    final initialDate = isBaptism ? _baptismDate : _confirmationDate;
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ja', 'JP'),
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

  void _showFeastDayBottomSheet(
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
        return FeastDaySearchSheet(
          primaryColor: primaryColor,
          selectedFeastDayId: _selectedFeastDayId,
          onFeastDaySelected: (saint) {
            setState(() {
              _selectedFeastDay = saint;
              _selectedFeastDayId = '${saint.month}-${saint.day}';
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final l10n = ref.read(appLocalizationsSyncProvider);
    try {
      final repository = ref.read(authRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);

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

      final result = await repository.updateProfile(
        nickname: _nicknameController.text.trim(),
        mainParishId: _selectedParishId,
        feastDayId: _selectedFeastDayId,
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
