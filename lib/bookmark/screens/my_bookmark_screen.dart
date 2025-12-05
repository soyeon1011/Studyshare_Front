// lib/bookmark/screens/my_bookmark_screen.dart

import 'package:flutter/material.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/community/screens/my_write_community_screen.dart'; // 작성 페이지 연결용
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/note/screens/my_note_screen.dart';

// 💡 서비스 & 모델 임포트
import 'package:studyshare/note/services/note_service.dart';
import 'package:studyshare/note/models/note_model.dart';
import 'package:studyshare/community/services/community_service.dart';
import 'package:studyshare/community/models/community_model.dart';

class MyBookmarkScreen extends StatefulWidget {
  const MyBookmarkScreen({super.key});

  @override
  State<MyBookmarkScreen> createState() => _MyBookmarkScreenState();
}

class _MyBookmarkScreenState extends State<MyBookmarkScreen> {
  final NoteService _noteService = NoteService();
  final CommunityService _communityService = CommunityService();

  // 💡 노트와 커뮤니티 글을 섞어서 담을 리스트 (dynamic)
  List<dynamic> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllBookmarks();
  }

  Future<void> _loadAllBookmarks() async {
    // 1. 노트 북마크 가져오기
    final notes = await _noteService.fetchBookmarkedNotes(1);
    // 2. 커뮤니티 북마크 가져오기
    final communities = await _communityService.fetchBookmarkedCommunities(1);

    if (mounted) {
      setState(() {
        // 3. 두 리스트 합치기
        _allItems = [...notes, ...communities];

        // (선택 사항) 최신순 정렬 등을 하고 싶으면 여기서 sort 가능
        // _allItems.sort((a, b) => ...);

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
            // 1. Header
            AppHeader(
              onLogoTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
              onSearchTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
              onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
              onWriteNoteTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyNoteScreen())),
              onLoginTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              onWriteCommunityTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen())), // 수정됨
              onBookmarkTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen())),
            ),

            // 2. 콘텐츠 영역
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
          width: 90, height: 90,
          decoration: const ShapeDecoration(color: Color(0xFFF3E3FF), shape: OvalBorder()),
          child: Center(child: Image.asset('assets/images/my_bookmark_purple.png', width: 48, height: 43)),
        ),
        const SizedBox(height: 30),
        const Text('북마크', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        const Text('북마크한 콘텐츠가 없습니다', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 100),
        Image.asset('assets/images/my_bookmark_gray.png', width: 75, height: 68),
        const SizedBox(height: 20),
        const Text('아직 북마크한 게시글이 없습니다', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 25),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3E3FF), foregroundColor: const Color(0xFF8F00FF), elevation: 0,
            minimumSize: const Size(200, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.home, size: 24),
          label: const Text('콘텐츠 구경하러 가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        ),
      ],
    );
  }

  Widget _buildDataList() {
    return Column(
      children: [
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(color: Color(0xFFF3E3FF), shape: OvalBorder()),
          child: Center(child: Image.asset('assets/images/my_bookmark_purple.png', width: 48, height: 43)),
        ),
        const SizedBox(height: 30),
        const Text('북마크', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        Text('북마크한 ${_allItems.length}개의 콘텐츠를 확인해보세요', style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 50),

        // 💡 리스트 아이템 렌더링
        ..._allItems.map((item) {

          // 데이터 타입 확인 후 값 추출
          String title = '';
          String category = '';
          String author = '';
          String date = '';
          String preview = '';
          int likes = 0;
          int comments = 0;

          if (item is NoteModel) {
            title = item.title;
            category = "노트"; // 노트는 카테고리를 고정하거나 subjectId 변환 필요
            author = "User ${item.userId}";
            date = item.createDate;
            preview = item.noteContent.replaceAll(RegExp(r'<[^>]*>'), '');
            likes = item.likesCount;
            comments = item.commentsCount;
          } else if (item is CommunityModel) {
            title = item.title;
            category = item.category; // 커뮤니티는 카테고리 그대로 사용
            author = "User ${item.userId}";
            date = item.createDate;
            preview = item.content.replaceAll(RegExp(r'<[^>]*>'), '');
            likes = item.likesCount;
            comments = item.commentCount;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFFCFCFCF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 10, offset: Offset(0, 4))],
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
          );
        }).toList(),
        const SizedBox(height: 80),
      ],
    );
  }
}

// 공통 카드 위젯
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 작성자 아이콘 (공통)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  // 커뮤니티면 노란색, 노트면 보라색 테두리 등을 줄 수도 있음 (여기선 공통 보라색)
                  border: Border.all(color: const Color(0xFF8F00FF), width: 1.0),
                ),
                child: Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text('$author · $date', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 15),
          Text(preview, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 47),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 30),
                  const SizedBox(width: 5),
                  Text('$likes', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 15),
                  const Icon(Icons.comment_outlined, color: Colors.black54, size: 25),
                  const SizedBox(width: 5),
                  Text('$comments', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              // 북마크 화면이므로 꽉 찬 북마크 아이콘 표시
              const Icon(Icons.bookmark, size: 30, color: Color(0xFF8F00FF)),
            ],
          ),
        ],
      ),
    );
  }
}