import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/bookmark/screens/my_bookmark_screen.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/like/screens/my_likes_list_screen.dart';
import 'package:studyshare/note/screens/my_note_screen.dart';
import 'package:studyshare/community/screens/my_write_community_screen.dart';
import 'package:studyshare/profile/services/profile_logic.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/note/screens/my_write_note_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 프로필 데이터 갱신
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileLogic>().fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Consumer를 사용하여 로직 상태 구독
    return Consumer<ProfileLogic>(
      builder: (context, logic, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 1. AppHeader
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()));
                  },
                  onLoginTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  onWriteCommunityTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen()));
                  },
                  onBookmarkTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen()));
                  },
                ),

                // 2. 프로필 내용
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFFE0E0E0),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '김학생',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.black),
                        ),
                        const SizedBox(height: 30),

                        // 💡 [수정] 로직의 실제 데이터 바인딩 (노트, 글, 좋아요)
                        Row(
                          children: [
                            _buildStatItem(logic.noteCount.toString(), '작성한 노트'),
                            const SizedBox(width: 20),
                            _buildStatItem(logic.postCount.toString(), '작성한 글'),
                            const SizedBox(width: 20),
                            _buildStatItem(logic.likeCount.toString(), '좋아요 글'),
                          ],
                        ),

                        const SizedBox(height: 50),
                        _buildSectionTitle('내 활동'),

                        // 💡 [수정] 메뉴 아이템에도 실제 카운트 반영
                        _buildProfileMenuItem(
                          icon: Icons.description_outlined,
                          title: '내가 작성한 노트',
                          count: logic.noteCount.toString(),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyNoteScreen()));
                          },
                        ),
                        _buildProfileMenuItem(
                          icon: Icons.chat_bubble_outline,
                          title: '내가 작성한 게시글',
                          count: logic.postCount.toString(),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen()));
                          },
                        ),
                        _buildProfileMenuItem(
                          icon: Icons.favorite_border,
                          title: '좋아요 글',
                          count: logic.likeCount.toString(),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LikesScreen()));
                          },
                        ),
                        _buildProfileMenuItem(
                            icon: Icons.bookmark_border,
                            title: '북마크',
                            count: logic.bookmarkCount.toString(), // [수정] 실제 북마크 개수 반영
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen()));
                            }
                        ),

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
                            onPressed: () {
                              // 로그아웃 로직
                            },
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
      },
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