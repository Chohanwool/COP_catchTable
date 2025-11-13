import 'package:flutter/foundation.dart';

import 'package:catch_table/features/registration/domain/entities/registration.dart';

/// 등록 단계
enum RegistrationStep { phone, group, confirm }

/// 등록 화면의 전체 상태
class RegistrationState {
  const RegistrationState({
    this.currentStep = RegistrationStep.phone,
    this.currentRegistration = const Registration(),
    this.registrations = const [],
    this.isLoading = false,
    this.error,
  });

  /// 현재 단계
  final RegistrationStep currentStep;

  /// 현재 작성 중인 등록 정보
  final Registration currentRegistration;

  /// 전체 등록 목록
  final List<Registration> registrations;

  /// 로딩 상태
  final bool isLoading;

  /// 에러 메시지
  final String? error;

  RegistrationState copyWith({
    RegistrationStep? currentStep,
    Registration? currentRegistration,
    List<Registration>? registrations,
    bool? isLoading,
    String? error,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      currentRegistration: currentRegistration ?? this.currentRegistration,
      registrations: registrations ?? this.registrations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegistrationState &&
        other.currentStep == currentStep &&
        other.currentRegistration == currentRegistration &&
        listEquals(other.registrations, registrations) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentStep,
      currentRegistration,
      Object.hashAll(registrations),
      isLoading,
      error,
    );
  }
}
