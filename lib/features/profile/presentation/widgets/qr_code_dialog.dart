import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  MobileScannerController? _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      // QR 스캔 탭이 활성화되면 카메라 컨트롤러 초기화
      if (_scannerController == null) {
        setState(() {
          _scannerController = MobileScannerController();
        });
      }
    } else {
      // 다른 탭으로 전환되면 카메라 컨트롤러 해제
      if (_scannerController != null) {
        _scannerController?.dispose();
        setState(() {
          _scannerController = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scannerController?.dispose();
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
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            tabs: const [
              Tab(icon: Icon(Icons.qr_code), text: 'QR表示'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'QRスキャン'),
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
    // QR 코드에 인코딩할 데이터: "credo:userId" 형식
    final qrData = 'credo:${widget.userId}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'プロフィールを共有',
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
    if (_scannerController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController!,
          onDetect: _handleBarcode,
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        // 스캔 가이드 오버레이
        Positioned.fill(
          child: CustomPaint(
            painter: _ScannerOverlayPainter(widget.primaryColor),
          ),
        ),
        // 하단 안내 텍스트
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
