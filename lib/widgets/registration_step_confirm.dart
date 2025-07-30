import 'package:catch_table/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class RegistrationStepConfirm extends StatelessWidget {
  const RegistrationStepConfirm({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: _buildConfrimArea(context),
            ),
            SizedBox(
              height: buttonAreaRatio * height,
              child: _buildButtonArea(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfrimArea(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.hsp(50), horizontal: 32),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Check You\'re Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: context.fsp(40),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: context.hsp(12)),
          Text(
            'You\'re currently number 3 in line.',
            style: TextStyle(color: Colors.black, fontSize: context.fsp(28)),
          ),
          SizedBox(height: context.hsp(4)),
          Text(
            'We\'ll text you when your table is ready',
            style: TextStyle(color: Colors.black, fontSize: context.fsp(28)),
          ),
          SizedBox(height: context.hsp(60)),
          // 연락처 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phone',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.fsp(34),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '0909-123-4567',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.fsp(34),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.hsp(20)),
          // 인원 수 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.fsp(34),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '2',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.fsp(34),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.hsp(80)),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: const Color.fromARGB(255, 254, 181, 71),
                ),
                width: context.hsp(150),
                height: context.hsp(150),
                child: Icon(Icons.message_rounded, size: context.hsp(80)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMS notification',
                      style: TextStyle(
                        fontSize: context.fsp(30),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'We\'ll send you a text message\nwhen your table is ready.',
                      style: TextStyle(
                        color: Color(0xFF459acc),
                        fontSize: context.fsp(25),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Please respond within 5 minute',
                      style: TextStyle(
                        color: Color(0xFF459acc),
                        fontSize: context.fsp(25),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.hsp(12)),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: const Color.fromARGB(255, 254, 181, 71),
                ),
                width: context.hsp(150),
                height: context.hsp(150),
                child: Icon(Icons.phone, size: context.hsp(80)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone call',
                      style: TextStyle(
                        fontSize: context.fsp(30),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'If you miss your confirmation.\nwe\'ll try to reach you by phone.',
                      style: TextStyle(
                        color: Color(0xFF459acc),
                        fontSize: context.fsp(25),
                        fontWeight: FontWeight.w500,
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

  Widget _buildButtonArea(BuildContext context) {
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
                  style: TextStyle(
                    fontSize: context.fsp(28),
                    fontWeight: FontWeight.w700,
                  ),
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
                    style: TextStyle(
                      fontSize: context.fsp(28),
                      fontWeight: FontWeight.w700,
                    ),
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
