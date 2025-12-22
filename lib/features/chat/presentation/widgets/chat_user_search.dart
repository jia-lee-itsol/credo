import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_user_entity.dart';
import '../providers/chat_providers.dart';

/// 사용자 검색 위젯
class ChatUserSearch extends ConsumerStatefulWidget {
  final Function(ChatUserEntity user) onUserSelected;
  final String? excludeUserId;

  const ChatUserSearch({
    super.key,
    required this.onUserSelected,
    this.excludeUserId,
  });

  @override
  ConsumerState<ChatUserSearch> createState() => _ChatUserSearchState();
}

class _ChatUserSearchState extends ConsumerState<ChatUserSearch> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchResults = ref.watch(userSearchProvider(_query));

    return Column(
      children: [
        // 검색 입력 필드
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '닉네임으로 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() => _query = value.trim());
            },
          ),
        ),

        // 검색 결과
        Expanded(
          child: searchResults.when(
            data: (users) {
              final filteredUsers = users
                  .where((u) => u.userId != widget.excludeUserId)
                  .toList();

              if (_query.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '닉네임을 검색해주세요',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '검색 결과가 없습니다',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      key: ValueKey(user.profileImageUrl ?? 'no-image'),
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: user.profileImageUrl == null
                          ? Text(
                              user.nickname[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(user.nickname),
                    onTap: () => widget.onUserSelected(user),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('오류가 발생했습니다: $error'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

