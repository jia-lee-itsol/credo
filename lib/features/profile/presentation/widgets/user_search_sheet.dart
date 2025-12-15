import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_localizations.dart';
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

  Future<void> _searchUser() async {
    final l10n = ref.read(appLocalizationsSyncProvider);
    if (_searchQuery.trim().isEmpty) {
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
                              '${l10n.profile.userId}: ${_foundUser!.userId}',
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
                        child: Text(l10n.common.select),
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
