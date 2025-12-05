import 'package:flutter/material.dart';
import 'package:studyshare/bookmark/screens/my_bookmark_screen.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/login/Login_UI.dart';
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
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. AppHeader를 콜백 함수와 함께 호출합니다.
            AppHeader(
              onLogoTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              onSearchTap: () {
                // 이미 검색 페이지이므로 아무 동작 안 함
                print("Already on Search Screen");
              },
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ProfileScreen()));
              },
              onWriteNoteTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyNoteScreen()));
            },
              onLoginTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              onWriteCommunityTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen()));
              },
              onBookmarkTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen()));
              },
            ),

            // 2. Positioned 대신 반응형 레이아웃으로 콘텐츠를 재구성합니다.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    const Text(
                      '검색어를 입력해주세요',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: TextField(
                              style: const TextStyle(fontSize: 20, color: Colors.black),
                              decoration: InputDecoration(
                                hintText: '검색어를 입력하세요...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFE4E4E4)),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFFFCB30), width: 2.0),
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 171,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCB30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('최근검색어', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              _buildRecentSearchTerm('공부 잘하는 법'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 50),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('인기 검색어', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              _buildRankedSearchTerm(rank: '1', term: '공부 잘하는 법'),
                              _buildRankedSearchTerm(rank: '2', term: '자격증 시험 일정'),
                              _buildRankedSearchTerm(rank: '3', term: '집중력 높이는 방법'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchTerm(String term) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(term, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 20, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildRankedSearchTerm({required String rank, required String term}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17.5,
            backgroundColor: const Color(0xFFFFCB30),
            child: Text(rank, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 15),
          Text(term, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 20, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}