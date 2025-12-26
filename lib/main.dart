import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/routes/app_router.dart';
import 'core/data/services/push_notification_service.dart';
import 'core/utils/app_localizations.dart';
import 'shared/providers/liturgy_theme_provider.dart';
import 'shared/providers/font_scale_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 디버그 모드: 위젯 보더 표시
  debugPaintSizeEnabled = false;

  // 환경 변수 로드
  await dotenv.load(fileName: '.env');

  // 날짜 로케일 초기화 (기본값: 일본어, 나중에 localeProvider에서 동적으로 변경됨)
  await initializeDateFormatting('ja', null);

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FCM 푸시 알림 초기화
  await PushNotificationService().initialize();

  runApp(const ProviderScope(child: CredoApp()));
}

/// Credo 앱 루트 위젯
class CredoApp extends ConsumerStatefulWidget {
  const CredoApp({super.key});

  @override
  ConsumerState<CredoApp> createState() => _CredoAppState();
}

class _CredoAppState extends ConsumerState<CredoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 포그라운드로 돌아올 때 뱃지 초기화
    if (state == AppLifecycleState.resumed) {
      PushNotificationService.clearBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    // 푸시 알림 서비스에 router 설정
    PushNotificationService().setRouter(router);

    // 인증 상태 감시: 사용자가 로그인하면 FCM 토큰 저장
    ref.listen<UserEntity?>(authStateProvider, (previous, next) {
      if (next != null && previous != next) {
        // 사용자가 로그인했거나 변경되었을 때 토큰 저장
        PushNotificationService().saveTokenForUser(next.userId);
      }
    });

    final fontScale = ref.watch(fontScaleProvider);
    final locale = ref.watch(localeProvider);

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(fontScale)),
      child: MaterialApp.router(
        title: 'Credo',
        debugShowCheckedModeBanner: false,

        // 테마
        theme: theme,

        // 라우팅
        routerConfig: router,

        // 로케일 설정
        locale: locale,
        supportedLocales: const [
          Locale('ja', 'JP'),
          Locale('en', 'US'),
          Locale('ko', 'KR'),
          Locale('zh', 'CN'),
          Locale('vi', 'VN'),
          Locale('es', 'ES'),
          Locale('pt', 'PT'),
        ],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

      ),
    );
  }
}
