// lib/bookmark/screens/my_bookmark_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/community/screens/my_write_community_screen.dart'; // 필요시 유지
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/bookmark/services/bookmark_logic.dart'; // 💡 Bookmark Logic
import 'package:studyshare/bookmark/models/bookmark_model.dart'; // 💡 Bookmark Model

class MyBookmarkScreen extends StatelessWidget {
  const MyBookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 [핵심] BookmarkLogic을 구독합니다.
    return Consumer<BookmarkLogic>(
      builder: (context, logic, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Header
                AppHeader(
                  onLogoTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                  },
                  onSearchTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
                  },
                  onProfileTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                  onWriteNoteTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const MyNoteScreen()));
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

                // 2. [핵심 콘텐츠]
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
                      child: RefreshIndicator(
                        onRefresh: logic.refreshData,
                        child: _buildContent(context, logic),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  // 상태별 빌더
  Widget _buildContent(BuildContext context, BookmarkLogic logic) {
    if (logic.isLoadingStatus) {
      return const Center(child: Padding(
        padding: EdgeInsets.only(top: 80.0),
        child: CircularProgressIndicator(color: Color(0xFF8F00FF)), // 보라색 로딩
      ));
    }

    if (logic.bookmarks.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildDataList(context, logic.bookmarks);
  }

  // 데이터가 없을 때 (Empty State)
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 💡 [디자인] 보라색 배경
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

        // 하단 Empty State
        Image.asset('assets/images/my_bookmark_gray.png', width: 75, height: 68),
        const SizedBox(height: 20),
        const Text('아직 북마크한 게시글이 없습니다', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 10),
        const Text('마음에 드는 게시글을 저장해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16)),
        const SizedBox(height: 25),

        // [변경] 북마크 화면에서는 '글 작성' 대신 '홈으로 가기' 버튼이 자연스러움
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

  // 데이터가 있을 때 (List State)
  Widget _buildDataList(BuildContext context, List<BookmarkModel> bookmarks) {
    final logic = Provider.of<BookmarkLogic>(context, listen: false);
    final count = bookmarks.length;

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
            '북마크한 $count개의 콘텐츠를 확인해보세요',
            style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 50),

        // 리스트 출력
        ...bookmarks.map((item) {
          final displayDate = logic.formatRelativeTime(item.createDate);

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
                // 💡 PostCardContent 재사용
                child: PostCardContent(
                  title: item.title.isNotEmpty ? item.title : "(제목 없음)",
                  category: item.category,
                  author: item.userId.toString(),
                  date: displayDate,
                  preview: item.content.length > 100
                      ? "${item.content.substring(0, 100)}..."
                      : item.content,
                  likes: item.likesCount,
                  comments: item.commentCount,
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

// 💡 PostCardContent (Community와 동일하게 사용)
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
                  border: Border.all(color: const Color(0xFF8F00FF), width: 1.0), // 💡 보라색 테두리
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
                  Text(likes.toString(), style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  const SizedBox(width: 15),
                  const Icon(Icons.comment_outlined, color: Colors.black54, size: 25),
                  const SizedBox(width: 5),
                  Text(comments.toString(), style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ],
              ),
              // 💡 북마크된 상태 (채워진 아이콘)
              const Icon(Icons.bookmark, size: 30, color: Color(0xFF8F00FF)),
            ],
          ),
        ],
      ),
    );
  }
}