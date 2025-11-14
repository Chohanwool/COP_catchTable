import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:catch_table/firebase_options.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_table/features/auth/presentation/providers/auth_providers.dart';
import 'package:catch_table/features/store/presentation/providers/store_providers.dart';
import 'package:catch_table/features/auth/presentation/screens/login_screen.dart';
import 'package:catch_table/features/registration/presentation/screens/queue_registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Landscape 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ProviderScope로 앱을 감싸서 Riverpod 활성화
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state와 Store 자동 로드를 watch
    final authState = ref.watch(authStateProvider);
    final storeState = ref.watch(autoLoadStoreProvider);

    return MaterialApp(
      title: 'Catch Table',
      debugShowCheckedModeBanner: false,
      // Auth state와 Store state에 따라 초기 화면 결정
      home: authState.when(
        data: (user) {
          if (user == null) {
            // 로그인되어 있지 않음
            return const LoginScreen();
          }

          // 로그인되어 있음 - 매장 정보 로드 확인
          return storeState.when(
            data: (store) {
              if (store != null) {
                // 매장 정보 로드 완료 - 메인 화면으로
                return const QueueRegistrationScreen();
              }
              // 매장 정보 없음 - 로그인 화면으로 (에러 상태)
              return const LoginScreen();
            },
            loading: () => const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF06F1A),
                ),
              ),
            ),
            error: (_, __) => const LoginScreen(),
          );
        },
        loading: () => const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF06F1A),
            ),
          ),
        ),
        error: (_, __) => const LoginScreen(),
      ),
      // Named routes 유지 (pushNamed 사용 위해)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const QueueRegistrationScreen(),
      },
    );
  }
}
