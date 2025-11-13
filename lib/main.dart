import 'package:catch_table/features/auth/presentation/screens/pin_login_screen.dart';
import 'package:catch_table/features/registration/presentation/screens/queue_registration.dart';
import 'package:catch_table/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Landscape 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ProviderScope로 앱을 감싸서 Riverpod 활성화
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catch Table',
      debugShowCheckedModeBanner: false,
      // 라우팅 설정
      initialRoute: '/',
      routes: {
        '/': (context) => const PinLoginScreen(),
        '/main': (context) => const QueueRegistrationScreen(),
      },
    );
  }
}
