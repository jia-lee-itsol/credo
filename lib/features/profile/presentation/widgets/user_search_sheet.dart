import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// 유저 검색 시트
class UserSearchSheet extends ConsumerStatefulWidget {
  final Color primaryColor;
  final String title;
  final void Function(UserEntity) onUserSelected;

  const UserSearchSheet({
    super.key,
    required this.primaryColor,
    required this.title,
    required this.onUserSelected,
  });

  @override
  ConsumerState<UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<UserSearchSheet> {
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

  /// 이메일 형식인지 확인하는 정규식
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _searchUser() async {
    final l10n = ref.read(appLocalizationsSyncProvider);
    final trimmedQuery = _searchQuery.trim();
    
    AppLogger.profile('사용자 검색 시작: $trimmedQuery');
    
    if (trimmedQuery.isEmpty) {
      AppLogger.profile('검색어가 비어있음');
      setState(() {
        _foundUser = null;
        _errorMessage = l10n.search.userSearchRequired;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _foundUser = null;
      _errorMessage = null;
    });

    final repository = ref.read(authRepositoryProvider);

    // 이메일 형식인지 확인하여 email, nickname 또는 userId로 검색
    final isEmail = _isValidEmail(trimmedQuery);
    AppLogger.profile('검색 타입: ${isEmail ? "이메일" : "닉네임 또는 사용자 ID"}');
    
    final result = isEmail
        ? await repository.searchUser(email: trimmedQuery)
        : await repository.searchUser(nickname: trimmedQuery);

    if (!mounted) {
      AppLogger.profile('위젯이 마운트되지 않음, 검색 취소');
      return;
    }

    result.fold(
      (failure) {
        AppLogger.profile('검색 실패: ${failure.message}');
        setState(() {
          _isSearching = false;
          _errorMessage = failure.message;
        });
      },
      (user) {
        if (user == null) {
          AppLogger.profile('사용자를 찾을 수 없음');
          setState(() {
            _isSearching = false;
            _errorMessage = l10n.profile.godparent.userNotFound;
          });
        } else {
          AppLogger.profile('사용자 검색 성공: ${user.userId}, ${user.email}');
          setState(() {
            _isSearching = false;
            _foundUser = user;
            _errorMessage = null;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);

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
                    hintText: l10n.search.userSearchHint,
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
                    : Text(l10n.common.search),
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
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: widget.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(Icons.person, color: widget.primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _foundUser!.nickname,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _foundUser!.email,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onLongPress: () {
                                      Clipboard.setData(
                                        ClipboardData(text: _foundUser!.userId),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.profile.godparent.userIdCopied),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${l10n.profile.userId}: ${_foundUser!.userId}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => widget.onUserSelected(_foundUser!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(l10n.common.select),
                            ),
                          ],
                        ),
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
                        l10n.profile.godparent.searchUser,
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
