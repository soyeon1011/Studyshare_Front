import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/community/screens/community_writing_screen.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
// 💡 [수정] 커뮤니티 Logic/Model을 사용하도록 변경
import 'package:studyshare/community/services/community_share_logic.dart';
import 'package:studyshare/community/models/community_model.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';


class MyWriteCommunityScreen extends StatelessWidget {
  const MyWriteCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 [핵심] CommunityShareLogic을 구독합니다.
    return Consumer<CommunityShareLogic>(builder: (context, logic, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120.0),
            child: Column(
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

                // 2. 헤더 섹션 (타이틀, 검색, 작성 버튼)
                _buildHeaderSection(context),

                // --- 두꺼운 노란색 구분선 (커뮤니티 색상) ---
                Container(
                  height: 6,
                  color: const Color(0xFFF4A908), // 커뮤니티 색상
                  margin: const EdgeInsets.only(bottom: 12.0),
                ),

                // --- 테이블 헤더 (고정) ---
                Column(
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 0.0, bottom: 12.0),
                      child: Row(
                        children: <Widget>[
                          // 💡 [수정] 구분 -> 카테고리
                          _TableHeaderItem(title: '카테고리', flex: 1),
                          _TableHeaderItem(title: '제목', flex: 3),
                          _TableHeaderItem(title: '작성자', flex: 1),
                          _TableHeaderItem(title: '좋아요', flex: 1), // 조회수 -> 좋아요
                          _TableHeaderItem(title: '등록일', flex: 1),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 2, color: Color(0xFFF4A908)), // 커뮤니티 색상
                  ],
                ),

                // --- 테이블 데이터 영역 (동적 로딩) ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: logic.refreshData,
                    child: logic.isLoadingStatus
                        ? const Center(child: CircularProgressIndicator())
                        : logic.posts.isEmpty // 💡 [수정] notes -> posts
                        ? const Center(
                        child: Text('게시된 게시글이 없습니다.',
                            style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      itemCount: logic.posts.length,
                      itemBuilder: (context, index) {
                        final post = logic.posts[index]; // 💡 [수정] notes -> posts

                        String displayDate =
                        logic.formatRelativeTime(post.createDate);

                        return Column(
                          children: [
                            _TableDataItem(
                              category: post.category, // 💡 [수정] 카테고리 필드 사용
                              title: post.title.isNotEmpty
                                  ? post.title
                                  : "(제목 없음)",
                              author: post.userId.toString(),
                              views: post.likesCount.toString(), // 💡 [수정] 좋아요 수 사용
                              date: displayDate,
                            ),
                            const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFDDDDDD)),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // --- 페이지네이션 (임시) ---
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('<<'),
                      SizedBox(width: 10),
                      Text('<'),
                      SizedBox(width: 10),
                      _PageButton(text: '1', isSelected: true),
                      _PageButton(text: '2'),
                      _PageButton(text: '3'),
                      SizedBox(width: 10),
                      Text('>'),
                      SizedBox(width: 10),
                      Text('>>'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 서버 상태를 시각적으로 보여주는 위젯 (NoteWritingScreen에서 복사)
  Widget _buildServerStatusWidget(CommunityShareLogic logic) {
    Color color;
    String message;
    IconData icon;

    if (logic.isLoadingStatus) {
      color = Colors.blueGrey;
      message = '서버 연결 상태 확인 중...';
      icon = Icons.sync;
    } else if (logic.isServerConnected) {
      color = Colors.green.shade700;
      message = '🟢 서버 연결됨: API 호출 준비 완료 (localhost:8081)';
      icon = Icons.check_circle;
    } else {
      color = Colors.red.shade700;
      message = '🔴 서버 연결 실패: Spring Boot 서버(8081)를 실행하세요.';
      icon = Icons.warning;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: color.withOpacity(0.1),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색바와 버튼 영역 (헤더 섹션)
  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text('Study Share',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          Row(
            children: [
              // 1. 검색 필드
              SizedBox(
                width: 150,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '검색',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0),
                        topRight: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0),
                        topRight: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
              ),
              // 2. 검색 버튼
              SizedBox(
                width: 40,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A908), // 커뮤니티 색상
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0),
                        topLeft: Radius.zero,
                        bottomLeft: Radius.zero,
                      ),
                    ),
                  ),
                  child:
                  const Icon(Icons.search, color: Colors.white, size: 24),
                ),
              ),

              const SizedBox(width: 4),

              // 3. 게시물 작성 버튼
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CommunityWritingScreen())); // 💡 [수정] PostWritingScreen으로 이동
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A908), // 커뮤니티 색상
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text('새 게시글 작성', // 💡 [수정] 노트 -> 게시글
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 테이블 구성 요소 위젯 (Helper Classes) - MyWriteCommunityScreen 파일 내에 정의
// =================================================================

class _TableHeaderItem extends StatelessWidget {
  final String title;
  final int flex;
  const _TableHeaderItem(
      {super.key,
        required this.title,
        required this.flex,
        // alignment 파라미터는 이전 코드에서 사용되지 않았으므로 제거하지 않음
      });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFFAAAAAA),
          ),
        ),
      ),
    );
  }
}

class _TableDataItem extends StatelessWidget {
  final String category;
  final String title;
  final String author;
  final String views;
  final String date;
  const _TableDataItem({
    super.key,
    required this.category,
    required this.title,
    required this.author,
    required this.views,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _TableDataCell(text: category, flex: 1), // 카테고리 (자유)
        _TableDataCell(text: title, flex: 3, alignment: Alignment.centerLeft), // 제목은 왼쪽 정렬이 자연스러움
        _TableDataCell(text: author, flex: 1),
        _TableDataCell(text: views, flex: 1), // 좋아요 수
        _TableDataCell(text: date, flex: 1),
      ],
    );
  }
}

class _TableDataCell extends StatelessWidget {
  final String text;
  final int flex;
  final Alignment alignment;
  const _TableDataCell({
    super.key,
    required this.text,
    required this.flex,
    this.alignment = Alignment.center,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFAAAAAA),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _PageButton({super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF4A908) : Colors.transparent, // 커뮤니티 색상
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}