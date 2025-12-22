import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/widgets/badge_chip.dart';
import 'my_page_main_parish_row.dart';

/// 마이페이지 프로필 섹션 위젯
class MyPageProfileSection extends ConsumerWidget {
  final ThemeData theme;
  final Color primaryColor;
  final bool isAuthenticated;
  final dynamic currentUser;
  final String? mainParishId;

  const MyPageProfileSection({
    super.key,
    required this.theme,
    required this.primaryColor,
    required this.isAuthenticated,
    required this.currentUser,
    this.mainParishId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // 프로필 이미지
                CircleAvatar(
                  key: ValueKey(
                    currentUser?.profileImageUrl ?? 'no-image',
                  ), // 이미지 URL이 변경되면 위젯 재생성
                  radius: 36,
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  backgroundImage: isAuthenticated &&
                          currentUser != null &&
                          currentUser.profileImageUrl != null
                      ? NetworkImage(currentUser.profileImageUrl!)
                      : null,
                  child: isAuthenticated &&
                          currentUser != null &&
                          currentUser.profileImageUrl != null
                      ? null
                      : Icon(Icons.person, size: 36, color: primaryColor),
                ),
                const SizedBox(width: 16),

                // 프로필 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isAuthenticated
                                  ? (currentUser?.nickname ?? 'ユーザー')
                                  : 'ゲスト',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isAuthenticated &&
                              currentUser != null &&
                              currentUser.isVerified) ...[
                            const SizedBox(width: 8),
                            BadgeChip.official(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAuthenticated
                            ? (currentUser?.email ?? '')
                            : l10n.profile.pleaseLogin,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isAuthenticated && currentUser != null) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(
                              ClipboardData(text: currentUser.userId),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.profile.userIdCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            '${l10n.profile.userId}: ${currentUser.userId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 편집 버튼 (로그인 상태일 때만 표시)
                if (isAuthenticated)
                  IconButton(
                    onPressed: () {
                      context.push(AppRoutes.editProfile);
                    },
                    icon: const Icon(Icons.edit),
                  ),
              ],
            ),

            // 소속 본당 (프로필 하단)
            if (isAuthenticated) ...[
              const SizedBox(height: 16),
              MyPageMainParishRow(
                theme: theme,
                primaryColor: primaryColor,
                mainParishId: mainParishId,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

