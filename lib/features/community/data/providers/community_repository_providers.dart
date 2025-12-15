import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../repositories/firestore_notification_repository.dart';
import '../repositories/firestore_post_repository.dart';
import '../repositories/firestore_report_repository.dart';
import '../repositories/firestore_user_repository.dart';

/// PostRepository Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return FirestorePostRepository();
});

/// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository();
});

/// NotificationRepository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirestoreNotificationRepository();
});

/// ReportRepository Provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return FirestoreReportRepository();
});
