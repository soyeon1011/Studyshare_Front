// lib/bookmark/screens/my_bookmark_screen.dart

import 'package:flutter/material.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/note/screens/my_note_screen.dart'; // 노트 작성 화면

// 💡 데이터 로딩을 위해 추가
import 'package:studyshare/note/services/note_service.dart';
import 'package:studyshare/note/models/note_model.dart';

class MyBookmarkScreen extends StatefulWidget {
  const MyBookmarkScreen({super.key});

  @override
  State<MyBookmarkScreen> createState() => _MyBookmarkScreenState();
}

class _MyBookmarkScreenState extends State<MyBookmarkScreen> {
  final NoteService _noteService = NoteService();
  List<NoteModel> _bookmarkedNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarkData();
  }

  Future<void> _loadBookmarkData() async {
    // 💡 백엔드에서 북마크한 노트 가져오기 (userId=1 임시)
    final notes = await _noteService.fetchBookmarkedNotes(1);

    if (mounted) {
      setState(() {
        _bookmarkedNotes = notes;
        _isLoading = false;
      });
    }
  }

  // 새로고침 기능
  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadBookmarkData();
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
              onWriteCommunityTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen())),
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
                        : _bookmarkedNotes.isEmpty
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

  // 데이터가 없을 때 (Empty State)
  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(
              color: Color(0xFFF3E3FF), shape: OvalBorder()),
          child: Center(
            child: Image.asset('assets/images/my_bookmark_purple.png', width: 48, height: 43),
          ),
        ),
        const SizedBox(height: 30),
        const Text('북마크', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        const Text('북마크한 콘텐츠가 없습니다', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 100),

        Image.asset('assets/images/my_bookmark_gray.png', width: 75, height: 68),
        const SizedBox(height: 20),
        const Text('아직 북마크한 게시글이 없습니다', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 10),
        const Text('마음에 드는 게시글을 저장해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16)),
        const SizedBox(height: 25),

        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()));
          },
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

  // 데이터가 있을 때 리스트 출력
  Widget _buildDataList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 상단 제목
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(
              color: Color(0xFFF3E3FF), shape: OvalBorder()),
          child: Center(
            child: Image.asset('assets/images/my_bookmark_purple.png', width: 48, height: 43),
          ),
        ),
        const SizedBox(height: 30),
        const Text('북마크', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        Text(
            '북마크한 ${_bookmarkedNotes.length}개의 콘텐츠를 확인해보세요',
            style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 50),

        // 리스트 출력
        ..._bookmarkedNotes.map((note) {
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
                  title: note.title.isNotEmpty ? note.title : "(제목 없음)",
                  category: "노트", // 카테고리 정보가 없으면 '노트'로 고정
                  author: "User ${note.userId}", // 작성자 이름 (임시)
                  date: note.createDate,
                  preview: note.noteContent.replaceAll(RegExp(r'<[^>]*>'), ''), // HTML 태그 제거
                  likes: note.likesCount,
                  comments: note.commentsCount,
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

// 💡 카드 디자인 컴포넌트 (재사용)
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.black, fontSize: 26, fontFamily: 'Inter', fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF8F00FF), width: 1.0),
                ),
                child: Text(category, style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text('$author · $date', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 15),
          Text(preview, style: const TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Inter', fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 47),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 30),
                  const SizedBox(width: 5),
                  Text('$likes', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  const SizedBox(width: 15),
                  const Icon(Icons.comment_outlined, color: Colors.black54, size: 25),
                  const SizedBox(width: 5),
                  Text('$comments', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ],
              ),
              const Icon(Icons.bookmark, size: 30, color: Color(0xFF8F00FF)),
            ],
          ),
        ],
      ),
    );
  }
}