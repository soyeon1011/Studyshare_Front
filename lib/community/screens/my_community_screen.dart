import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/community/screens/my_write_community_screen.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/login/Login_UI.dart'; // LoginScreen import
import 'package:studyshare/community/services/community_share_logic.dart'; // 💡 커뮤니티 Logic
import 'package:studyshare/community/models/community_model.dart'; // 💡 커뮤니티 Model
// [추가] 커뮤니티 작성 화면 (PostWritingScreen으로 가정)


class MyCommunityScreen extends StatelessWidget {
  const MyCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 [핵심] CommunityShareLogic을 구독합니다.
    return Consumer<CommunityShareLogic>(
      builder: (context, logic, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Header (메뉴 버튼)
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen()));
                  },
                  onLoginTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  onWriteCommunityTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen()));
                  },
                ),

                // 2. [핵심 콘텐츠] 상태에 따른 내용 표시
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0), // 패딩 통일
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

  // 데이터 상태에 따라 Empty State 또는 List State를 반환하는 빌더 함수
  Widget _buildContent(BuildContext context, CommunityShareLogic logic) {

    if (logic.isLoadingStatus) {
      return const Center(child: Padding(
        padding: EdgeInsets.only(top: 80.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (logic.posts.isEmpty) { // 💡 [수정] notes -> posts
      return _buildEmptyState(context);
    }

    return _buildDataList(context, logic.posts);
  }

  // 데이터가 없을 때의 UI (Empty State)
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 💡 [수정] 아이콘 배경색 커뮤니티 색상으로 변경
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(
              color: Color(0xFFFFF2CB), shape: OvalBorder()),
          child: Center(
            child: Image.asset('assets/images/my_write_post_yellow.png', width: 48, height: 43),
          ),
        ),
        const SizedBox(height: 30),
        const Text('내가 작성한 게시글', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)), // 💡 [수정] 노트 -> 게시글
        const SizedBox(height: 15),
        const Text('지금까지 작성한 0개의 게시글을 확인해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 100),

        // 하단 Empty State
        Image.asset('assets/images/my_write_post_gray.png', width: 75, height: 68),
        const SizedBox(height: 20),
        const Text('아직 작성한 게시글이 없습니다', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)), // 💡 [수정] 노트 -> 게시글
        const SizedBox(height: 10),
        const Text('첫 번째 게시글을 작성해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16)), // 💡 [수정] 노트 -> 게시글
        const SizedBox(height: 25),

        // '새 게시글 작성' 버튼
        ElevatedButton.icon(
          onPressed: () {
            // 💡 [수정] PostWritingScreen으로 이동
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF2CB), foregroundColor: const Color(0xFFF4A908), elevation: 0, // 커뮤니티 색상
            minimumSize: const Size(170, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.add, size: 24),
          label: const Text('새 게시글 작성', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)), // 💡 [수정] 노트 -> 게시글
        ),
      ],
    );
  }

  // 데이터가 있을 때의 UI (카드 리스트)
  Widget _buildDataList(BuildContext context, List<CommunityModel> posts) {
    final logic = Provider.of<CommunityShareLogic>(context, listen: false);
    final postCount = posts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 상단 제목 및 카운트
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(
              color: Color(0xFFFFF2CB), shape: OvalBorder()),
          child: Center(
            child: Image.asset('assets/images/my_write_post_yellow.png', width: 48, height: 43),
          ),
        ),
        const SizedBox(height: 30),
        const Text('내가 작성한 게시글', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)), // 💡 [수정] 노트 -> 게시글
        const SizedBox(height: 15),
        Text(
            '지금까지 작성한 $postCount개의 게시글을 확인해보세요',
            style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 50),

        // 노트 데이터 목록 (카드 반복)
        ...posts.map((post) {
          final displayDate = logic.formatRelativeTime(post.createDate);

          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700), // 카드의 최대 너비를 제한하여 중앙 정렬이 깔끔하게 보이도록 설정
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
                // 💡 [수정] PostCardContent 사용
                child: PostCardContent(
                  title: post.title.isNotEmpty ? post.title : "(제목 없음)",
                  category: post.category,
                  author: post.userId.toString(),
                  date: displayDate,
                  preview: post.content.length > 100
                      ? "${post.content.substring(0, 100)}..."
                      : post.content,
                  likes: post.likesCount,
                  comments: post.commentCount,
                ),
              ),
            ),
          );
        }).toList(),

        // '새 게시글 작성' 버튼 (목록 아래에도 추가)
        const SizedBox(height: 50),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4A908), foregroundColor: Colors.white, elevation: 0,
              minimumSize: const Size(170, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add, size: 24),
            label: const Text('새 게시글 작성', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // 💡 [수정] 노트 -> 게시글
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// =================================================================
// PostCardContent 클래스 (커뮤니티 카드 위젯)
// =================================================================
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
                  border: Border.all(color: const Color(0xFFF4A908), width: 1.0), // 커뮤니티 색상
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
              const Icon(Icons.bookmark_border_outlined, size: 30, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }
}