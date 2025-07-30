
import 'package:flutter/material.dart';

extension ResponsiveHelper on BuildContext {
  // 기준이 되는 기기의 너비와 높이 (예: iPad Pro 12.9인치)
  static const double _baseWidth = 1024;
  static const double _baseHeight = 1366;

  double get _screenWidth => MediaQuery.of(this).size.width;
  double get _screenHeight => MediaQuery.of(this).size.height;

  // 화면 너비에 비례한 크기 (sp: Scaleable Pixel)
  double sp(double size) {
    return size * (_screenWidth / _baseWidth);
  }

  // 화면 높이에 비례한 크기 (hsp: Height-Scaleable Pixel)
  double hsp(double size) {
    return size * (_screenHeight / _baseHeight);
  }

  // 반응형 폰트 사이즈
  double fsp(double size) {
    // 화면 너비와 높이 중 더 작은 값을 기준으로 스케일링하여
    // 가로/세로 모드 전환 시 폰트 크기가 급격하게 변하는 것을 방지
    final double scale = MediaQuery.of(this).size.shortestSide / _baseWidth;
    return size * scale;
  }
}
