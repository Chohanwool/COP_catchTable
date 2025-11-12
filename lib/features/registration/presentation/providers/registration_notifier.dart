import 'package:catch_table/features/registration/domain/entities/registration.dart';
import 'package:catch_table/features/registration/presentation/providers/registration_providers.dart';
import 'package:catch_table/features/registration/presentation/providers/registration_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_notifier.g.dart';

/// Registration Notifier (Presentation Layer)
///
/// 등록 화면의 상태와 비즈니스 로직을 관리합니다.
@riverpod
class RegistrationNotifier extends _$RegistrationNotifier {
  @override
  RegistrationState build() {
    // 초기 상태 설정 및 등록 목록 로드
    _loadRegistrations();
    return const RegistrationState();
  }

  /// 등록 목록을 로드합니다.
  Future<void> _loadRegistrations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getRegistrations = ref.read(getRegistrationsProvider);
      final registrations = await getRegistrations();

      state = state.copyWith(
        registrations: registrations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '등록 목록을 불러오는데 실패했습니다: $e',
        isLoading: false,
      );
    }
  }

  /// 다음 단계로 이동합니다.
  void nextStep(Registration newRegistration) {
    // 현재 등록 정보와 새 정보를 병합
    final updatedRegistration = state.currentRegistration.copyWith(
      phoneNumber: newRegistration.phoneNumber,
      groupSize: newRegistration.groupSize,
    );

    // 다음 단계 결정
    RegistrationStep nextStep;
    if (state.currentStep == RegistrationStep.phone) {
      nextStep = RegistrationStep.group;
    } else if (state.currentStep == RegistrationStep.group) {
      nextStep = RegistrationStep.confirm;
    } else {
      nextStep = state.currentStep;
    }

    state = state.copyWith(
      currentRegistration: updatedRegistration,
      currentStep: nextStep,
    );
  }

  /// 이전 단계로 이동합니다.
  void previousStep() {
    RegistrationStep previousStep;
    if (state.currentStep == RegistrationStep.confirm) {
      previousStep = RegistrationStep.group;
    } else if (state.currentStep == RegistrationStep.group) {
      previousStep = RegistrationStep.phone;
    } else {
      previousStep = state.currentStep;
    }

    state = state.copyWith(currentStep: previousStep);
  }

  /// 등록을 완료하고 목록에 추가합니다.
  Future<void> submitRegistration() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final addRegistration = ref.read(addRegistrationProvider);
      await addRegistration(state.currentRegistration);

      // 등록 목록을 다시 로드
      await _loadRegistrations();

      // 상태를 초기화하고 첫 단계로 돌아감
      state = state.copyWith(
        currentRegistration: const Registration(),
        currentStep: RegistrationStep.phone,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: '등록에 실패했습니다: $e',
        isLoading: false,
      );
    }
  }

  /// 현재 작성 중인 등록 정보를 초기화합니다.
  void resetCurrentRegistration() {
    state = state.copyWith(
      currentRegistration: const Registration(),
      currentStep: RegistrationStep.phone,
    );
  }
}
