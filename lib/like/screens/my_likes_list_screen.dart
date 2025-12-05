// lib/like/screens/my_likes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:studyshare/bookmark/screens/my_bookmark_screen.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/note/screens/my_note_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';

// 💡 데이터 로딩을 위해 추가
import 'package:studyshare/note/services/note_service.dart';
import 'package:studyshare/note/models/note_model.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikesScreen> {
  // 1. 선택 상태를 관리할 리스트 [노트, 게시글]
  final List<bool> _isSelected = [true, false];

  // 💡 2. 서비스와 데이터 변수 준비
  final NoteService _noteService = NoteService();
  List<NoteModel> _likedNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedData(); // 화면 시작 시 데이터 가져오기
  }

  // 💡 3. 데이터 가져오는 함수
  Future<void> _loadLikedData() async {
    // 임시 유저 ID 1 (나중에 로그인 정보로 교체)
    final notes = await _noteService.fetchLikedNotes(1);

    if (mounted) {
      setState(() {
        _likedNotes = notes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
              onLogoTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
              onSearchTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
              onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
              onLoginTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              onWriteNoteTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyNoteScreen()));
              },
              onWriteCommunityTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen()));
              },
              onBookmarkTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen()));
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

                  // --- 탭 버튼 ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: ToggleButtons(
                      isSelected: _isSelected,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _isSelected.length; i++) {
                            _isSelected[i] = false;
                          }
                          _isSelected[index] = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(25.0),
                      borderColor: Colors.transparent,
                      selectedBorderColor: Colors.transparent,
                      fillColor: Colors.white,
                      splashColor: Colors.grey.withOpacity(0.12),
                      hoverColor: Colors.grey.withOpacity(0.04),
                      children: <Widget>[
                        _buildTab('노트 (${_likedNotes.length})', Icons.description_outlined),
                        _buildTab('게시글 (0)', Icons.chat_bubble_outline),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // 💡 4. 로딩 및 데이터 표출 로직
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else if (_isSelected[0]) ...[
                    // [노트 탭]
                    if (_likedNotes.isEmpty)
                      _buildEmptyState('노트')
                    else
                      _buildNoteList(), // 리스트 그리기
                  ] else ...[
                    // [게시글 탭] (아직 구현 안 함)
                    _buildEmptyState('게시글'),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 리스트 뷰 빌더
  Widget _buildNoteList() {
    return ListView.separated(
      shrinkWrap: true, // Column 안에서 ListView 쓸 때 필수
      physics: const NeverScrollableScrollPhysics(), // 전체 스크롤 사용
      itemCount: _likedNotes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final note = _likedNotes[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 내용 미리보기 (HTML 태그 제거는 생략하고 간단히 표시)
              Text(
                note.noteContent.replaceAll(RegExp(r'<[^>]*>'), ''), // 태그 제거
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text('${note.likesCount}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.bookmark, color: Color(0xFF8F00FF), size: 16),
                  const SizedBox(width: 4),
                  Text('${note.bookmarksCount}'), // 북마크 개수
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Column(
      children: [
        Image.asset(
          'assets/images/my_likes_list_gray.png',
          width: 100,
          height: 100,
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

  Widget _buildTab(String text, IconData icon) {
    return SizedBox(
      width: 400, // 버튼 너비
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