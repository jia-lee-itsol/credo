import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// QR 코드 스캔 화면
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _isProcessing = false;

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
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('自分のプロフィールです'),
            backgroundColor: Colors.orange,
          ),
        );
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
            // TODO: 메신저/친구 기능 구현 시 여기서 사용자 추가 처리
            // 현재는 사용자 정보를 표시만 함
            // 메신저 기능이 구현되면 여기서 친구 추가 또는 메시지 전송 기능을 구현해야 함
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
          SnackBar(content: Text('スキャンエラー: $e'), backgroundColor: Colors.red),
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
          // TODO: 메신저/친구 기능 구현 시 "友達追加" 버튼 추가
          // 메신저 기능이 구현되면 여기에 친구 추가 버튼을 추가해야 함
          // 예: TextButton(onPressed: () => _addFriend(user), child: Text(l10n.qr.addFriend))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsSyncProvider);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('QRコードをスキャン'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: primaryColor),
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
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
