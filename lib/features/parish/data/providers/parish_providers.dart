import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/parish_repository_impl.dart';
import '../../domain/repositories/parish_repository.dart';

/// Parish Repository Provider
final parishRepositoryProvider = Provider<ParishRepository>((ref) {
  return ParishRepositoryImpl();
});
