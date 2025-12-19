import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/logger_service.dart';
import 'app_localizations.dart';
import '../../config/routes/app_routes.dart';

/// 공유 유틸리티
class ShareUtils {
  // 앱 기본 URL (딥링크용)
  static const String _appBaseUrl = 'https://credo.app';

  // 앱 스킴 (앱이 설치되어 있을 때 사용)
  static const String _appScheme = 'credo://';

  /// 딥링크 URL 생성
  static String _createDeepLink(String path) {
    return '$_appBaseUrl$path';
  }

  /// 앱 스킴 URL 생성
  static String _createAppSchemeUrl(String path) {
    return '$_appScheme$path';
  }

  /// 게시글 공유
  ///
  /// [context] BuildContext (iPad 지원용)
  /// [postTitle] 게시글 제목
  /// [parishId] 교구 ID
  /// [postId] 게시글 ID
  /// [l10n] 번역 객체
  static Future<void> sharePost({
    required BuildContext context,
    required String postTitle,
    required String parishId,
    required String postId,
    required AppLocalizations l10n,
  }) async {
    try {
      final deepLink = _createDeepLink(
        AppRoutes.postDetailPath(parishId, postId),
      );
      final appSchemeUrl = _createAppSchemeUrl(
        AppRoutes.postDetailPath(parishId, postId),
      );

      final shareText =
          '${l10n.community.sharePost}\n\n'
          '$postTitle\n\n'
          '${l10n.common.shareLink}: $deepLink\n'
          '${l10n.common.shareAppLink}: $appSchemeUrl';

      AppLogger.debug(
        '게시글 공유 시작: postId=$postId, shareText 길이=${shareText.length}',
      );

      // iOS/iPad에서 sharePositionOrigin 문제 해결
      ShareResult result;
      if (Platform.isIOS) {
        // iOS에서는 화면 하단 중앙에 공유 시트 표시
        final screenSize = MediaQuery.of(context).size;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final buttonSize = 60.0;
        final sharePositionOrigin = Rect.fromLTWH(
          (screenSize.width - buttonSize) / 2, // 화면 중앙
          screenSize.height - bottomPadding - buttonSize - 20, // 하단에서 약간 위
          buttonSize,
          buttonSize,
        );

        result = await Share.share(
          shareText,
          subject: postTitle,
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Android에서는 subject 포함하여 공유
        result = await Share.share(shareText, subject: postTitle);
      }

      AppLogger.debug('게시글 공유 완료: postId=$postId, status=${result.status}');
    } catch (e, stackTrace) {
      AppLogger.error('게시글 공유 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 일일 미사 독서 공유
  ///
  /// [context] BuildContext (iPad 지원용)
  /// [date] 날짜
  /// [readingTitle] 독서 제목
  /// [readingText] 독서 본문 (선택사항)
  /// [l10n] 번역 객체
  static Future<void> shareDailyMassReading({
    required BuildContext context,
    required DateTime date,
    String? readingTitle,
    String? readingText,
    required AppLocalizations l10n,
  }) async {
    try {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final deepLink = _createDeepLink(
        '${AppRoutes.dailyMass}?date=$dateString',
      );
      final appSchemeUrl = _createAppSchemeUrl(
        '${AppRoutes.dailyMass}?date=$dateString',
      );

      final shareText =
          '${l10n.mass.shareReading}\n\n'
          '${readingTitle != null ? '$readingTitle\n\n' : ''}'
          '${readingText != null && readingText.length > 200
              ? '${readingText.substring(0, 200)}...\n\n'
              : readingText != null
              ? '$readingText\n\n'
              : ''}'
          '${l10n.common.shareLink}: $deepLink\n'
          '${l10n.common.shareAppLink}: $appSchemeUrl';

      AppLogger.debug(
        '일일 미사 독서 공유 시작: date=$dateString, shareText 길이=${shareText.length}',
      );

      // iOS/iPad에서 sharePositionOrigin 문제 해결
      ShareResult result;
      if (Platform.isIOS) {
        // iOS에서는 화면 하단 중앙에 공유 시트 표시
        final screenSize = MediaQuery.of(context).size;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final buttonSize = 60.0;
        final sharePositionOrigin = Rect.fromLTWH(
          (screenSize.width - buttonSize) / 2, // 화면 중앙
          screenSize.height - bottomPadding - buttonSize - 20, // 하단에서 약간 위
          buttonSize,
          buttonSize,
        );

        result = await Share.share(
          shareText,
          subject: readingTitle ?? l10n.mass.shareReading,
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Android에서는 subject 포함하여 공유
        result = await Share.share(
          shareText,
          subject: readingTitle ?? l10n.mass.shareReading,
        );
      }

      AppLogger.debug(
        '일일 미사 독서 공유 완료: date=$dateString, status=${result.status}',
      );
    } catch (e, stackTrace) {
      AppLogger.error('일일 미사 독서 공유 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 교회 정보 공유
  ///
  /// [context] BuildContext (iPad 지원용)
  /// [parishName] 교회 이름
  /// [parishId] 교회 ID
  /// [address] 주소 (선택사항)
  /// [l10n] 번역 객체
  static Future<void> shareParish({
    required BuildContext context,
    required String parishName,
    required String parishId,
    String? address,
    required AppLocalizations l10n,
  }) async {
    try {
      final deepLink = _createDeepLink(AppRoutes.parishDetailPath(parishId));
      final appSchemeUrl = _createAppSchemeUrl(
        AppRoutes.parishDetailPath(parishId),
      );

      final shareText =
          '${l10n.parish.shareParish ?? 'この教会をシェア'}\n\n'
          '$parishName\n'
          '${address != null ? '$address\n' : ''}'
          '${l10n.common.shareLink}: $deepLink\n'
          '${l10n.common.shareAppLink}: $appSchemeUrl';

      AppLogger.debug(
        '교회 정보 공유 시작: parishId=$parishId, shareText 길이=${shareText.length}',
      );

      // iOS/iPad에서 sharePositionOrigin 문제 해결
      ShareResult result;
      if (Platform.isIOS) {
        // iOS에서는 화면 하단 중앙에 공유 시트 표시
        final screenSize = MediaQuery.of(context).size;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final buttonSize = 60.0;
        final sharePositionOrigin = Rect.fromLTWH(
          (screenSize.width - buttonSize) / 2, // 화면 중앙
          screenSize.height - bottomPadding - buttonSize - 20, // 하단에서 약간 위
          buttonSize,
          buttonSize,
        );

        result = await Share.share(
          shareText,
          subject: parishName,
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Android에서는 subject 포함하여 공유
        result = await Share.share(shareText, subject: parishName);
      }

      AppLogger.debug(
        '교회 정보 공유 완료: parishId=$parishId, status=${result.status}',
      );
    } catch (e, stackTrace) {
      AppLogger.error('교회 정보 공유 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 일반 텍스트 공유
  static Future<void> shareText({
    required BuildContext context,
    required String text,
    String? subject,
  }) async {
    try {
      AppLogger.debug('텍스트 공유 시작: text 길이=${text.length}');

      // iOS/iPad에서 sharePositionOrigin 문제 해결
      ShareResult result;
      if (Platform.isIOS) {
        // iOS에서는 화면 하단 중앙에 공유 시트 표시
        final screenSize = MediaQuery.of(context).size;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final buttonSize = 60.0;
        final sharePositionOrigin = Rect.fromLTWH(
          (screenSize.width - buttonSize) / 2, // 화면 중앙
          screenSize.height - bottomPadding - buttonSize - 20, // 하단에서 약간 위
          buttonSize,
          buttonSize,
        );

        result = await Share.share(
          text,
          subject: subject,
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Android에서는 subject 포함하여 공유
        result = await Share.share(text, subject: subject);
      }

      AppLogger.debug('텍스트 공유 완료: status=${result.status}');
    } catch (e, stackTrace) {
      AppLogger.error('텍스트 공유 실패', e, stackTrace);
      rethrow;
    }
  }

  /// 딥링크 URL만 가져오기 (공유 외 용도)
  static String getPostDeepLink(String parishId, String postId) {
    return _createDeepLink(AppRoutes.postDetailPath(parishId, postId));
  }

  static String getParishDeepLink(String parishId) {
    return _createDeepLink(AppRoutes.parishDetailPath(parishId));
  }

  static String getDailyMassDeepLink(DateTime date) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _createDeepLink('${AppRoutes.dailyMass}?date=$dateString');
  }
}
