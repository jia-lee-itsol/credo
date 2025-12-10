import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../../core/data/models/saint_feast_day_model.dart';
import '../../../../core/data/services/parish_service.dart' as core;
import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/providers/saint_feast_day_providers.dart';
import '../../domain/usecases/get_saint_feast_days_usecase.dart';
import '../../../parish/data/providers/parish_providers.dart';
import '../../../parish/domain/usecases/get_parishes_usecase.dart';

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
            nameEnglish: saint.nameEnglish,
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
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
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
                    '保存',
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
            // 프로필 이미지
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryColor.withValues(alpha: 0.2),
                    child: Icon(Icons.person, size: 50, color: primaryColor),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 기본 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本情報',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 닉네임 입력
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'ニックネーム',
                        hintText: 'ニックネームを入力してください',
                      ),
                      validator: Validators.validateNickname,
                      maxLength: 20,
                    ),
                    const SizedBox(height: 16),
                    // 이메일 (읽기 전용)
                    TextFormField(
                      initialValue: currentUser?.email ?? '',
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
                      enabled: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'メールアドレスは変更できません',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 유저 ID (읽기 전용)
                    GestureDetector(
                      onLongPress: currentUser?.userId != null
                          ? () {
                              Clipboard.setData(
                                ClipboardData(text: currentUser!.userId),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ユーザーIDをコピーしました'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      child: TextFormField(
                        initialValue: currentUser?.userId ?? '',
                        decoration: const InputDecoration(labelText: 'ユーザーID'),
                        enabled: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ユーザーIDは変更できません（長押しでコピー）',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 세례명 (읽기 전용)
                    TextFormField(
                      initialValue: currentUser?.baptismalName ?? '未設定',
                      decoration: const InputDecoration(labelText: '洗礼名'),
                      enabled: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '洗礼名は変更できません',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 교회 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '教会情報',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 소속 본당 선택
                    InkWell(
                      onTap: () => _showParishSearchBottomSheet(
                        context,
                        ref,
                        primaryColor,
                      ),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '所属教会',
                          suffixIcon: const Icon(Icons.chevron_right),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _selectedParishName ?? '選択してください',
                          style: TextStyle(
                            color: _selectedParishName != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 축일 선택
                    InkWell(
                      onTap: () =>
                          _showFeastDayBottomSheet(context, ref, primaryColor),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '守護聖人の祝日',
                          suffixIcon: const Icon(Icons.chevron_right),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _selectedFeastDay != null
                              ? _selectedFeastDay!.name
                              : '選択してください',
                          style: TextStyle(
                            color: _selectedFeastDay != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 성사 날짜 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '聖事の日付',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 세례 날짜
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '洗礼日',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _baptismDate != null
                              ? DateFormat(
                                  'yyyy年MM月dd日',
                                  'ja',
                                ).format(_baptismDate!)
                              : '選択してください',
                          style: TextStyle(
                            color: _baptismDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 견진 날짜
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '堅信日',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _confirmationDate != null
                              ? DateFormat(
                                  'yyyy年MM月dd日',
                                  'ja',
                                ).format(_confirmationDate!)
                              : '選択してください',
                          style: TextStyle(
                            color: _confirmationDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 대부모・대자녀 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '代父母・代子・代女',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 대부모 선택
                    InkWell(
                      onTap: () => _showUserSearchBottomSheet(
                        context,
                        ref,
                        primaryColor,
                        '代父母を選択',
                        (user) {
                          setState(() {
                            _godparentId = user.userId;
                            _godparent = user;
                          });
                        },
                      ),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '代父母 (1名のみ)',
                          suffixIcon: const Icon(Icons.chevron_right),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _godparent != null
                              ? '${_godparent!.nickname} (${_godparent!.email})'
                              : '選択してください',
                          style: TextStyle(
                            color: _godparent != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    if (_godparent != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onLongPress: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _godparent!.userId),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ユーザーIDをコピーしました'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Text(
                                  'ユーザーID: ${_godparent!.userId}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _godparentId = null;
                                  _godparent = null;
                                });
                              },
                              child: const Text('削除'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // 대자녀 목록
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '代子・代女 (${_godchildren.length}人)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showUserSearchBottomSheet(
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
                          icon: const Icon(Icons.add),
                          label: const Text('追加'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_godchildren.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '登録された代子・代女がありません',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ..._godchildren.map((userId) {
                        final user = _godchildrenMap[userId];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                Icons.person,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            title: Text(user?.nickname ?? '不明'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (user != null) Text(user.email),
                                GestureDetector(
                                  onLongPress: () {
                                    Clipboard.setData(
                                      ClipboardData(text: userId),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('ユーザーIDをコピーしました'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'ユーザーID: $userId',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red.shade300,
                              onPressed: () {
                                setState(() {
                                  _godchildren.remove(userId);
                                  _godchildrenMap.remove(userId);
                                });
                              },
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
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
        return _UserSearchSheet(
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
            return _ParishSearchSheet(
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
        return _FeastDaySearchSheet(
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
            const SnackBar(
              content: Text('プロフィールを更新しました'),
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
        ).showSnackBar(const SnackBar(content: Text('更新に失敗しました')));
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

/// 축일 검색 시트
class _FeastDaySearchSheet extends ConsumerStatefulWidget {
  final Color primaryColor;
  final String? selectedFeastDayId;
  final void Function(SaintFeastDayModel) onFeastDaySelected;

  const _FeastDaySearchSheet({
    required this.primaryColor,
    this.selectedFeastDayId,
    required this.onFeastDaySelected,
  });

  @override
  ConsumerState<_FeastDaySearchSheet> createState() =>
      _FeastDaySearchSheetState();
}

class _FeastDaySearchSheetState extends ConsumerState<_FeastDaySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allSaintsAsync = ref.watch(_allSaintsProvider);

    return Column(
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        // 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '守護聖人の祝日を選択',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '聖人名で検索',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const SizedBox(height: 16),

        // 성인 목록
        Expanded(
          child: allSaintsAsync.when(
            data: (allSaints) {
              // 검색 필터링
              final filteredSaints = _searchQuery.isEmpty
                  ? allSaints
                  : allSaints.where((saint) {
                      final name = saint.name.toLowerCase();
                      final nameEn = saint.nameEnglish.toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || nameEn.contains(query);
                    }).toList();

              if (filteredSaints.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '検索結果がありません',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredSaints.length,
                itemBuilder: (context, index) {
                  final saint = filteredSaints[index];
                  final feastDayId = '${saint.month}-${saint.day}';
                  final isSelected = widget.selectedFeastDayId == feastDayId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: widget.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.celebration,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      saint.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${saint.month}月${saint.day}日',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: widget.primaryColor)
                        : null,
                    onTap: () => widget.onFeastDaySelected(saint),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('エラー: $error')),
          ),
        ),
      ],
    );
  }
}

/// 모든 성인 목록 Provider
final _allSaintsProvider = FutureProvider<List<SaintFeastDayModel>>((
  ref,
) async {
  final repository = ref.read(saintFeastDayRepositoryProvider);
  final result = await repository.loadSaintsFeastDays();
  return result.fold(
    (_) => <SaintFeastDayModel>[],
    (saints) => saints
        .map(
          (saint) => SaintFeastDayModel(
            month: saint.month,
            day: saint.day,
            name: saint.name,
            nameEnglish: saint.nameEnglish,
            type: saint.type,
            isJapanese: saint.isJapanese,
            greeting: saint.greeting,
            description: saint.description,
          ),
        )
        .toList(),
  );
});

/// 유저 검색 시트
class _UserSearchSheet extends ConsumerStatefulWidget {
  final Color primaryColor;
  final String title;
  final void Function(UserEntity) onUserSelected;

  const _UserSearchSheet({
    required this.primaryColor,
    required this.title,
    required this.onUserSelected,
  });

  @override
  ConsumerState<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<_UserSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  UserEntity? _foundUser;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    if (_searchQuery.trim().isEmpty) {
      setState(() {
        _foundUser = null;
        _errorMessage = 'メールアドレスまたはユーザーIDを入力してください';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _foundUser = null;
      _errorMessage = null;
    });

    final repository = ref.read(authRepositoryProvider);

    // email 또는 userId로 검색
    final isEmail = _searchQuery.contains('@');
    final result = isEmail
        ? await repository.searchUser(email: _searchQuery.trim())
        : await repository.searchUser(userId: _searchQuery.trim());

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSearching = false;
          _errorMessage = failure.message;
        });
      },
      (user) {
        setState(() {
          _isSearching = false;
          if (user == null) {
            _errorMessage = 'ユーザーが見つかりませんでした';
          } else {
            _foundUser = user;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        // 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'メールアドレスまたはユーザーID',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onSubmitted: (_) => _searchUser(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSearching ? null : _searchUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('検索'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 검색 결과
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                )
              : _foundUser != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: widget.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(Icons.person, color: widget.primaryColor),
                      ),
                      title: Text(
                        _foundUser!.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(_foundUser!.email),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onLongPress: () {
                              Clipboard.setData(
                                ClipboardData(text: _foundUser!.userId),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ユーザーIDをコピーしました'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              'ユーザーID: ${_foundUser!.userId}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => widget.onUserSelected(_foundUser!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('選択'),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'メールアドレスまたはユーザーIDで検索してください',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// 교회 검색 시트 (프로필 편집용)
class _ParishSearchSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final Color primaryColor;
  final String? selectedParishId;
  final void Function(String parishId, String parishName) onParishSelected;

  const _ParishSearchSheet({
    required this.scrollController,
    required this.primaryColor,
    this.selectedParishId,
    required this.onParishSelected,
  });

  @override
  ConsumerState<_ParishSearchSheet> createState() => _ParishSearchSheetState();
}

class _ParishSearchSheetState extends ConsumerState<_ParishSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allParishesAsync = ref.watch(core.allParishesProvider);

    return Column(
      children: [
        // 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        // 타이틀
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '所属教会を選択',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '教会名で検索',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        const SizedBox(height: 16),

        // 교회 목록
        Expanded(
          child: allParishesAsync.when(
            data: (allParishesMap) {
              final allParishes = <Map<String, dynamic>>[];
              allParishesMap.forEach((dioceseId, parishes) {
                for (final parish in parishes) {
                  final parishId = '$dioceseId-${parish['name']}';
                  allParishes.add({...parish, 'parishId': parishId});
                }
              });

              // 검색 필터링
              final filteredParishes = _searchQuery.isEmpty
                  ? allParishes
                  : allParishes.where((parish) {
                      final name = (parish['name'] as String? ?? '')
                          .toLowerCase();
                      final address = (parish['address'] as String? ?? '')
                          .toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || address.contains(query);
                    }).toList();

              if (filteredParishes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '検索結果がありません',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredParishes.length,
                itemBuilder: (context, index) {
                  final parish = filteredParishes[index];
                  final name = parish['name'] as String? ?? '';
                  final address = parish['address'] as String? ?? '';
                  final parishId = parish['parishId'] as String? ?? '';
                  final isSelected = widget.selectedParishId == parishId;

                  return ListTile(
                    key: ValueKey(parishId),
                    leading: CircleAvatar(
                      backgroundColor: widget.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.church,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: widget.primaryColor)
                        : Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                    onTap: () => widget.onParishSelected(parishId, name),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('エラー: $error')),
          ),
        ),
      ],
    );
  }
}
