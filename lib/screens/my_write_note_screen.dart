import 'package:flutter/material.dart';
import 'package:study_note/screens/home_main_screen.dart';
import 'package:study_note/screens/profile_screen.dart';
import 'package:study_note/screens/search_screen.dart';
import 'package:study_note/widgets/header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWriteNoteScreen(),
    );
  }
}

class MyWriteNoteScreen extends StatelessWidget {
  const MyWriteNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                crossAxisAlignment: CrossAxisAlignment.center ,
                children: [
                  // 아이콘
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const ShapeDecoration(
                      color: Color(0x3310595F),
                      shape: OvalBorder(),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/my_write_note_green.png',
                        width: 48,
                        height: 43,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // '내가 작성한 노트'
                  const Text(
                    '내가 작성한 노트',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // '지금까지 작성한...'
                  const Text(
                    '지금까지 작성한 N개의 노트를 확인해보세요',
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
                    'assets/images/my_write_note_gray.png',
                    width: 75,
                    height: 68,
                  ),
                  const SizedBox(height: 20),

                  // '아직 작성한 노트가 없습니다'
                  const Text(
                    '아직 작성한 노트가 없습니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // '첫 번째 노트를 작성해보세요'
                  const Text(
                    '첫 번째 노트를 작성해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // '새 노트 작성' 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      print('새 노트 작성 버튼 클릭!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x3310595F),
                      foregroundColor: const Color(0xFF10595F),
                      elevation: 0,
                      minimumSize: const Size(170, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 24),
                    label: const Text(
                      '새 노트 작성',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}