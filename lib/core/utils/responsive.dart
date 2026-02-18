import 'package:flutter/material.dart';
import 'dart:math';

/// 반응형 UI 유틸리티
/// 기기 화면 크기에 따라 UI 요소의 크기를 자동으로 조절합니다.
/// 기준 해상도: 375 x 812 (iPhone X / 11 Pro 등 일반적인 모바일 비율)
///
/// **핵심 원칙**: 거의 모든 크기를 너비(w) 기준으로 계산합니다.
/// - 화면 비율(Aspect Ratio)이 달라도 UI 비율이 유지됩니다.
/// - h()는 수직 간격에만 제한적으로 사용합니다.
extension Responsive on BuildContext {
  
  // 현재 화면 크기
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // 기준 해상도 (Design Standard)
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  // 스케일 팩터 (Scale Factor)
  double get scaleW => screenWidth / designWidth;
  double get scaleH => screenHeight / designHeight;
  
  /// 텍스트 스케일링 - 너비 기준, 합리적 범위로 clamp
  double sp(double size) {
    final scale = scaleW.clamp(0.75, 1.4);
    return size * scale;
  }

  /// 너비 기준 크기 - 마진, 패딩, 아이콘, 위젯 크기, 수직 간격 모두 이것 사용
  /// 화면 비율과 무관하게 비율 유지
  double w(double size) {
    return size * scaleW;
  }

  /// 높이 기준 크기 - SafeArea, 특수 수직 배치에만 사용
  /// 주의: 화면 비율이 다르면 결과가 크게 달라질 수 있음
  double h(double size) {
    return size * scaleH;
  }
  
  /// 반응형 반지름 (Radius) - 너비 기준
  double r(double size) {
    return size * scaleW;
  }

  /// 화면 너비의 % (Percentage of Width)
  double percentW(double percent) {
    return screenWidth * (percent / 100);
  }

  /// 화면 높이의 % (Percentage of Height)
  double percentH(double percent) {
    return screenHeight * (percent / 100);
  }
  
  /// 안전 영역 (Safe Area)
  double get topSafePadding => MediaQuery.of(this).padding.top;
  double get bottomSafePadding => MediaQuery.of(this).padding.bottom;
}
