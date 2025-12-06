// lib/search/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 로직 및 모델
import 'package:studyshare/note/services/note_share_logic.dart';
import 'package:studyshare/community/services/community_share_logic.dart';
import 'package:studyshare/note/models/note_model.dart';
import 'package:studyshare/community/models/community_model.dart';
import 'package:studyshare/note/screens/note_detail_screen.dart';
import 'package:studyshare/community/screens/community_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _recentSearches = [];
  String _currentQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 최근 검색어 불러오기
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  // 최근 검색어 저장
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];

    searches.remove(query); // 중복 제거
    searches.insert(0, query); // 맨 앞에 추가

    if (searches.length > 10) {
      searches.removeLast(); // 최대 10개 유지
    }

    await prefs.setStringList('recent_searches', searches);
    _loadRecentSearches();
  }

  // 최근 검색어 삭제
  Future<void> _removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];
    searches.remove(query);
    await prefs.setStringList('recent_searches', searches);
    _loadRecentSearches();
  }

  // 전체 삭제
  Future<void> _clearAllRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    _loadRecentSearches();
  }

  // 검색 실행
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    _saveRecentSearch(query);
    setState(() {
      _currentQuery = query;
      _isSearching = true;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final noteLogic = Provider.of<StudyShareLogic>(context);
    final communityLogic = Provider.of<CommunityShareLogic>(context);

    // 검색 결과 가져오기
    final searchNotes = noteLogic.searchNotes(_currentQuery);
    final searchPosts = communityLogic.searchPosts(_currentQuery);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              hintStyle: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Color(0xFFB3B3B3), size: 28),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _currentQuery = '';
                    _isSearching = false;
                  });
                },
              )
                  : null,
            ),
            onChanged: (val) {
              setState(() {}); // X 버튼 표시 갱신용
            },
          ),
        ),
      ),
      body: _isSearching
          ? _buildSearchResults(searchNotes, searchPosts)
          : _buildRecentSearches(),
    );
  }

  // 최근 검색어 화면
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: Text(
          '최근 검색 기록이 없습니다',
          style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('최근 검색어', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              TextButton(
                onPressed: _clearAllRecentSearches,
                child: const Text('전체 삭제', style: TextStyle(color: Colors.grey, fontSize: 18)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _recentSearches.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final term = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey, size: 28),
                title: Text(term, style: const TextStyle(fontSize: 20)),
                onTap: () {
                  _searchController.text = term;
                  _performSearch(term);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 24, color: Colors.grey),
                  onPressed: () => _removeRecentSearch(term),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 검색 결과 화면 (디자인 적용)
  Widget _buildSearchResults(List<NoteModel> notes, List<CommunityModel> posts) {
    if (notes.isEmpty && posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 100, color: Color(0xFFB3B3B3)),
            const SizedBox(height: 30),
            Text(
              '"$_currentQuery" 검색 결과가 없습니다',
              style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 24),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (notes.isNotEmpty) ...[
                  const Text('노트 검색 결과', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ...notes.map((note) => _buildNoteItem(note)),
                  const SizedBox(height: 60),
                ],

                if (posts.isNotEmpty) ...[
                  if (notes.isNotEmpty) const Divider(thickness: 1, height: 60, color: Color(0xFFEEEEEE)),
                  const Text('커뮤니티 검색 결과', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ...posts.map((post) => _buildCommunityItem(post)),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 노트 아이템 (MyNoteScreen 디자인 적용)
  Widget _buildNoteItem(NoteModel note) {
    // NoteShareLogic에서 과목명 가져오기 등은 Provider로 처리 가능하나, 여기선 간략히 noteSubjectId 표시하거나 Logic 접근 필요
    final logic = Provider.of<StudyShareLogic>(context, listen: false);
    final subjectName = logic.getSubjectNameById(note.noteSubjectId);
    final displayDate = logic.formatRelativeTime(note.createDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)));
          },
          child: Container(
            padding: const EdgeInsets.all(35),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFCFCFCF)),
                borderRadius: BorderRadius.circular(15),
              ),
              shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: _buildCardContent(
              title: note.title,
              category: subjectName,
              author: "User ${note.userId}",
              date: displayDate,
              preview: note.noteContent,
              likes: note.likesCount,
              comments: note.commentsCount,
              categoryColor: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // 커뮤니티 아이템 (MyCommunityScreen 디자인 적용)
  Widget _buildCommunityItem(CommunityModel post) {
    final logic = Provider.of<CommunityShareLogic>(context, listen: false);
    final displayDate = logic.formatRelativeTime(post.createDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailScreen(post: post)));
          },
          child: Container(
            padding: const EdgeInsets.all(35),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFCFCFCF)),
                borderRadius: BorderRadius.circular(15),
              ),
              shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: _buildCardContent(
              title: post.title,
              category: post.category,
              author: "User ${post.userId}",
              date: displayDate,
              preview: post.content,
              likes: post.likesCount,
              comments: post.commentCount,
              categoryColor: const Color(0xFFF4A908),
            ),
          ),
        ),
      ),
    );
  }

  // 공통 카드 내용 위젯 (디자인 통일)
  Widget _buildCardContent({
    required String title,
    required String category,
    required String author,
    required String date,
    required String preview,
    required int likes,
    required int comments,
    required Color categoryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(radius: 24, backgroundColor: Colors.transparent, child: Icon(Icons.person, size: 48, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 32, fontFamily: 'Inter', fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: categoryColor, width: 1.2),
              ),
              child: Text(category, style: const TextStyle(fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Text('$author · $date', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          preview.replaceAll(RegExp(r'<[^>]*>'), ''),
          style: const TextStyle(fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.5),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 55),
        Row(
          children: [
            const Icon(Icons.favorite_border, color: Colors.grey, size: 36),
            const SizedBox(width: 8),
            Text('$likes', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 22, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            const SizedBox(width: 20),
            const Icon(Icons.comment_outlined, color: Colors.black54, size: 32),
            const SizedBox(width: 8),
            Text('$comments', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 22, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}