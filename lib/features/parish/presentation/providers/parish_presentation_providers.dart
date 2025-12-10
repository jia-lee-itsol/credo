import 'package:credo/features/parish/data/providers/parish_providers.dart';
import 'package:credo/features/parish/domain/entities/parish_entity.dart';
import 'package:credo/features/parish/domain/usecases/get_parishes_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 모든 교회 목록 Provider (Entity 기반)
final allParishesEntityProvider = FutureProvider<List<ParishEntity>>((
  ref,
) async {
  final repository = ref.watch(parishRepositoryProvider);
  final useCase = GetParishesUseCase(repository);

  final result = await useCase.call();
  return result.fold((failure) => throw failure, (parishes) => parishes);
});

/// 특정 교회 조회 Provider (Entity 기반)
final parishByIdEntityProvider = FutureProvider.family<ParishEntity?, String>((
  ref,
  parishId,
) async {
  final repository = ref.watch(parishRepositoryProvider);
  final useCase = GetParishByIdUseCase(repository);
  final result = await useCase.call(parishId);
  return result.fold((failure) => null, (parish) => parish);
});

/// 교회 검색 Provider
final searchParishesProvider =
    FutureProvider.family<List<ParishEntity>, String>((ref, query) async {
      final repository = ref.watch(parishRepositoryProvider);
      final useCase = SearchParishesUseCase(repository);
      final result = await useCase.call(query: query);
      return result.fold((failure) => throw failure, (parishes) => parishes);
    });
