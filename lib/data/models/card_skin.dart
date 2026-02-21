import 'package:flutter/material.dart';

class CardSkin {
  final String id;
  final String name;
  final String description;
  final int price;
  
  // 꾸미기 화면 상단 미리보기에 보여줄 이미지/아이콘 (또는 Color)
  final IconData previewIcon;
  final Color primaryColor;
  final Color secondaryColor;
  
  // 실제 게임 화면 뒷면 테마 세팅
  final Color backBgColor;
  final Color backPatternColor;
  final String? cardBackImagePath; // 추후 추가될 커스텀 AI 일러스트 에셋 경로
  
  // 실제 게임 화면 앞면 테마 세팅
  final Color frontBgColor;
  final String? cardFrontImagePath; // 추후 추가될 앞면 커스텀 이미지 (은은한 배경용)
  final Color frontBorderColor;
  final Color tooltipBgColor;

  const CardSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.previewIcon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backBgColor,
    required this.backPatternColor,
    this.cardBackImagePath,
    required this.frontBgColor,
    this.cardFrontImagePath,
    required this.frontBorderColor,
    required this.tooltipBgColor,
  });
}

// 20대 여성 타겟팅 감성 & 힙한 스킨 데이터베이스
final List<CardSkin> allCardSkins = [
  const CardSkin(
    id: 'basic',
    name: '오리지널 펄 (Basic)',
    description: '베이직하고 깔끔한 진주빛 텍스쳐의 기본 스킨입니다.',
    price: 0,
    previewIcon: Icons.layers_rounded,
    primaryColor: Color(0xFFE2E8F0),
    secondaryColor: Color(0xFF94A3B8),
    backBgColor: Color(0xFF1E293B), // 슬레이트 다크
    backPatternColor: Color(0xFF334155),
    frontBgColor: Colors.white,
    cardFrontImagePath: null,
    frontBorderColor: Color(0xFFE2E8F0),
    tooltipBgColor: Color(0xFFF1F5F9),
  ),
  const CardSkin(
    id: 'magical_girl',
    name: '마법소녀 드림',
    description: '정의의 이름으로 카드를 깝니다! 핑크빛 리본과 별빛이 수놓아진 영롱한 스킨.',
    price: 10000,
    previewIcon: Icons.auto_awesome,
    primaryColor: Color(0xFFF472B6), // 핑크
    secondaryColor: Color(0xFFFBCFE8),
    backBgColor: Color(0xFFBE185D), // 진한 핑크
    backPatternColor: Color(0xFFF9A8D4),
    cardBackImagePath: 'assets/images/skins/back_magical_girl.png',
    frontBgColor: Color(0xFFFDF2F8),
    cardFrontImagePath: 'assets/images/skins/front_magical_girl.webp',
    frontBorderColor: Color(0xFFF472B6),
    tooltipBgColor: Color(0xFFFCE7F3),
  ),
  const CardSkin(
    id: 'space_cat',
    name: '우주 냥냥이',
    description: '어두운 밤하늘과 별을 유영하는 신비로운 우주 고양이 테마.',
    price: 10000,
    previewIcon: Icons.pets,
    primaryColor: Color(0xFF8B5CF6), // 보라
    secondaryColor: Color(0xFFC4B5FD),
    backBgColor: Color(0xFF2E1065), // 딥 퍼플
    backPatternColor: Color(0xFF6D28D9),
    cardBackImagePath: 'assets/images/skins/back_space_cat.png',
    frontBgColor: Color(0xFFFAF5FF),
    cardFrontImagePath: 'assets/images/skins/front_space_cat.webp',
    frontBorderColor: Color(0xFFA78BFA),
    tooltipBgColor: Color(0xFFF3E8FF),
  ),
  const CardSkin(
    id: 'pastel_macaron',
    name: '파스텔 마카롱',
    description: '달콤한 마카롱처럼 부드러운 민트, 피치, 바닐라가 섞인 스킨.',
    price: 10000,
    previewIcon: Icons.cake,
    primaryColor: Color(0xFF5EEAD4), // 민트/시안
    secondaryColor: Color(0xFFFDBA74), // 피치/오렌지
    backBgColor: Color(0xFF14B8A6), // 틸
    backPatternColor: Color(0xFF99F6E4),
    cardBackImagePath: 'assets/images/skins/back_pastel_macaron.png',
    frontBgColor: Color(0xFFF0FDF4),
    cardFrontImagePath: 'assets/images/skins/front_pastel_macaron.webp',
    frontBorderColor: Color(0xFF6EE7B7),
    tooltipBgColor: Color(0xFFCCFBF1),
  ),
  const CardSkin(
    id: 'gothic_lolita',
    name: '고딕 로맨스',
    description: '다크한 분위기에 붉은 장미와 레이스 패턴이 가미된 치명적인 스킨.',
    price: 10000,
    previewIcon: Icons.favorite, // (추후 장미 등으로 커스텀 가능)
    primaryColor: Color(0xFF9F1239), // 로즈 레드
    secondaryColor: Color(0xFF171717), // 매우 다크 
    backBgColor: Color(0xFF000000), // 완전 블랙
    backPatternColor: Color(0xFF881337), // 딥 다크 로즈
    cardBackImagePath: 'assets/images/skins/back_gothic_lolita.png',
    frontBgColor: Color(0xFF1C1917), // 스톤 그레이
    cardFrontImagePath: 'assets/images/skins/front_gothic_lolita.webp',
    frontBorderColor: Color(0xFFBE123C),
    tooltipBgColor: Color(0xFF292524),
  ),
  const CardSkin(
    id: 'nano_banana',
    name: '나노 바나나',
    description: '팝아트 감성의 키치하고 트렌디한 옐로우 & 네온 테마.',
    price: 10000,
    previewIcon: Icons.bolt, // ⚡ 힙한 느낌
    primaryColor: Color(0xFFEAB308), // 비비드 옐로우
    secondaryColor: Color(0xFFFDE047),
    backBgColor: Color(0xFFFEF08A), // 파스텔 옐로우
    backPatternColor: Color(0xFFCA8A04), // 다크 옐로우 포인트
    cardBackImagePath: 'assets/images/skins/back_nano_banana.png',
    frontBgColor: Color(0xFFFEFCE8), // 연한 바나나 우유 빛
    cardFrontImagePath: 'assets/images/skins/front_nano_banana.png',
    frontBorderColor: Color(0xFFFACC15),
    tooltipBgColor: Color(0xFFFFFBEB),
  ),
];
