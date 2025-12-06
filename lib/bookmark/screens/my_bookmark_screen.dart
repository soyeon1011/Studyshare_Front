// lib/bookmark/screens/my_bookmark_screen.dart

import 'package:flutter/material.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/community/screens/my_write_community_screen.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/note/screens/my_note_screen.dart';

import 'package:studyshare/note/services/note_service.dart';
import 'package:studyshare/note/models/note_model.dart';
import 'package:studyshare/community/services/community_service.dart';
import 'package:studyshare/community/models/community_model.dart';

import 'package:studyshare/note/screens/note_detail_screen.dart';
import 'package:studyshare/community/screens/community_detail_screen.dart';

class MyBookmarkScreen extends StatefulWidget {
  const MyBookmarkScreen({super.key});

  @override
  State<MyBookmarkScreen> createState() => _MyBookmarkScreenState();
}

class _MyBookmarkScreenState extends State<MyBookmarkScreen> {
  final NoteService _noteService = NoteService();
  final CommunityService _communityService = CommunityService();

  List<dynamic> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllBookmarks();
  }

  Future<void> _loadAllBookmarks() async {
    final notes = await _noteService.fetchBookmarkedNotes(1);
    final communities = await _communityService.fetchBookmarkedCommunities(1);

    if (mounted) {
      setState(() {
        _allItems = [...notes, ...communities];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() { _isLoading = true; });
    await _loadAllBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppHeader(
              onLogoTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
              onSearchTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
              onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
              onWriteNoteTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyNoteScreen())),
              onLoginTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              onWriteCommunityTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen())),
              onBookmarkTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen())),
            ),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8F00FF)))
                        : _allItems.isEmpty
                        ? _buildEmptyState()
                        : _buildDataList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          width: 120, height: 120, // 90 -> 120
          decoration: const ShapeDecoration(color: Color(0xFFF3E3FF), shape: OvalBorder()),
          child: Center(child: Image.asset('assets/images/my_bookmark_purple.png', width: 64, height: 58)), // 48,43 -> 64,58
        ),
        const SizedBox(height: 30),
        const Text('북마크', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400)), // 36 -> 40
        const SizedBox(height: 15),
        const Text('북마크한 콘텐츠가 없습니다', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 24)), // 20 -> 24
        const SizedBox(height: 100),
        Image.asset('assets/images/my_bookmark_gray.png', width: 100, height: 90), // 75,68 -> 100,90
        const SizedBox(height: 20),
        const Text('아직 북마크한 게시글이 없습니다', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 24)), // 20 -> 24
        const SizedBox(height: 25),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3E3FF), foregroundColor: const Color(0xFF8F00FF), elevation: 0,
            minimumSize: const Size(220, 60), // 200,45 -> 220,60
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.home, size: 28), // 24 -> 28
          label: const Text('콘텐츠 구경하러 가기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)), // 18 -> 24
        ),
      ],
    );
  }

  Widget _buildDataList() {
    return Column(
      children: [
        Container(
          width: 100, height: 100, // 90 -> 100
          decoration: const ShapeDecoration(color: Color(0xFFF3E3FF), shape: OvalBorder()),
          child: Center(child: Image.asset('assets/images/my_bookmark_purple.png', width: 55, height: 50)), // 48,43 -> 55,50
        ),
        const SizedBox(height: 30),
        const Text('북마크', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400)), // 36 -> 40
        const SizedBox(height: 15),
        Text('북마크한 ${_allItems.length}개의 콘텐츠를 확인해보세요', style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 24)), // 20 -> 24
        const SizedBox(height: 60), // 50 -> 60

        ..._allItems.map((item) {
          String title = '';
          String category = '';
          String author = '';
          String date = '';
          String preview = '';
          int likes = 0;
          int comments = 0;

          if (item is NoteModel) {
            title = item.title;
            category = "노트";
            author = "User ${item.userId}";
            date = item.createDate; // 필요시 포맷팅 로직 추가
            preview = item.noteContent.replaceAll(RegExp(r'<[^>]*>'), '');
            likes = item.likesCount;
            comments = item.commentsCount;
          } else if (item is CommunityModel) {
            title = item.title;
            category = item.category;
            author = "User ${item.userId}";
            date = item.createDate; // 필요시 포맷팅 로직 추가
            preview = item.content.replaceAll(RegExp(r'<[^>]*>'), '');
            likes = item.likesCount;
            comments = item.commentCount;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 40.0), // 30 -> 40
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000), // 💡 [핵심] 너비 700 -> 1000

              child: GestureDetector(
                onTap: () {
                  if (item is NoteModel) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetailScreen(note: item)));
                  } else if (item is CommunityModel) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailScreen(post: item)));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(35), // 💡 [핵심] 패딩 20 -> 35
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFFCFCFCF)),
                      borderRadius: BorderRadius.circular(15), // 10 -> 15
                    ),
                    shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 12, offset: Offset(0, 6))], // 그림자 강화
                  ),
                  child: PostCardContent(
                    title: title.isNotEmpty ? title : "(제목 없음)",
                    category: category,
                    author: author,
                    date: date,
                    preview: preview.length > 100 ? "${preview.substring(0, 100)}..." : preview,
                    likes: likes,
                    comments: comments,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class PostCardContent extends StatelessWidget {
  final String title;
  final String category;
  final String author;
  final String date;
  final String preview;
  final int likes;
  final int comments;

  const PostCardContent({
    super.key,
    required this.title,
    required this.category,
    required this.author,
    required this.date,
    required this.preview,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(radius: 24, backgroundColor: Colors.transparent, child: Icon(Icons.person, size: 48, color: Colors.grey)), // 18/40 -> 24/48
          ],
        ),
        const SizedBox(height: 16), // 12 -> 16
        // 제목 크기 확대 (26 -> 32)
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12), // 8 -> 12
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 8/4 -> 12/6
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6), // 4 -> 6
                border: Border.all(color: const Color(0xFF8F00FF), width: 1.2), // 1.0 -> 1.2
              ),
              child: Text(category, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), // 18 -> 20
            ),
            const SizedBox(width: 12), // 8 -> 12
            Text('$author · $date', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 20, fontWeight: FontWeight.w700)), // 18 -> 20
          ],
        ),
        const SizedBox(height: 20), // 15 -> 20
        // 본문 미리보기 확대 (22 -> 24) 및 줄간격 추가
        Text(preview, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 55), // 47 -> 55
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 36), // 30 -> 36
                const SizedBox(width: 8), // 5 -> 8
                Text('$likes', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 22, fontWeight: FontWeight.w700)), // 18 -> 22
                const SizedBox(width: 20), // 15 -> 20
                const Icon(Icons.comment_outlined, color: Colors.black54, size: 32), // 25 -> 32
                const SizedBox(width: 8), // 5 -> 8
                Text('$comments', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 22, fontWeight: FontWeight.w700)), // 18 -> 22
              ],
            ),
            const Icon(Icons.bookmark, size: 36, color: Color(0xFF8F00FF)), // 30 -> 36
          ],
        ),
      ],
    );
  }
}