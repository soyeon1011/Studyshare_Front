// lib/Write_Post/my_write_note_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/bookmark/screens/my_bookmark_screen.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/community/screens/my_write_community_screen.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/note/services/note_share_logic.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'note_writing_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyShareLogic()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWriteNoteScreen(),
    );
  }
}

// 💡 [수정] StatelessWidget -> StatefulWidget으로 변경하여 진입 시 자동 갱신 구현
class MyWriteNoteScreen extends StatefulWidget {
  const MyWriteNoteScreen({super.key});

  @override
  State<MyWriteNoteScreen> createState() => _MyWriteNoteScreenState();
}

class _MyWriteNoteScreenState extends State<MyWriteNoteScreen> {
  @override
  void initState() {
    super.initState();
    // 💡 [핵심] 화면이 생성될 때 데이터를 새로고침합니다.
    // Provider가 트리에 있는지 확인 후 호출 (Microtask로 지연 실행하여 안전하게 처리)
    Future.microtask(() {
      if (mounted) {
        context.read<StudyShareLogic>().refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // StudyShareLogic 객체를 Provider를 통해 구독합니다.
    return Consumer<StudyShareLogic>(builder: (context, logic, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120.0),
            child: Column(
              children: [
                AppHeader(
                  onLogoTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MainScreen()));
                  },
                  onSearchTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SearchScreen()));
                  },
                  onProfileTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                  onWriteNoteTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyCommunityScreen()));
                  },
                  onLoginTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  onWriteCommunityTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen()));
                  },
                  onBookmarkTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyBookmarkScreen()));
                  },
                ),

                // 2. 헤더 섹션 (타이틀, 검색, 작성 버튼)
                _buildHeaderSection(context),

                // --- 두꺼운 노란색 구분선 ---
                Container(
                  height: 6,
                  color: const Color(0xFFFFCC33),
                  margin: const EdgeInsets.only(bottom: 12.0),
                ),

                // --- 테이블 헤더 (고정) ---
                Column(
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 0.0, bottom: 12.0),
                      child: Row(
                        children: <Widget>[
                          _TableHeaderItem(title: '구분', flex: 1),
                          _TableHeaderItem(title: '제목', flex: 3),
                          _TableHeaderItem(title: '작성자', flex: 1),
                          _TableHeaderItem(title: '조회수', flex: 1),
                          _TableHeaderItem(title: '등록일', flex: 1),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 2, color: Color(0xFFFFCC33)),
                  ],
                ),

                // --- 테이블 데이터 영역 (동적 로딩) ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: logic.refreshData,
                    child: logic.isLoadingStatus
                        ? const Center(child: CircularProgressIndicator())
                        : logic.notes.isEmpty
                        ? const Center(
                        child: Text('게시된 노트가 없습니다.',
                            style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      itemCount: logic.notes.length,
                      itemBuilder: (context, index) {
                        final note = logic.notes[index];

                        String displayDate =
                        logic.formatRelativeTime(note.createDate);

                        return Column(
                          children: [
                            _TableDataItem(
                              category: logic.getSubjectNameById(
                                  note.noteSubjectId),
                              title: note.title.isNotEmpty
                                  ? note.title
                                  : "(제목 없음)",
                              author: note.userId.toString(),
                              views: note.likesCount.toString(),
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
                      _PageButton(text: '4'),
                      _PageButton(text: '5'),
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
                    backgroundColor: const Color(0xFFFFCC33),
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
                            builder: (context) => const NoteWritingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC33),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text('게시물 작성하기',
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
// 테이블 구성 요소 위젯 (Helper Classes)
// =================================================================

class _TableHeaderItem extends StatelessWidget {
  final String title;
  final int flex;
  final Alignment alignment;
  const _TableHeaderItem(
      {super.key,
        required this.title,
        required this.flex,
        this.alignment = Alignment.center});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
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
        _TableDataCell(text: category, flex: 1),
        _TableDataCell(text: title, flex: 3, alignment: Alignment.center),
        _TableDataCell(text: author, flex: 1),
        _TableDataCell(text: views, flex: 1),
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

  const _PageButton({required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFCC33) : Colors.transparent,
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