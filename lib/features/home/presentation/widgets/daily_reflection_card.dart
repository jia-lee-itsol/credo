import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/daily_reflection_provider.dart';

/// 오늘의 묵상 한마디 카드
class DailyReflectionCard extends ConsumerWidget {
  const DailyReflectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final reflectionAsync = ref.watch(dailyReflectionProvider);
    final locale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.1),
                primaryColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.format_quote,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getTitle(locale.languageCode),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Spacer(),
                    // 새로고침 버튼
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      onPressed: () async {
                        await refreshDailyReflection(ref);
                      },
                      tooltip: _getRefreshTooltip(locale.languageCode),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 묵상 내용
                reflectionAsync.when(
                  data: (reflection) {
                    if (reflection == null || reflection.isEmpty) {
                      return _buildPlaceholder(theme, locale.languageCode);
                    }
                    return Text(
                      reflection,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                  loading: () => _buildLoading(theme, locale.languageCode),
                  error: (error, stack) => _buildPlaceholder(theme, locale.languageCode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme, String languageCode) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _getLoadingText(languageCode),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme, String languageCode) {
    return Text(
      _getPlaceholderText(languageCode),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  String _getTitle(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '今日の黙想';
      case 'ko':
        return '오늘의 묵상';
      case 'en':
        return "Today's Reflection";
      case 'zh':
        return '今日默想';
      case 'vi':
        return 'Suy niệm hôm nay';
      case 'es':
        return 'Reflexión de hoy';
      case 'pt':
        return 'Reflexão de hoje';
      default:
        return '今日の黙想';
    }
  }

  String _getLoadingText(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '黙想を準備しています...';
      case 'ko':
        return '묵상을 준비하고 있습니다...';
      case 'en':
        return 'Preparing reflection...';
      case 'zh':
        return '正在准备默想...';
      case 'vi':
        return 'Đang chuẩn bị suy niệm...';
      case 'es':
        return 'Preparando reflexión...';
      case 'pt':
        return 'Preparando reflexão...';
      default:
        return '黙想を準備しています...';
    }
  }

  String _getPlaceholderText(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '今日も主と共に歩みましょう。';
      case 'ko':
        return '오늘도 주님과 함께 걸어갑시다.';
      case 'en':
        return 'Let us walk with the Lord today.';
      case 'zh':
        return '今天也让我们与主同行。';
      case 'vi':
        return 'Hôm nay chúng ta hãy bước đi cùng Chúa.';
      case 'es':
        return 'Caminemos hoy con el Señor.';
      case 'pt':
        return 'Vamos caminhar com o Senhor hoje.';
      default:
        return '今日も主と共に歩みましょう。';
    }
  }

  String _getRefreshTooltip(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '新しい黙想を生成';
      case 'ko':
        return '새로운 묵상 생성';
      case 'en':
        return 'Generate new reflection';
      case 'zh':
        return '生成新的默想';
      case 'vi':
        return 'Tạo suy niệm mới';
      case 'es':
        return 'Generar nueva reflexión';
      case 'pt':
        return 'Gerar nova reflexão';
      default:
        return '新しい黙想を生成';
    }
  }
}
