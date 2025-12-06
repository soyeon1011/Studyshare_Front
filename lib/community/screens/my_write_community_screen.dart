// lib/community/screens/my_write_community_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/bookmark/screens/my_bookmark_screen.dart';
import 'package:studyshare/community/screens/community_writing_screen.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/community/services/community_share_logic.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';

class MyWriteCommunityScreen extends StatefulWidget {
  const MyWriteCommunityScreen({super.key});

  @override
  State<MyWriteCommunityScreen> createState() => _MyWriteCommunityScreenState();
}

class _MyWriteCommunityScreenState extends State<MyWriteCommunityScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 데이터 새로고침
    Future.microtask(() {
      if (mounted) {
        context.read<CommunityShareLogic>().refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityShareLogic>(builder: (context, logic, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          // 💡 [핵심] 노트 화면과 동일하게 120.0 패딩 적용 (박스 크기 복구)
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120.0),
            child: Column(
              children: [
                // 1. 상단 네비게이션 헤더
                AppHeader(
                  onLogoTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
                  onSearchTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
                  onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
                  onWriteNoteTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen())),
                  onLoginTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                  onWriteCommunityTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen())),
                  onBookmarkTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen())),
                ),

                // 2. 검색창 및 작성 버튼 섹션
                _buildHeaderSection(context),

                // 3. 노란색 구분선 (커뮤니티 색상)
                Container(
                  height: 6,
                  color: const Color(0xFFF4A908),
                  margin: const EdgeInsets.only(bottom: 12.0),
                ),

                // 4. 리스트 헤더
                Column(
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 0.0, bottom: 12.0),
                      child: Row(
                        children: <Widget>[
                          _TableHeaderItem(title: '카테고리', flex: 1),
                          _TableHeaderItem(title: '제목', flex: 3),
                          _TableHeaderItem(title: '작성자', flex: 1),
                          _TableHeaderItem(title: '좋아요', flex: 1),
                          _TableHeaderItem(title: '등록일', flex: 1),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 2, color: Color(0xFFF4A908)),
                  ],
                ),

                // 5. 게시글 목록 리스트
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: logic.refreshData,
                    child: logic.isLoadingStatus
                        ? const Center(child: CircularProgressIndicator())
                        : logic.posts.isEmpty
                        ? const Center(
                        child: Text('게시된 게시글이 없습니다.',
                            style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      itemCount: logic.posts.length,
                      itemBuilder: (context, index) {
                        final post = logic.posts[index];
                        String displayDate = logic.formatRelativeTime(post.createDate);

                        return Column(
                          children: [
                            _TableDataItem(
                              category: post.category,
                              title: post.title.isNotEmpty ? post.title : "(제목 없음)",
                              author: post.userId.toString(),
                              views: post.likesCount.toString(),
                              date: displayDate,
                            ),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 6. 하단 페이지네이션
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('<<'), SizedBox(width: 10),
                      Text('<'), SizedBox(width: 10),
                      _PageButton(text: '1', isSelected: true),
                      _PageButton(text: '2'),
                      _PageButton(text: '3'),
                      _PageButton(text: '4'),
                      _PageButton(text: '5'),
                      SizedBox(width: 10),
                      Text('>'), SizedBox(width: 10),
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

  // [헤더 섹션] 노트 화면과 동일한 구조로 작성 버튼 배치
  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text('Study Share',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),

          Row(
            children: [
              // 1. 검색 필드
              SizedBox(
                width: 150,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '검색',
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
              ),
              // 2. 검색 버튼
              SizedBox(
                width: 40, height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A908),
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 24),
                ),
              ),

              const SizedBox(width: 4),

              // 3. 💡 [핵심] 새 게시글 작성 버튼 (노트와 동일 위치)
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 작성 페이지로 이동
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CommunityWritingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A908),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text('새 게시글 작성',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- Helper Widgets (노트 화면과 동일) ----------------

class _TableHeaderItem extends StatelessWidget {
  final String title; final int flex;
  const _TableHeaderItem({required this.title, required this.flex});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFAAAAAA))),
      ),
    );
  }
}

class _TableDataItem extends StatelessWidget {
  final String category, title, author, views, date;
  const _TableDataItem({required this.category, required this.title, required this.author, required this.views, required this.date});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _TableDataCell(text: category, flex: 1),
      _TableDataCell(text: title, flex: 3, alignment: Alignment.center),
      _TableDataCell(text: author, flex: 1),
      _TableDataCell(text: views, flex: 1),
      _TableDataCell(text: date, flex: 1),
    ]);
  }
}

class _TableDataCell extends StatelessWidget {
  final String text; final int flex; final Alignment alignment;
  const _TableDataCell({required this.text, required this.flex, this.alignment = Alignment.center});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String text; final bool isSelected;
  const _PageButton({required this.text, this.isSelected = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 30, alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF4A908) : Colors.transparent,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }
}