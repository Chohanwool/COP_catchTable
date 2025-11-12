import 'package:flutter/material.dart';

import 'package:catch_table/core/utils/responsive_helper.dart';

import 'package:catch_table/features/registration/domain/entities/registration.dart';

class RegistrationStepGroup extends StatefulWidget {
  const RegistrationStepGroup({
    super.key,
    required this.registrationInfo,
    required this.onNext,
    required this.onBack,
  });

  final Registration registrationInfo;
  final ValueChanged<Registration> onNext;
  final VoidCallback onBack;

  @override
  State<RegistrationStepGroup> createState() => _RegistrationStepGroupState();
}

class _RegistrationStepGroupState extends State<RegistrationStepGroup> {
  late final PageController _pageController;
  int _groupCount = 1; // 기본값 1로 시작
  final int _minCount = 1;
  final int _maxCount = 20;

  @override
  void initState() {
    super.initState();

    // 좌우 숫자 인식후 화면 빌드되도록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    // 이전에 선택한 값이 있으면 그 값으로, 없으면 기본 값 사용
    _groupCount = widget.registrationInfo.groupSize ?? _minCount;

    _pageController = PageController(
      // PageView는 0부터 시작, 인원수는 1부터 시작하므로 -1
      initialPage: _groupCount - 1,
      viewportFraction: 0.3, // 양옆 숫자 보이게
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 다음 숫자로 이동
  void _slideToNextNumber() {
    if (_groupCount < _maxCount) {
      _pageController.animateToPage(
        _groupCount, // +1 제거
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 이전 숫자로 이동
  void _slideToPrevNumber() {
    if (_groupCount > _minCount) {
      // >= 대신 > 사용
      _pageController.animateToPage(
        _groupCount - 2, // -1 대신 -2
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // 비율 기반 높이 설정
        final titleAreaRatio = 0.2;
        final groupSelectAreaRatio = 0.65;
        final buttonRatio = 0.15;

        return Column(
          children: [
            SizedBox(
              height: height * titleAreaRatio,
              child: Center(
                child: Text(
                  'Number of Guests',
                  style: TextStyle(
                    fontSize: context.fsp(40),
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * groupSelectAreaRatio,
              child: _buildGroupSelectorWithControls(),
            ),
            SizedBox(height: height * buttonRatio, child: _buildButtonArea()),
          ],
        );
      },
    );
  }

  // 숫자 슬라이더 위젯 : +,- 추가 버전
  Widget _buildGroupSelectorWithControls() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 왼쪽 버튼
          IconButton(
            icon: Icon(Icons.remove, size: context.hsp(80)),
            onPressed: _slideToPrevNumber,
          ),
          _buildGroupSelector(),

          // 오른쪽 버튼
          IconButton(
            icon: Icon(Icons.add, size: context.hsp(80)),
            onPressed: _slideToNextNumber,
          ),
        ],
      ),
    );
  }

  // 숫자 슬라이더 위젯 : 기본
  Widget _buildGroupSelector() {
    return SizedBox(
      height: context.hsp(400),
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // ← 더 자연스럽게 슬라이드
        itemCount: _maxCount,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          setState(() => _groupCount = index + 1);
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0;
              bool isInitialized = false;

              if (_pageController.hasClients &&
                  _pageController.position.haveDimensions) {
                value =
                    ((_pageController.page ?? _groupCount.toDouble()) - index)
                        .toDouble();
                value = value.clamp(-1, 1);
                isInitialized = true;
              }

              // 초기화되지 않은 경우 기본값 설정
              final scale = isInitialized ? (1 - (value.abs() * 0.5)) : 0.5;
              final opacity = isInitialized ? (1 - (value.abs() * 0.7)) : 0.3;
              final translateY = isInitialized ? value.abs() : 0.5;

              return Center(
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: Text(
                        '${_minCount + index}',
                        style: TextStyle(
                          fontSize: context.fsp(140),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
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
              onTap: widget.onBack,
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
                onTap: () {
                  widget.onNext(
                    widget.registrationInfo.copyWith(groupSize: _groupCount),
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
}
