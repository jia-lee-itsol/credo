import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// QR 코드 바텀시트 (QR 보기 및 QR 스캔 탭)
class QrCodeBottomSheet extends ConsumerStatefulWidget {
  final String userId;
  final String nickname;
  final Color primaryColor;

  const QrCodeBottomSheet({
    super.key,
    required this.userId,
    required this.nickname,
    required this.primaryColor,
  });

  @override
  ConsumerState<QrCodeBottomSheet> createState() => _QrCodeBottomSheetState();

  static void show(
    BuildContext context, {
    required String userId,
    required String nickname,
    required Color primaryColor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrCodeBottomSheet(
        userId: userId,
        nickname: nickname,
        primaryColor: primaryColor,
      ),
    );
  }
}

class _QrCodeBottomSheetState extends ConsumerState<QrCodeBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    if (_isProcessing) return;
    final l10n = ref.read(appLocalizationsSyncProvider);

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await SimpleBarcodeScanner.scanBarcode(context);

      if (!mounted) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      if (result == null || result.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final rawValue = result;

      // "credo:userId" 형식인지 확인
      if (!rawValue.startsWith('credo:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.qr.invalid),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final userId = rawValue.substring(6); // "credo:" 제거

      // 자신의 QR 코드를 스캔한 경우
      final currentUser = ref.read(currentUserProvider);
      if (currentUser?.userId == userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('自分のプロフィールです'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // 사용자 검색
      final repository = ref.read(authRepositoryProvider);
      final searchResult = await repository.searchUser(userId: userId);

      if (!mounted) return;

      searchResult.fold(
        (failure) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (user) {
          setState(() {
            _isProcessing = false;
          });
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.qr.userNotFound),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            _showUserFoundDialog(user);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.qr.scanError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUserFoundDialog(UserEntity user) {
    final l10n = ref.read(appLocalizationsSyncProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.qr.userFound),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.profile.godparent.nickname}: ${user.nickname}'),
            const SizedBox(height: 8),
            Text('${l10n.profile.godparent.email}: ${user.email}'),
            const SizedBox(height: 8),
            Text('${l10n.profile.userId}: ${user.userId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 탭바
          TabBar(
            controller: _tabController,
            labelColor: widget.primaryColor,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: widget.primaryColor,
            tabs: [
              Tab(icon: const Icon(Icons.qr_code), text: 'QR表示'),
              Tab(
                icon: const Icon(Icons.qr_code_scanner),
                text: l10n.qr.startScan,
              ),
            ],
          ),

          // 탭 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // QR 보기 탭
                _buildQrDisplayTab(theme),
                // QR 스캔 탭
                _buildQrScanTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrDisplayTab(ThemeData theme) {
    final l10n = ref.read(appLocalizationsSyncProvider);
    // QR 코드에 인코딩할 데이터: "credo:userId" 형식
    final qrData = 'credo:${widget.userId}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            l10n.profile.shareProfileQR,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.nickname,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'このQRコードをスキャンして\n友達を追加できます',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrScanTab(ThemeData theme) {
    final l10n = ref.read(appLocalizationsSyncProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: widget.primaryColor),
          const SizedBox(height: 24),
          Text(
            'QRコードをスキャン',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ボタンを押してQRコードをスキャンしてください',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _scanBarcode,
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.qr.startScan),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
