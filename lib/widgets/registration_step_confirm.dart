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
              child: _buildConfrimArea(context, screenHeight, screenWidth),
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

  Widget _buildConfrimArea(
    BuildContext context,
    double screenHeight,
    double screenWidth,
  ) {
    // 기준이 되는 화면 높이 (예: iPad Pro 12.9인치)
    const double baseScreenHeight = 1366;
    final double scaleFactor = screenHeight / baseScreenHeight;

    // 반응형 폰트 크기
    final double titleFontSize = 40 * scaleFactor;
    final double subtitleFontSize = 28 * scaleFactor;
    final double bodyFontSize = 34 * scaleFactor;
    final double smallBodyFontSize = 30 * scaleFactor;
    final double captionFontSize = 25 * scaleFactor;

    // 반응형 여백
    final double verticalPadding = 50 * scaleFactor;
    final double horizontalPadding = 32;
    final double spacing1 = 12 * scaleFactor;
    final double spacing2 = 4 * scaleFactor;
    final double spacing3 = 60 * scaleFactor;
    final double spacing4 = 20 * scaleFactor;
    final double spacing5 = 80 * scaleFactor;

    // 반응형 컨테이너 및 아이콘 크기
    final double containerSize = 150 * scaleFactor;
    final double iconSize = 80 * scaleFactor;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Check You\'re Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: spacing1),
          Text(
            'You\'re currently number 3 in line.',
            style: TextStyle(color: Colors.black, fontSize: subtitleFontSize),
          ),
          SizedBox(height: spacing2),
          Text(
            'We\'ll text you when your table is ready',
            style: TextStyle(color: Colors.black, fontSize: subtitleFontSize),
          ),
          SizedBox(height: spacing3),
          // 연락처 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phone',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '0909-123-4567',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing4),
          // 인원 수 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '2',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing5),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: const Color.fromARGB(255, 254, 181, 71),
                ),
                width: containerSize,
                height: containerSize,
                child: Icon(Icons.message_rounded, size: iconSize),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMS notification',
                      style: TextStyle(
                        fontSize: smallBodyFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'We\'ll send you a text message\nwhen your table is ready.',
                      style: TextStyle(
                        color: Color(0xFF459acc),
                        fontSize: captionFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Please respond within 5 minute',
                      style: TextStyle(
                        color: Color(0xFF459acc),
                        fontSize: captionFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing1),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: const Color.fromARGB(255, 254, 181, 71),
                ),
                width: containerSize,
                height: containerSize,
                child: Icon(Icons.phone, size: iconSize),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone call',
                      style: TextStyle(
                        fontSize: smallBodyFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'If you miss your confirmation. we\'ll try to reach you by phone.',
                      style: TextStyle(
                        color: Color(0xFF459acc),
                        fontSize: captionFontSize,
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
    final screenHeight = MediaQuery.of(context).size.height;
    const double baseScreenHeight = 1366;
    final double scaleFactor = screenHeight / baseScreenHeight;
    final double buttonFontSize = 28 * scaleFactor;

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
                    fontSize: buttonFontSize,
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
                      fontSize: buttonFontSize,
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
