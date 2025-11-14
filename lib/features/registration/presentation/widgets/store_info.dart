import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_table/features/store/presentation/providers/store_providers.dart';
import 'package:catch_table/features/auth/presentation/providers/auth_providers.dart';

class StoreInfo extends ConsumerStatefulWidget {
  const StoreInfo({super.key, required this.waitingNum});

  final String waitingNum;

  @override
  ConsumerState<StoreInfo> createState() => _StoreInfoState();
}

class _StoreInfoState extends ConsumerState<StoreInfo> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  /// 가게 이름 탭 처리 (5번 탭으로 로그아웃)
  void _handleStoreTap() {
    final now = DateTime.now();

    // 마지막 탭으로부터 2초 이상 지났으면 카운트 리셋
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTapTime = now;

    // 5번 탭 시 PIN 입력 모달 표시
    if (_tapCount >= 5) {
      _tapCount = 0; // 카운트 리셋
      _showPinDialog();
    }
  }

  /// PIN 입력 다이얼로그 표시
  void _showPinDialog() {
    final store = ref.read(selectedStoreProvider);
    if (store == null) return;

    final pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          'Admin Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter PIN to logout',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  _verifyPinAndLogout(value, store.pin);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _verifyPinAndLogout(pinController.text, store.pin);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// PIN 검증 후 로그아웃
  Future<void> _verifyPinAndLogout(String enteredPin, String correctPin) async {
    if (enteredPin.trim() == correctPin) {
      // PIN이 맞으면 로그아웃
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();

      // 로그인 화면으로 이동
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } else {
      // PIN이 틀리면 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect PIN. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tapCount = 0;
    _lastTapTime = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 가게 정보 가져오기
    final store = ref.watch(selectedStoreProvider);
    return Expanded(
      flex: 1, // 메인에서 좌우 각각 1씩 차지하기 위해 필수!
      child: Container(
        // 배경색
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 28.0),
          child: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 앱 로고 or 타이틀
                  Text(
                    'CATCHTABLE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // 안내 문구
                  Text(
                    'Enter your phone number to receive\nreal-time waiting updates.',
                    style: TextStyle(fontSize: 24, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              Divider(
                color: Colors.grey.withValues(alpha: 0.5),
                thickness: 1,
                height: 50,
              ),

              // 가게 상호 (5번 탭으로 로그아웃)
              GestureDetector(
                onTap: _handleStoreTap,
                child: Text(
                  store?.name ?? 'Store Name',
                  style: const TextStyle(
                    fontSize: 52,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Divider(
                color: Colors.grey.withValues(alpha: 0.5),
                thickness: 0.55,
                height: 50,
              ),

              // 대기 정보
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Currently\nWaiting',
                      style: TextStyle(fontSize: 24, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 42.0),
                    Text(
                      widget.waitingNum,
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 18.0),
                    Text(
                      'Groups',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
