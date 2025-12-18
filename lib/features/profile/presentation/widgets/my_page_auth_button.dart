import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';

/// 마이페이지 로그인/로그아웃 버튼 위젯
class MyPageAuthButton extends ConsumerWidget {
  final Color primaryColor;
  final bool isAuthenticated;

  const MyPageAuthButton({
    super.key,
    required this.primaryColor,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsSyncProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: () async {
          if (isAuthenticated) {
            // 로그아웃
            await _handleSignOut(context, ref);
          } else {
            // 로그인 페이지로 이동
            context.push(AppRoutes.signIn);
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryColor),
        ),
        child: Text(
          isAuthenticated ? l10n.auth.signOut : l10n.auth.signIn,
          style: TextStyle(color: primaryColor),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signOut();

    if (!context.mounted) return;

    final l10n = ref.read(appLocalizationsSyncProvider);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.auth.signOutSuccess),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}

