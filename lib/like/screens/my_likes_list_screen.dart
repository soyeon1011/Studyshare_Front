import 'package:flutter/material.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/note/screens/my_note_screen.dart';

import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LikesScreen(),
    );
  }
}
 */

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikesScreen> {
  // 1. 선택 상태를 관리할 리스트 (true, false)
  // [노트 선택 여부, 게시글 선택 여부]
  final List<bool> _isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
              onLogoTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
              onSearchTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
              onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile())),
              onWriteNoteTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
              child: Column(
                children: [
                  // --- 상단 아이콘 및 제목 ---
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0x33FF0000), // 옅은 빨간색
                    child: Icon(Icons.favorite, color: Colors.red, size: 45),
                  ),
                  const SizedBox(height: 20),
                  const Text('좋아요 글', style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 15),
                  const Text('좋아요를 누른 노트와 콘텐츠를 확인하세요', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
                  const SizedBox(height: 50),

                  // --- 2. ToggleButtons 위젯으로 탭 구현 ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 전체 배경색
                      borderRadius: BorderRadius.circular(25.0), // 둥근 모서리
                    ),
                    child: ToggleButtons(
                      isSelected: _isSelected, // 각 버튼의 선택 상태
                      onPressed: (int index) { // 버튼을 눌렀을 때
                        setState(() {
                          // 모든 버튼을 일단 선택 해제
                          for (int i = 0; i < _isSelected.length; i++) {
                            _isSelected[i] = false;
                          }
                          // 누른 버튼만 선택 상태로 변경
                          _isSelected[index] = true;
                        });
                      },
                      // 둥근 모서리 및 테두리 스타일
                      borderRadius: BorderRadius.circular(25.0),
                      borderColor: Colors.transparent,
                      selectedBorderColor: Colors.transparent,
                      fillColor: Colors.white, // 선택된 버튼의 배경색
                      splashColor: Colors.grey.withOpacity(0.12),
                      hoverColor: Colors.grey.withOpacity(0.04),

                      // 버튼 목록
                      children: <Widget>[
                        _buildTab('노트 (0)', Icons.description_outlined),
                        _buildTab('게시글 (0)', Icons.chat_bubble_outline),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // --- 3. 선택된 탭에 따라 다른 내용 표시 ---
                  if (_isSelected[0]) // 첫 번째 버튼(노트)이 선택되었다면
                    _buildEmptyState('노트')
                  else // 두 번째 버튼(게시글)이 선택되었다면
                    _buildEmptyState('게시글'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // '좋아요한 ...가 없습니다' 부분을 만드는 함수
  Widget _buildEmptyState(String type) {
    return Column(
      children: [
        Image.asset(
          'assets/images/my_likes_list_gray.png',
          width: 100,  // Icon의 size를 width로
          height: 100, // Icon의 size를 height로
        ),
        const SizedBox(height: 20),
        Text(
          '아직 좋아요한 $type가 없습니다.',
          style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20),
        ),
        const SizedBox(height: 10),
        Text(
          '마음에 드는 $type에 좋아요를 눌러보세요',
          style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 16),
        ),
      ],
    );
  }

  // ToggleButtons의 각 버튼 UI를 만드는 함수 (수정)
  Widget _buildTab(String text, IconData icon) {
    // 1. SizedBox로 감싸서 너비를 지정합니다.
    return SizedBox(
      width: 600, // 버튼 하나의 너비를 원하는 만큼 조절하세요.
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}