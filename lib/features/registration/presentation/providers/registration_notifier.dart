import 'package:catch_table/core/utils/result.dart';
import 'package:catch_table/features/registration/domain/entities/registration.dart';
import 'package:catch_table/features/registration/presentation/providers/registration_providers.dart';
import 'package:catch_table/features/registration/presentation/providers/registration_state.dart';
import 'package:catch_table/features/store/presentation/providers/store_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registration Notifier (Presentation Layer)
///
/// 등록 화면의 상태와 비즈니스 로직을 관리합니다.
class RegistrationNotifier extends ChangeNotifier {
  RegistrationNotifier(this._ref);

  final Ref _ref;
  RegistrationState _state = const RegistrationState();

  RegistrationState get state => _state;

  void _updateState(RegistrationState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 등록 목록을 실시간으로 구독합니다.
  void watchRegistrations() {
    final store = _ref.read(selectedStoreProvider);
    if (store == null) {
      _updateState(state.copyWith(
        error: '매장 정보가 없습니다.',
        isLoading: false,
      ));
      return;
    }

    // 오늘 날짜 계산
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final repository = _ref.read(registrationRepositoryProvider);
    final stream = repository.watchRegistrations(
      storeId: store.id,
      date: today,
    );

    stream.listen(
      (result) {
        if (result.isSuccess) {
          final registrations = result.valueOrNull ?? [];
          _updateState(state.copyWith(
            registrations: registrations,
            isLoading: false,
          ));
        } else {
          _updateState(state.copyWith(
            error: result.failureOrNull?.message ?? '등록 목록을 불러오는데 실패했습니다.',
            isLoading: false,
          ));
        }
      },
      onError: (error) {
        _updateState(state.copyWith(
          error: '등록 목록을 불러오는데 실패했습니다: $error',
          isLoading: false,
        ));
      },
    );
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

    _updateState(state.copyWith(
      currentRegistration: updatedRegistration,
      currentStep: nextStep,
    ));
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

    _updateState(state.copyWith(currentStep: previousStep));
  }

  /// 등록을 완료하고 목록에 추가합니다.
  Future<void> submitRegistration() async {
    final store = _ref.read(selectedStoreProvider);
    if (store == null) {
      _updateState(state.copyWith(
        error: '매장 정보가 없습니다.',
        isLoading: false,
      ));
      return;
    }

    _updateState(state.copyWith(isLoading: true, error: null));

    try {
      final repository = _ref.read(registrationRepositoryProvider);
      final result = await repository.addRegistration(
        storeId: store.id,
        registration: state.currentRegistration,
      );

      if (result.isSuccess) {
        // 상태를 초기화하고 첫 단계로 돌아감
        _updateState(state.copyWith(
          currentRegistration: const Registration(),
          currentStep: RegistrationStep.phone,
          isLoading: false,
        ));
      } else {
        _updateState(state.copyWith(
          error: result.failureOrNull?.message ?? '등록에 실패했습니다.',
          isLoading: false,
        ));
      }
    } catch (e) {
      _updateState(state.copyWith(
        error: '등록에 실패했습니다: $e',
        isLoading: false,
      ));
    }
  }

  /// 현재 작성 중인 등록 정보를 초기화합니다.
  void resetCurrentRegistration() {
    _updateState(state.copyWith(
      currentRegistration: const Registration(),
      currentStep: RegistrationStep.phone,
    ));
  }
}
