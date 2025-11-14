import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_table/core/consts/constants.dart';
import 'package:catch_table/core/utils/responsive_helper.dart';
import 'package:catch_table/core/utils/result.dart';

import 'package:catch_table/features/auth/presentation/providers/auth_providers.dart';

import 'package:catch_table/features/store/presentation/providers/store_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 로그인 처리
  Future<void> _handleLogin() async {
    // 키보드 숨기기
    FocusScope.of(context).unfocus();

    // 폼 유효성 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Firebase Auth 로그인
      final authRepository = ref.read(authRepositoryProvider);
      final authResult = await authRepository.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!authResult.isSuccess) {
        if (mounted) {
          _showErrorDialog(
            authResult.failureOrNull?.message ?? '로그인에 실패했습니다.',
          );
        }
        return;
      }

      final user = authResult.valueOrNull!;

      // 2. Firestore에서 매장 정보 조회
      final storeRepository = ref.read(storeRepositoryProvider);
      final storeResult = await storeRepository.getStoreByUid(user.uid);

      if (!storeResult.isSuccess) {
        if (mounted) {
          _showErrorDialog(
            storeResult.failureOrNull?.message ??
                '매장 정보를 불러오는데 실패했습니다.',
          );
        }
        // 로그인은 성공했지만 매장 정보가 없으면 로그아웃
        await authRepository.signOut();
        return;
      }

      final store = storeResult.valueOrNull!;

      // 3. 매장 정보를 상태에 저장
      ref.read(selectedStoreProvider.notifier).state = store;

      // 4. QueueRegistrationScreen으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('로그인 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        title: const Text(
          'Login Failed',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.lightGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus to hide keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.sp(500),
              ),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: AppColors.darkGrey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.hsp(40),
                    horizontal: context.sp(32),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Logo/Title
                      Text(
                        'Catch Table',
                        style: TextStyle(
                          fontSize: context.fsp(48),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: context.hsp(12)),
                      Text(
                        'Sign in with store account',
                        style: TextStyle(
                          fontSize: context.fsp(16),
                          color: AppColors.grey,
                        ),
                      ),

                        SizedBox(height: context.hsp(40)),

                        // Email TextField
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: AppColors.grey),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: AppColors.lightGrey,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                          style: const TextStyle(color: Colors.white),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(height: context.hsp(20)),

                        // Password TextField
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: AppColors.grey),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.grey,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: AppColors.lightGrey,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                          style: const TextStyle(color: Colors.white),
                          autocorrect: false,
                        ),

                        SizedBox(height: context.hsp(32)),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: context.hsp(56),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2.0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: context.fsp(18),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: context.hsp(16)),

                        // Forgot Password Link
                        TextButton(
                          onPressed: _isLoading ? null : () {
                            // TODO: Implement forgot password
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: context.fsp(14),
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
