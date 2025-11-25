import 'package:flutter/material.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/note/screens/my_note_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBookmarkScreen(),
    );
  }
}

class MyBookmarkScreen extends StatelessWidget {
  const MyBookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. AppHeader를 콜백 함수와 함께 올바르게 호출합니다.
            AppHeader(
              onLogoTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()));
              },
              onSearchTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
              },
              onProfileTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
              },
              onWriteNoteTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()),
                );
              },
            ),

            // 2. Positioned 대신 Column을 사용해 콘텐츠를 수직으로 배치합니다.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
              child: Column(
                children: [
                  // 아이콘
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const ShapeDecoration(
                      color:  Color(0xFFF3E3FF),
                      shape: OvalBorder(),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/my_bookmark_purple.png',
                        width: 48,
                        height: 43,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // '북마크'
                  const Text(
                    '북마크',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // '북마크를 한...'
                  const Text(
                    '북마크를 한 N개의 콘텐츠를 확인해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 100),

                  // 회색 노트 아이콘
                  Image.asset(
                    'assets/images/my_bookmark_gray.png',
                    width: 75,
                    height: 68,
                  ),
                  const SizedBox(height: 20),

                  // '아직 북마크한 게시글이 없습니다'
                  const Text(
                    '아직 북마크한 게시글이 없습니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // '마음에 드는 노트나 게시글을 북마크 해보세요'
                  const Text(
                    '마음에 드는 노트나 게시글을 북마크 해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}