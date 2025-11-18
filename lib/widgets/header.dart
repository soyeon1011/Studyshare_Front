import 'package:flutter/material.dart';
import 'dart:math';

class AppHeader extends StatelessWidget {
  final VoidCallback onLogoTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onWriteNoteTap;

  const AppHeader({
    super.key,
    required this.onLogoTap,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onWriteNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Stack을 SizedBox로 감싸서 명확한 크기를 지정합니다.
    return SizedBox(
      width: 1440, // 헤더의 디자인 기준 너비
      height: 225, // 헤더의 가장 아래 요소(선)의 top 좌표 + 높이
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경선
          Positioned(
            top: 142,
            left: 0,
            right: 0,
            child: Container(height: 1, color: const Color(0xFFE4E4E4)),
          ),
          Positioned(
            top: 224,
            left: 0,
            right: 0,
            child: Container(height: 1, color: const Color(0xFFE4E4E4)),
          ),

          // 상단 영역 (로고, 검색, 로그인, 회원가입)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 142,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 164.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                children: [
                  GestureDetector(
                    onTap: onLogoTap,
                    child: Image.asset('assets/images/StudyShare_Logo.png', width: 280, height: 70),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0), // 아이콘들을 살짝 내리기 위한 여백
                    child: Row(
                      children: [
                        _buildTopButton(Icons.search, '검색', onTap: onSearchTap),
                        const SizedBox(width: 30),
                        _buildTopButton(Icons.login, '로그인'),
                        const SizedBox(width: 30),
                        _buildTopButton(Icons.person_add_alt_1, '회원가입'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 내비게이션 영역
          Positioned(
            top: 143,
            left: 0,
            right: 0,
            height: 81,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 192.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavButton('StudyShare', onTap: onLogoTap),
                  _buildNavButton('북마크'),
                  _buildNavButton('노트 작성', onTap: onWriteNoteTap),
                  _buildNavButton('커뮤니티'),
                  _buildNavButton('프로필', onTap: onProfileTap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 21),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700),
      ),
    );
  }
}