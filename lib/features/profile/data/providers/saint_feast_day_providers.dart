import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/saint_feast_day_repository_impl.dart';
import '../../domain/repositories/saint_feast_day_repository.dart';

/// Saint Feast Day Repository Provider
final saintFeastDayRepositoryProvider = Provider<SaintFeastDayRepository>((
  ref,
) {
  return SaintFeastDayRepositoryImpl();
});
