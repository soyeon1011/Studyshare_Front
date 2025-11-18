import 'package:flutter/material.dart';
import 'package:study_note/screens/home_main_screen.dart';
import 'package:study_note/screens/my_likes_list_screen.dart';
import 'package:study_note/screens/my_write_note_screen.dart';
import 'package:study_note/screens/my_write_post_screen.dart';
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
      home: Profile(),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

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
                print("Already on Profile Screen");
              },
              onWriteNoteTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()),
                );
              },
            ),

            // 2. Positioned 대신 Column/Row 기반의 반응형 레이아웃으로 변경합니다.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFFE0E0E0),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '김학생',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.black),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        _buildStatItem('20', '작성한 노트'),
                        const SizedBox(width: 20),
                        _buildStatItem('5', '게시글'),
                        const SizedBox(width: 20),
                        _buildStatItem('20', '작성한 글'),
                      ],
                    ),
                    const SizedBox(height: 50),
                    _buildSectionTitle('내 활동'),
                    _buildProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: '내가 작성한 노트',
                      count: '20',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()));
                      },
                    ),
                    _buildProfileMenuItem(
                      icon: Icons.chat_bubble_outline,
                      title: '내가 작성한 게시글',
                      count: '5',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWritePostScreen()));
                      },
                    ),
                    _buildProfileMenuItem(
                      icon: Icons.favorite_border,
                      title: '좋아요 글',
                      count: '5',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LikesScreen()));
                      },
                    ),


                    //_buildProfileMenuItem(icon: Icons.favorite_border, title: '좋아요 글', count: '5'),
                    _buildProfileMenuItem(icon: Icons.bookmark_border, title: '북마크', count: '5'),
                    const SizedBox(height: 50),
                    _buildSectionTitle('설정'),
                    _buildProfileMenuItem(icon: Icons.edit_outlined, title: '프로필 편집'),
                    _buildProfileMenuItem(icon: Icons.notifications_outlined, title: '알림 설정'),
                    _buildProfileMenuItem(icon: Icons.privacy_tip_outlined, title: '개인정보 처리방침'),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF7B7B)),
                          foregroundColor: const Color(0xFFFF7B7B),
                        ),
                        child: const Text('로그아웃'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  Widget _buildProfileMenuItem({required IconData icon, required String title, String? count, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black))),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(count, style: const TextStyle(fontSize: 12, color: Colors.black)),
              ),
            if (onTap != null) const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}