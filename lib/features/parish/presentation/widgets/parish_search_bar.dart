import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/data/services/search_history_service.dart';
import '../../../../shared/providers/search_history_provider.dart';
import '../../../../core/data/services/parish_service.dart';

/// 교회 검색바 위젯 (히스토리 및 자동완성 지원)
class ParishSearchBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const ParishSearchBar({super.key, required this.controller, this.onChanged});

  @override
  ConsumerState<ParishSearchBar> createState() => _ParishSearchBarState();
}

class _ParishSearchBarState extends ConsumerState<ParishSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
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
      final historyAsync = ref.read(parishSearchHistoryProvider);
      final history = historyAsync.valueOrNull ?? [];
      if (mounted) {
        setState(() {
          _suggestions = history;
        });
      }
    } else {
      // 검색어가 있으면 자동완성 (성당 이름 기반)
      final allParishes = await ParishService.loadAllParishes();
      final matchingNames = <String>[];

      for (final dioceseParishes in allParishes.values) {
        for (final parish in dioceseParishes) {
          final name = (parish['name'] as String? ?? '').toLowerCase();
          final address = (parish['address'] as String? ?? '').toLowerCase();
          final prefecture = (parish['prefecture'] as String? ?? '')
              .toLowerCase();

          if (name.contains(query) ||
              address.contains(query) ||
              prefecture.contains(query)) {
            final displayName = parish['name'] as String? ?? '';
            if (!matchingNames.contains(displayName)) {
              matchingNames.add(displayName);
              if (matchingNames.length >= 5) break;
            }
          }
        }
        if (matchingNames.length >= 5) break;
      }

      // 히스토리에서도 매칭되는 항목 추가
      final historyAsync = ref.read(parishSearchHistoryProvider);
      final history = historyAsync.valueOrNull ?? [];
      final matchingHistory = history
          .where((item) => item.toLowerCase().contains(query))
          .take(3)
          .toList();

      if (mounted) {
        setState(() {
          _suggestions = [
            ...matchingNames,
            ...matchingHistory,
          ].take(8).toList();
        });
      }
    }
  }

  void _onSuggestionTap(String suggestion) {
    widget.controller.text = suggestion;
    widget.onChanged?.call(suggestion);
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      SearchHistoryService.saveParishSearchHistory(value.trim());
      ref.invalidate(parishSearchHistoryProvider);
    }
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  Future<void> _removeHistoryItem(String item) async {
    await SearchHistoryService.removeParishSearchHistory(item);
    ref.invalidate(parishSearchHistoryProvider);
    _loadSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final historyAsync = ref.watch(parishSearchHistoryProvider);

    return Column(
      children: [
        Container(
          height: 49.361,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 0.69),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              letterSpacing: -0.31,
            ),
            decoration: InputDecoration(
              hintText: l10n.search.parishSearchHint,
              hintStyle: const TextStyle(
                color: Color(0x800A0A0A),
                fontSize: 16,
                letterSpacing: -0.31,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.search, size: 20, color: Color(0x800A0A0A)),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged?.call('');
                        _focusNode.requestFocus();
                        _loadSuggestions();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
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
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
