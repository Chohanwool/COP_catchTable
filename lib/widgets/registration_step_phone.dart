import 'package:catch_table/models/registration.dart';
import 'package:catch_table/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

const kPhonePrefixPh = '09';

class RegistrationStepPhone extends StatefulWidget {
  const RegistrationStepPhone({
    super.key,
    required this.registrationInfo,
    required this.onNext,
    required this.onNavigateToWaitingList,
  });

  final Registration registrationInfo;
  final ValueChanged<Registration> onNext;
  final VoidCallback onNavigateToWaitingList;

  @override
  State<RegistrationStepPhone> createState() => _RegistrationPhoneState();
}

class _RegistrationPhoneState extends State<RegistrationStepPhone> {
  // 상태 변수
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때, 부모로부터 받은 전화번호 정보로 상태를 초기화합니다.
    if (widget.registrationInfo.phoneNumber != null) {
      // '09' 접두사를 제외하고, 포맷을 적용하여 화면에 표시합니다.
      final initialNumber = widget.registrationInfo.phoneNumber!.substring(2);
      _phoneNumber = _formatPhoneNumber(initialNumber);
    }
  }

  // 연락처 포맷터
  // 1,4 자리 후 '-' 추가
  String _formatPhoneNumber(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i == 1 || i == 4) && i != digits.length - 1) {
        buffer.write('-');
      }
    }
    return buffer.toString();
  }

  // 키패드 핸들러
  void _onKeyboardTap(String value) {
    setState(() {
      // 숫자만 저장하는 내부 상태
      String rawNumber = _phoneNumber.replaceAll('-', '');

      if (value == 'DEL') {
        if (rawNumber.isNotEmpty) {
          rawNumber = rawNumber.substring(0, rawNumber.length - 1);
        }
      } else if (value == 'RESET') {
        rawNumber = '';
      } else {
        if (rawNumber.length < 9) {
          // 09 제외한 숫자 9자리 제한
          rawNumber += value;
        }
      }

      _phoneNumber = _formatPhoneNumber(rawNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // 비율 기반 높이 설정
        final inputAreaRatio = 0.25;
        final keypadAreaRatio = 0.6;
        final buttonRatio = 0.15;

        return Column(
          children: [
            SizedBox(
              height: height * inputAreaRatio,
              child: _buildPhoneInputArea(),
            ),
            SizedBox(
              height: height * keypadAreaRatio,
              child: _buildKeypadArea(),
            ),
            SizedBox(height: height * buttonRatio, child: _buildButtonArea()),
          ],
        );
      },
    );
  }

  Widget _buildPhoneInputArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                kPhonePrefixPh,
                style: TextStyle(fontSize: context.fsp(46)),
                textAlign: TextAlign.end,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  _phoneNumber,
                  style: TextStyle(
                    fontSize: context.fsp(46),
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.hsp(24)),
        Text(
          'Enter your phone number',
          style: TextStyle(color: Colors.black54, fontSize: context.fsp(32)),
        ),
      ],
    );
  }

  Widget _buildKeypadArea() {
    final screenWidth = MediaQuery.of(context).size.width;

    double aspectRatio;
    if (screenWidth >= 1376) {
      aspectRatio = 1.56;
    } else if (screenWidth >= 1210) {
      aspectRatio = 1.72;
    } else {
      aspectRatio = 1.8;
    }

    return AspectRatio(
      aspectRatio: 3 / 2,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // 스크롤 막기
        itemCount: 12,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          if (index < 9) {
            return _buildKey('${index + 1}');
          } else if (index == 9) {
            return _buildKey('RESET');
          } else if (index == 10) {
            return _buildKey('0');
          } else {
            return _buildKey('DEL');
          }
        },
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
              onTap: widget.onNavigateToWaitingList,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'View Waiting List',
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
                onTap: () {
                  final rawPhoneNumber = (kPhonePrefixPh + _phoneNumber)
                      .replaceAll('-', '');

                  if (rawPhoneNumber.length < 11) return;

                  widget.onNext(
                    widget.registrationInfo.copyWith(
                      phoneNumber: rawPhoneNumber,
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Next',
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

  // 키패드 버튼 설정
  Widget _buildKey(String label) {
    return ElevatedButton(
      onPressed: () => _onKeyboardTap(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        textStyle: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.5, // border 테두리 설정
          ),
        ),
      ),
      child: label == 'DEL'
          ? const Icon(Icons.arrow_back, size: 50)
          : label == 'RESET'
          ? const Icon(Icons.refresh_sharp, size: 50)
          : Text(label),
    );
  }
}
