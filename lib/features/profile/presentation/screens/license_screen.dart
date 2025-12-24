import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 라이선스 화면
class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  List<LicenseEntry> _licenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    final licenses = <LicenseEntry>[];
    await for (final license in LicenseRegistry.licenses) {
      licenses.add(license);
    }
    if (mounted) {
      setState(() {
        _licenses = licenses;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('ライセンス')),
      body: CustomScrollView(
        slivers: [
          // 커스텀 헤더
          SliverToBoxAdapter(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 앱 로고
                  Image.asset(
                    'assets/icons/logo.png',
                    width: 256,
                    height: 256,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  // 버전 정보
                  Text(
                    '1.0.0',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 회사 로고
                  Image.asset(
                    'assets/icons/itz.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  // 저작권 정보
                  Text(
                    '© 2026 ITSolutionz Inc.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 구분선
                  Divider(color: colorScheme.outlineVariant, height: 1),
                ],
              ),
            ),
          ),
          // 라이선스 목록
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _licenses.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text('データがありません', style: theme.textTheme.bodyLarge),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final license = _licenses[index];
                      final packages = license.packages;
                      final paragraphs = license.paragraphs;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: const Icon(Icons.description),
                          title: Text(
                            packages.join(', '),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${paragraphs.length}件のライセンス',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: paragraphs.map((paragraph) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      paragraph.text,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(height: 1.6),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: _licenses.length),
                  ),
                ),
        ],
      ),
    );
  }
}
