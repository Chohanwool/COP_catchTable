import 'package:flutter/material.dart';

class RegistrationStepConfirm extends StatelessWidget {
  const RegistrationStepConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // 비율 기반 높이 설정
        final infoAreaRatio = 0.85;
        final buttonAreaRatio = 0.15;

        return Column(
          children: [
            SizedBox(
              height: infoAreaRatio * height,
              child: _buildConfrimArea(screenHeight, screenWidth),
            ),
            SizedBox(
              height: buttonAreaRatio * height,
              child: _buildButtonArea(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfrimArea(double screenHeight, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 32),
      child: Column(
        children: [
          Text(
            'Check You\'re Registration',
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re currently number 3 in line.',
            style: TextStyle(color: Colors.black, fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            'We\'ll text you when your table is ready',
            style: TextStyle(color: Colors.black, fontSize: 28),
          ),
          const SizedBox(height: 60),
          // 연락처 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phone',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '0909-123-4567',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 인원 수 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '2',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: const Color.fromARGB(255, 254, 181, 71),
                ),
                width: 150,
                height: 150,
                child: const Icon(Icons.message_rounded, size: 80),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'SMS notification',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'We\'ll send you a text message\nwhen your table is ready.',
                        style: TextStyle(
                          color: Color(0xFF459acc),
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Please respond within 5 minute',
                        style: TextStyle(
                          color: Color(0xFF459acc),
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: const Color.fromARGB(255, 254, 181, 71),
                ),
                width: 150,
                height: 150,
                child: const Icon(Icons.phone, size: 80),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Phone call',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'If you miss your confirmation. we\'ll try to reach you by phone.',
                        style: TextStyle(
                          color: Color(0xFF459acc),
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        VerticalDivider(
          color: Colors.grey.withOpacity(0.5),
          thickness: 1,
          width: 1,
        ),
        Expanded(
          child: Container(
            color: Colors.orange,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Confirm',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
