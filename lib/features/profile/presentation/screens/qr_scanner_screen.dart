import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (_isProcessing) return;

    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null) return;

    // "credo:userId" 형식인지 확인
    if (!rawValue.startsWith('credo:')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('無効なQRコードです'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

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
    final result = await repository.searchUser(userId: userId);

    if (!mounted) return;

    result.fold(
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
            const SnackBar(
              content: Text('ユーザーが見つかりませんでした'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // TODO: 메신저 기능 구현 시 여기서 사용자 추가 처리
          // 현재는 사용자 정보를 표시만 함
          _showUserFoundDialog(user);
        }
      },
    );
  }

  void _showUserFoundDialog(UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ユーザーが見つかりました'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ニックネーム: ${user.nickname}'),
            const SizedBox(height: 8),
            Text('メール: ${user.email}'),
            const SizedBox(height: 8),
            Text('ユーザーID: ${user.userId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          // TODO: 메신저 기능 구현 시 "友達追加" 버튼 추가
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードをスキャン'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          // 스캔 가이드 오버레이
          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(primaryColor),
            ),
          ),
          // 하단 안내 텍스트
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'QRコードを枠内に合わせてください',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 스캔 가이드 오버레이 페인터
class _ScannerOverlayPainter extends CustomPainter {
  final Color primaryColor;

  _ScannerOverlayPainter(this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 전체 화면 어둡게
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 중앙 스캔 영역 (정사각형)
    final scanSize = size.width * 0.7;
    final scanLeft = (size.width - scanSize) / 2;
    final scanTop = (size.height - scanSize) / 2;
    final scanRect = Rect.fromLTWH(scanLeft, scanTop, scanSize, scanSize);

    // 중앙 영역만 투명하게
    canvas.drawRect(scanRect, Paint()..blendMode = BlendMode.clear);

    // 스캔 영역 테두리
    canvas.drawRect(scanRect, borderPaint);

    // 모서리 코너
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // 좌상단
    canvas.drawLine(
      Offset(scanLeft, scanTop),
      Offset(scanLeft + cornerLength, scanTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft, scanTop),
      Offset(scanLeft, scanTop + cornerLength),
      cornerPaint,
    );

    // 우상단
    canvas.drawLine(
      Offset(scanLeft + scanSize, scanTop),
      Offset(scanLeft + scanSize - cornerLength, scanTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft + scanSize, scanTop),
      Offset(scanLeft + scanSize, scanTop + cornerLength),
      cornerPaint,
    );

    // 좌하단
    canvas.drawLine(
      Offset(scanLeft, scanTop + scanSize),
      Offset(scanLeft + cornerLength, scanTop + scanSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft, scanTop + scanSize),
      Offset(scanLeft, scanTop + scanSize - cornerLength),
      cornerPaint,
    );

    // 우하단
    canvas.drawLine(
      Offset(scanLeft + scanSize, scanTop + scanSize),
      Offset(scanLeft + scanSize - cornerLength, scanTop + scanSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanLeft + scanSize, scanTop + scanSize),
      Offset(scanLeft + scanSize, scanTop + scanSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

