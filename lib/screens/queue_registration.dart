import 'package:catch_table/data/dummy_data.dart';
import 'package:catch_table/models/registration.dart';
import 'package:catch_table/widgets/registration_step_confirm.dart';
import 'package:catch_table/widgets/registration_step_group.dart';
import 'package:catch_table/widgets/registration_step_phone.dart';
import 'package:catch_table/widgets/store_info.dart';
import 'package:flutter/material.dart';

// 단계별 스텝을 확인하기 위한 ENUM
enum RegistrationStep { phone, group, confirm }

class QueueRegistrationScreen extends StatefulWidget {
  const QueueRegistrationScreen({super.key});

  @override
  State<QueueRegistrationScreen> createState() =>
      _QueueRegistrationScreenState();
}

class _QueueRegistrationScreenState extends State<QueueRegistrationScreen> {
  RegistrationStep _currentStep = RegistrationStep.phone;
  Registration _registration = const Registration();

  final registrationList = dummyRegistrations;

  // 대기 현황 보기
  void _navigateToWaitingList() {
    debugPrint('_navigateToWaitingList..');
  }

  // 다음 스텝으로 이동
  void _onNextStep(Registration newRegistration) {
    debugPrint(newRegistration.toString());

    // copyWith를 사용해서 기존 상태에 새로운 데이터를 병합
    final updateRegistration = _registration.copyWith(
      phoneNumber: newRegistration.phoneNumber,
      groupSize: newRegistration.groupSize,
    );

    setState(() {
      _registration = updateRegistration;

      // 현재 단계에 따라 다음 단계 결정
      if (_currentStep == RegistrationStep.phone) {
        _currentStep = RegistrationStep.group;
      } else if (_currentStep == RegistrationStep.group) {
        _currentStep = RegistrationStep.confirm;
      }
    });
  }

  // 이전 스텝으로 이동
  void _onBackStep() {
    setState(() {
      if (_currentStep == RegistrationStep.confirm) {
        _currentStep = RegistrationStep.group;
      } else if (_currentStep == RegistrationStep.group) {
        _currentStep = RegistrationStep.phone;
      }
    });
  }

  // 대기열 등록
  void _onSubmitRegistration(Registration newRegistration) {
    setState(() {
      registrationList.add(newRegistration);
      _currentStep = RegistrationStep.phone;
    });
  }

  Widget _buildRightPanel() {
    switch (_currentStep) {
      case RegistrationStep.phone:
        return RegistrationStepPhone(
          registrationInfo: _registration,
          onNext: (newRegistration) {
            _onNextStep(newRegistration);
          },
          onNavigateToWaitingList: _navigateToWaitingList,
        );
      case RegistrationStep.group:
        return RegistrationStepGroup(
          registrationInfo: _registration,
          onNext: (newRegistration) {
            _onNextStep(newRegistration);
          },
          onBack: _onBackStep,
        );
      case RegistrationStep.confirm:
        return RegistrationStepConfirm(
          registrationInfo: _registration,
          onConfirm: () {
            // confirm 단계에서는 새롭게 추가되는 데이터가 없기 때문에 최상위의 상태인 _registration을 사용
            _onSubmitRegistration(_registration);
          },
          onBack: _onBackStep,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            StoreInfo(waitingNum: registrationList.length.toString()),
            Expanded(child: _buildRightPanel()),
          ],
        ),
      ),
    );
  }
}
