
import 'package:flutter/material.dart';

/// Helper 클래스
/// - 화면 크기에 따라 UI 요소(폰트, 여백, 아이콘 등)의 크기를 동적으로 계산해주는 클래스
/// - (before) 헬퍼가 없었다면 모든 위젯 파일마다 MediaQuery.of(context).size.height / 1366 * 40  와 같은 계산 코드를 직접 사용해야함
/// - (after) 헬퍼를 통해 context.fsp(40) 과 같이 직관적이고 짧은 코드로 반응형 크기를 얻을 수 있음
///
/// - Extension 메서드 사용
///   - Dart에서 제공하는 기능으로, 기존 클래스에 새로운 기능을 확장하는 것처럼 추가

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
