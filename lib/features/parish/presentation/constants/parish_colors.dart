import 'package:flutter/material.dart';

/// Parish 관련 색상 상수
class ParishColors {
  ParishColors._();

  // Neutral 색상
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);

  // Purple 색상
  static const purple100 = Color(0xFFF3E8FF);
  static const purple600 = Color(0xFF8200DB);

  // Blue 색상
  static const blue50 = Color(0xFFEFF6FF);
  static const blue600 = Color(0xFF1447E6);

  // 전례 시기별 색상
  // 대림절 - 보라색 (기다림, 준비)
  static const adventPrimary = Color(0xFF7B1FA2);
  static const adventLight = Color(0xFFE1BEE7);
  static const adventDark = Color(0xFF4A148C);
  static const adventBackground = Color(0xFFF3E5F5);

  // 사순절 - 보라색 (회개, 속죄)
  static const lentPrimary = Color(0xFF7B1FA2);
  static const lentLight = Color(0xFFE1BEE7);
  static const lentDark = Color(0xFF4A148C);
  static const lentBackground = Color(0xFFF3E5F5);

  // 연중 시기 - 초록색 (희망, 성장)
  static const ordinaryPrimary = Color(0xFF2E7D32);
  static const ordinaryLight = Color(0xFF60AD5E);
  static const ordinaryDark = Color(0xFF005005);
  static const ordinaryBackground = Color(0xFFF1F8E9);

  // 골드 포인트 색상 (흰색 시기용) - 채도 낮춘 골드
  static const goldPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const goldLight = Color(0xFFF4E4BC); // 밝은 골드
  static const goldDark = Color(0xFFB8860B); // 어두운 골드
  static const goldBackground = Color(0xFFFFFDE7);

  // 성탄절 - 흰색 배경 + 골드 포인트 (기쁨, 순결)
  static const christmasPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const christmasLight = Color(0xFFFFFFFF);
  static const christmasDark = Color(0xFFB8860B);
  static const christmasBackground = Color(0xFFFFFBFE);

  // 부활절 - 흰색 배경 + 골드 포인트 (승리, 영광)
  static const easterPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const easterLight = Color(0xFFFFFFFF);
  static const easterDark = Color(0xFFB8860B);
  static const easterBackground = Color(0xFFFFFBFE);

  // 성령 강림(오순절) - 붉은색 (성령, 순교)
  static const pentecostPrimary = Color(0xFFC62828);
  static const pentecostLight = Color(0xFFFF5F52);
  static const pentecostDark = Color(0xFF8E0000);
  static const pentecostBackground = Color(0xFFFFEBEE);

  // 순교자 축일 - 붉은색 (피흘림)
  static const martyrPrimary = Color(0xFFC62828);
  static const martyrLight = Color(0xFFFF5F52);
  static const martyrDark = Color(0xFF8E0000);
  static const martyrBackground = Color(0xFFFFEBEE);

  // 성모 마리아 축일/성인 축일 - 흰색 배경 + 골드 포인트 (기쁨, 성덕)
  static const saintPrimary = Color(0xFFD4AF37); // 클래식 골드 (채도 낮음)
  static const saintLight = Color(0xFFFFFFFF);
  static const saintDark = Color(0xFFB8860B);
  static const saintBackground = Color(0xFFFFFBFE);
}
