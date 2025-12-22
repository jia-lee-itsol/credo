import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/chat_repository.dart';
import '../repositories/firestore_chat_repository.dart';

/// ChatRepository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirestoreChatRepository();
});

