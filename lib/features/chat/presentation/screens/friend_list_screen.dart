import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/entities/friend_entity.dart';
import '../providers/friend_providers.dart';

/// 친구 목록 화면 (검색, 친구, QR 코드 탭)
class FriendListScreen extends ConsumerStatefulWidget {
  const FriendListScreen({super.key});

  @override
  ConsumerState<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends ConsumerState<FriendListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 기본으로 친구 목록 탭(index: 1)을 보여줌
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('친구')),
        body: const Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('친구'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: '검색'),
            Tab(icon: Icon(Icons.people), text: '친구'),
            Tab(icon: Icon(Icons.qr_code), text: 'QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 검색 탭
          _SearchTab(primaryColor: primaryColor),
          // 친구 목록 탭
          _FriendsTab(primaryColor: primaryColor),
          // QR 코드 탭
          _QRCodeTab(
            userId: currentUser.userId,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

/// 검색 탭
class _SearchTab extends ConsumerStatefulWidget {
  final Color primaryColor;

  const _SearchTab({required this.primaryColor});

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchResults = ref.watch(friendUserSearchProvider(_query));

    return Column(
      children: [
        // 검색 입력 필드
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '닉네임, 이메일 또는 ID로 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() => _query = value.trim());
            },
          ),
        ),

        // 검색 결과
        Expanded(
          child: searchResults.when(
            data: (users) {
              if (_query.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '사용자를 검색해주세요',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '닉네임, 이메일, 사용자 ID로 검색할 수 있습니다',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '검색 결과가 없습니다',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserListTile(
                    user: user,
                    primaryColor: widget.primaryColor,
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Text('오류: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

/// 사용자 리스트 타일
class _UserListTile extends ConsumerWidget {
  final ChatUserEntity user;
  final Color primaryColor;

  const _UserListTile({
    required this.user,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final friendRelationAsync = ref.watch(friendRelationProvider(user.userId));

    return ListTile(
      leading: CircleAvatar(
        key: ValueKey(user.profileImageUrl ?? 'no-image'),
        backgroundImage: user.profileImageUrl != null
            ? NetworkImage(user.profileImageUrl!)
            : null,
        backgroundColor: primaryColor.withValues(alpha: 0.1),
        child: user.profileImageUrl == null
            ? Text(
                user.nickname[0].toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(user.nickname),
      subtitle: Text(
        'ID: ${user.userId}',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
      trailing: friendRelationAsync.when(
        data: (relation) {
          if (relation?.status == FriendStatus.accepted) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '친구',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          } else if (relation?.status == FriendStatus.blocked) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '차단됨',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const Icon(Icons.chevron_right, color: Colors.grey);
        },
        loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, __) => const Icon(Icons.chevron_right, color: Colors.grey),
      ),
      onTap: () {
        context.push(AppRoutes.userProfilePath(user.userId));
      },
    );
  }
}

/// 친구 목록 탭
class _FriendsTab extends ConsumerWidget {
  final Color primaryColor;

  const _FriendsTab({required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final friendsAsync = ref.watch(friendsStreamProvider);

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '아직 친구가 없습니다',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '검색 또는 QR 코드로 친구를 추가해보세요',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: friends.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final friend = friends[index];
            return ListTile(
              leading: CircleAvatar(
                key: ValueKey(friend.friendProfileImageUrl ?? 'no-image'),
                backgroundImage: friend.friendProfileImageUrl != null
                    ? NetworkImage(friend.friendProfileImageUrl!)
                    : null,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child: friend.friendProfileImageUrl == null
                    ? Text(
                        friend.friendNickname[0].toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(friend.friendNickname),
              onTap: () {
                context.push(AppRoutes.userProfilePath(friend.friendUserId));
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류: $error'),
          ],
        ),
      ),
    );
  }
}

/// QR 코드 탭
class _QRCodeTab extends ConsumerStatefulWidget {
  final String userId;
  final Color primaryColor;

  const _QRCodeTab({
    required this.userId,
    required this.primaryColor,
  });

  @override
  ConsumerState<_QRCodeTab> createState() => _QRCodeTabState();
}

class _QRCodeTabState extends ConsumerState<_QRCodeTab> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrData = 'credo://user/${widget.userId}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 내 QR 코드
          Text(
            '내 QR 코드',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '친구가 이 코드를 스캔하면 나를 추가할 수 있습니다',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // QR 코드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: widget.primaryColor,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: widget.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 사용자 ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ID: ${widget.userId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ),

          const SizedBox(height: 32),

          // QR 스캔 버튼
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isScanning ? null : _scanQRCode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR 코드 스캔하기'),
              style: FilledButton.styleFrom(
                backgroundColor: widget.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 사용자의 QR 코드를 스캔해서 친구를 추가하세요',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),

          if (_isScanning) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    setState(() => _isScanning = true);

    try {
      final result = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'QR 코드 스캔',
          centerTitle: true,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back),
        ),
        isShowFlashIcon: true,
        delayMillis: 500,
        cameraFace: CameraFace.back,
      );

      if (!mounted) return;

      if (result == null || result == '-1' || result.isEmpty) {
        // 취소됨
        return;
      }

      // QR 코드 파싱 ("credo://user/userId" 또는 "credo:userId" 형식)
      String? userId;
      if (result.startsWith('credo://user/')) {
        userId = result.replaceFirst('credo://user/', '');
      } else if (result.startsWith('credo:')) {
        userId = result.substring(6); // "credo:" 제거
      }

      if (userId != null && userId.isNotEmpty) {
        // 사용자 프로필로 이동
        context.push(AppRoutes.userProfilePath(userId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효하지 않은 QR 코드입니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스캔 오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }
}

