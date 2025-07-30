import 'package:catch_table/widgets/registration_step_confirm.dart';
import 'package:catch_table/widgets/registration_step_group.dart';
import 'package:catch_table/widgets/registration_step_phone.dart';
import 'package:catch_table/widgets/store_info.dart';
import 'package:flutter/material.dart';

class QueueRegistrationScreen extends StatefulWidget {
  const QueueRegistrationScreen({super.key});

  @override
  State<QueueRegistrationScreen> createState() =>
      _QueueRegistrationScreenState();
}

class _QueueRegistrationScreenState extends State<QueueRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            StoreInfo(),
            // Expanded(child: RegistrationStepPhone(onNext: (value) {})),
            // Expanded(child: RegistrationStepGroup()),
            Expanded(child: RegistrationStepConfirm()),
          ],
        ),
      ),
    );
  }
}
