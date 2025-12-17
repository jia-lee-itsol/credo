import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/services/search_history_service.dart';

/// 게시글 검색 히스토리 Provider
final postSearchHistoryProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return SearchHistoryService.getPostSearchHistory();
});

/// 성당 검색 히스토리 Provider
final parishSearchHistoryProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return SearchHistoryService.getParishSearchHistory();
});
