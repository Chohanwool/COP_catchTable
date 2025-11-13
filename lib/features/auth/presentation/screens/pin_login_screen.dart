import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_table/core/consts/constants.dart';
import 'package:catch_table/core/utils/responsive_helper.dart';
import 'package:catch_table/core/utils/result.dart';

import 'package:catch_table/features/store/presentation/providers/store_providers.dart';

/// PIN 입력 화면
///
/// 매장 선택을 위한 PIN 번호 입력 화면
class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final pin = _pinController.text;

    if (pin.length != 4) {
      setState(() {
        _errorMessage = 'The PIN number must be 4 digits.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getStoreByPin = ref.read(getStoreByPinProvider);
      final result = await getStoreByPin(pin);

      if (result.isSuccess) {
        final store = result.valueOrNull!;
        // 매장 정보 저장
        ref.read(selectedStoreProvider.notifier).state = store;

        // 메인 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } else {
        final failure = result.failureOrNull!;
        if (mounted) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
          _pinController.clear(); // 입력 필드 초기화
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'error: $e';
          _isLoading = false;
        });
        _pinController.clear(); // 입력 필드 초기화
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 화면 다른 곳 클릭 시 키보드 닫기
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: context.hsp(120)),
              _buildPinInputArea(),
              SizedBox(height: context.hsp(60)),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Catch Table',
          style: TextStyle(
            fontSize: context.fsp(64),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: context.hsp(16)),
        Text(
          'Please Enter store PIN nunber',
          style: TextStyle(fontSize: context.fsp(24), color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildPinInputArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN 입력 표시 (4개의 원) - 탭하면 키보드 나타남
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _pinFocusNode.requestFocus();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              final isActive = index < _pinController.text.length;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: context.sp(12)),
                width: context.sp(20),
                height: context.sp(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : AppColors.lightGrey,
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.grey,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        ),
        // 숨겨진 TextField (기기 키보드를 띄우기 위해)
        Opacity(
          opacity: 0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: _pinController,
              focusNode: _pinFocusNode,
              autofocus: false,
              showCursor: false,
              keyboardType: TextInputType.phone,
              maxLength: 4,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                });
                // 4자리 입력되면 키보드 먼저 닫고 로그인
                if (value.length == 4) {
                  _pinFocusNode.unfocus();
                  // 키보드가 완전히 닫힌 후 로그인 처리
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      _onLogin();
                    }
                  });
                }
              },
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: context.hsp(16)),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: context.fsp(18), color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: context.sp(200),
      child: ElevatedButton(
        onPressed: _isLoading || _pinController.text.length != 4
            ? null
            : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.lightGrey,
          padding: EdgeInsets.symmetric(
            vertical: context.hsp(16),
            horizontal: context.sp(32),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.sp(8)),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: context.sp(20),
                height: context.sp(20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Login',
                style: TextStyle(
                  fontSize: context.fsp(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
