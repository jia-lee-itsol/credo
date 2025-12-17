import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/data/services/search_history_service.dart';
import '../../../../shared/providers/search_history_provider.dart';
import '../providers/community_presentation_providers.dart';

/// 게시글 목록 검색 바 위젯 (히스토리 및 자동완성 지원)
class PostListSearchBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String? parishId;

  const PostListSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    this.parishId,
  });

  @override
  ConsumerState<PostListSearchBar> createState() => _PostListSearchBarState();
}

class _PostListSearchBarState extends ConsumerState<PostListSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // 포커스가 없어지면 잠시 후 숨김 (탭 이벤트 처리 시간 확보)
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showSuggestions = false);
          }
        });
      }
    });
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final query = widget.controller.text;
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = true;
        _loadSuggestions();
      });
    } else {
      _loadSuggestions();
    }
  }

  Future<void> _loadSuggestions() async {
    final query = widget.controller.text.toLowerCase().trim();

    if (query.isEmpty) {
      // 검색어가 없으면 히스토리 표시
      final historyAsync = ref.read(postSearchHistoryProvider);
      final history = historyAsync.valueOrNull ?? [];
      if (mounted) {
        setState(() {
          _suggestions = history;
        });
      }
    } else {
      // 검색어가 있으면 자동완성 (게시글 제목 기반)
      final postsAsync = ref.read(allPostsProvider(widget.parishId));
      final posts = postsAsync.valueOrNull ?? [];
      final matchingTitles = posts
          .where(
            (post) =>
                post.title.toLowerCase().contains(query) ||
                post.body.toLowerCase().contains(query),
          )
          .map((post) => post.title)
          .take(5)
          .toSet()
          .toList();

      // 히스토리에서도 매칭되는 항목 추가
      final historyAsync = ref.read(postSearchHistoryProvider);
      final history = historyAsync.valueOrNull ?? [];
      final matchingHistory = history
          .where((item) => item.toLowerCase().contains(query))
          .take(3)
          .toList();

      if (mounted) {
        setState(() {
          _suggestions = [
            ...matchingTitles,
            ...matchingHistory,
          ].take(8).toList();
        });
      }
    }
  }

  void _onSuggestionTap(String suggestion) {
    widget.controller.text = suggestion;
    widget.onChanged(suggestion);
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      SearchHistoryService.savePostSearchHistory(value.trim());
      ref.invalidate(postSearchHistoryProvider);
    }
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  Future<void> _removeHistoryItem(String item) async {
    await SearchHistoryService.removePostSearchHistory(item);
    ref.invalidate(postSearchHistoryProvider);
    _loadSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final historyAsync = ref.watch(postSearchHistoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: l10n.community.searchPost,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: widget.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.onClear();
                        _focusNode.requestFocus();
                        _loadSuggestions();
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
            onChanged: (value) {
              widget.onChanged(value);
              if (_focusNode.hasFocus) {
                setState(() => _showSuggestions = true);
              }
            },
            onSubmitted: _onSearchSubmitted,
            onTap: () {
              setState(() => _showSuggestions = true);
              _loadSuggestions();
            },
          ),
        ),
        // 검색 제안 목록
        if (_showSuggestions && _focusNode.hasFocus)
          historyAsync.when(
            data: (history) {
              if (_suggestions.isEmpty && widget.controller.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    final isHistory = history.contains(suggestion);

                    return ListTile(
                      leading: Icon(
                        isHistory ? Icons.history : Icons.search,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      title: Text(
                        suggestion,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: isHistory
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeHistoryItem(suggestion),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          : null,
                      onTap: () => _onSuggestionTap(suggestion),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}
