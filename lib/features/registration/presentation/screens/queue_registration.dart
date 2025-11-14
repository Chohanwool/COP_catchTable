import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_table/features/registration/domain/entities/registration.dart';

import 'package:catch_table/features/registration/presentation/providers/registration_providers.dart';
import 'package:catch_table/features/registration/presentation/providers/registration_state.dart';
import 'package:catch_table/features/registration/presentation/screens/waiting_list.dart';
import 'package:catch_table/features/registration/presentation/widgets/registration_step_confirm.dart';
import 'package:catch_table/features/registration/presentation/widgets/registration_step_group.dart';
import 'package:catch_table/features/registration/presentation/widgets/registration_step_phone.dart';
import 'package:catch_table/features/registration/presentation/widgets/store_info.dart';

/// Queue Registration Screen (Presentation Layer)
///
/// Clean Architecture + Riverpod를 사용한 대기 등록 화면
/// - ConsumerStatefulWidget으로 Riverpod Provider 연동
/// - UseCase를 통한 비즈니스 로직 처리
/// - 상태 관리는 RegistrationNotifier가 담당
class QueueRegistrationScreen extends ConsumerStatefulWidget {
  const QueueRegistrationScreen({super.key});

  @override
  ConsumerState<QueueRegistrationScreen> createState() =>
      _QueueRegistrationScreenState();
}

class _QueueRegistrationScreenState
    extends ConsumerState<QueueRegistrationScreen> {
  @override
  void initState() {
    super.initState();
    // 첫 프레임 이후에 실시간 구독 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registrationNotifierProvider).watchRegistrations();
    });
  }

  // 대기 현황 보기
  void _navigateToWaitingList(
    BuildContext context,
    List<Registration> registrations,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => WaitingListScreen(registrationList: registrations),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(registrationNotifierProvider);
    final state = notifier.state;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 키보드가 나타나도 화면 리사이즈 방지
        body: Row(
          children: [
            StoreInfo(waitingNum: state.registrations.length.toString()),
            Expanded(child: _buildRightPanel(context, state)),
          ],
        ),
      ),
    );
  }

  /// 대기화면(우측) 빌드
  /// - 스텝에 맞는 위젯을 빌드하여 반환
  Widget _buildRightPanel(BuildContext context, RegistrationState state) {
    final notifier = ref.read(registrationNotifierProvider);

    switch (state.currentStep) {
      case RegistrationStep.phone:
        return RegistrationStepPhone(
          registrationInfo: state.currentRegistration,
          onNext: (newRegistration) {
            notifier.nextStep(newRegistration);
          },
          onNavigateToWaitingList: () =>
              _navigateToWaitingList(context, state.registrations),
        );
      case RegistrationStep.group:
        return RegistrationStepGroup(
          registrationInfo: state.currentRegistration,
          onNext: (newRegistration) {
            notifier.nextStep(newRegistration);
          },
          onBack: () {
            notifier.previousStep();
          },
        );
      case RegistrationStep.confirm:
        return RegistrationStepConfirm(
          registrationInfo: state.currentRegistration,
          onConfirm: () {
            notifier.submitRegistration();
          },
          onBack: () {
            notifier.previousStep();
          },
        );
    }
  }
}
