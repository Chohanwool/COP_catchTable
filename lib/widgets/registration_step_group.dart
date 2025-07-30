import 'package:flutter/material.dart';

class RegistrationStepGroup extends StatefulWidget {
  const RegistrationStepGroup({super.key});

  @override
  State<RegistrationStepGroup> createState() => _RegistrationStepGroupState();
}

class _RegistrationStepGroupState extends State<RegistrationStepGroup> {
  late final PageController _pageController;
  int _groupCount = 1;
  final int _minCount = 1;
  final int _maxCount = 20;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _groupCount,
      viewportFraction: 0.3, // 양옆 숫자 보이게
    );

    // 좌우 숫자 인식후 화면 빌드되도록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
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
        _groupCount + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 이전 숫자로 이동
  void _slideToPrevNumber() {
    if (_groupCount >= _minCount) {
      _pageController.animateToPage(
        _groupCount - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
            icon: Icon(Icons.remove, size: 80),
            onPressed: _slideToPrevNumber,
          ),
          _buildGroupSelector(),

          // 오른쪽 버튼
          IconButton(
            icon: Icon(Icons.add, size: 80),
            onPressed: _slideToNextNumber,
          ),
        ],
      ),
    );
  }

  // 숫자 슬라이더 위젯 : 기본
  Widget _buildGroupSelector() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // ← 더 자연스럽게 슬라이드
        itemCount: _maxCount,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          setState(() => _groupCount = index);
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0;
              if (_pageController.hasClients &&
                  _pageController.position.haveDimensions) {
                value =
                    ((_pageController.page ?? _groupCount.toDouble()) - index)
                        .toDouble();
                value = value.clamp(-1, 1);
              }

              final scale = 1 - (value.abs() * 0.5); // 가까울수록 큼
              final opacity = 1 - (value.abs() * 0.7); // 멀수록 흐림
              // 아래 수치 조절하면 좌,우 숫자는 조금 아래로 떨어짐
              // 예) value.abs() * 20;
              final translateY = value.abs(); // 멀수록 위아래로 밀림

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
                          fontSize: 140,
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
                  style: const TextStyle(fontSize: 40, color: Colors.black54),
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
                  'View Waiting List',
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
                    'Next',
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
