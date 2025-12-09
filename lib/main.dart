import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/routes/app_router.dart';
import 'shared/providers/liturgy_theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 디버그 모드: 위젯 보더 표시
  debugPaintSizeEnabled = false;

  // 날짜 로케일 초기화
  await initializeDateFormatting('ja', null);

  // TODO: Firebase 초기화
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const ProviderScope(child: CredoApp()));
}

/// Credo 앱 루트 위젯
class CredoApp extends ConsumerWidget {
  const CredoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'Credo',
      debugShowCheckedModeBanner: false,

      // 테마
      theme: theme,

      // 라우팅
      routerConfig: router,

      // 로케일 설정
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
