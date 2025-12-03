import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/login/Login_UI.dart';
// 💡 [경로 확인] 필요시 경로를 조정하세요.
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/note/services/note_share_logic.dart';
import 'package:studyshare/note/models/note_model.dart';
// MyWriteNoteScreen이 'screens' 폴더의 자식이라고 가정합니다.
import '../screens/my_write_note_screen.dart';


class MyNoteScreen extends StatelessWidget {
  const MyNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Logic 객체를 Provider를 통해 구독하여 상태를 받아옵니다.
    return Consumer<StudyShareLogic>(
      builder: (context, logic, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          // 💡 [수정 1] Scaffold body를 SingleChildScrollView로 감싸서 전체 스크롤 가능하게 합니다.
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()));
                  },
                  onLoginTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  onWriteCommunityTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen()));
                  },
                ),

                // 2. [핵심 콘텐츠] 상태에 따른 내용 표시
                // 💡 [핵심 수정 2] ConstrainedBox로 최대 너비 1200px 설정 (디자인 통일)
                Center(
                  // Center 위젯으로 감싸서 콘텐츠가 중앙에 오도록 합니다.
                  child: ConstrainedBox(
                    // 💡 [수정] 콘텐츠의 최대 너비를 750px로 고정하여 중앙에 배치합니다.
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      // 고정된 225px 패딩은 제거하고, 수직 패딩과 내부 여백만 남깁니다.
                      padding: const EdgeInsets.symmetric(horizontal: 225.0, vertical: 40.0),
                      child: RefreshIndicator(
                        onRefresh: logic.refreshData,
                        child: _buildContent(context, logic),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 데이터 상태에 따라 Empty State 또는 List State를 반환하는 빌더 함수
  Widget _buildContent(BuildContext context, StudyShareLogic logic) {
    // 1. 로딩 중
    if (logic.isLoadingStatus) {
      return const Center(child: Padding(
        padding: EdgeInsets.only(top: 80.0),
        child: CircularProgressIndicator(),
      ));
    }

    // 2. 데이터가 없을 때 (첫 번째 사진 구현)
    if (logic.notes.isEmpty) {
      return _buildEmptyState(context);
    }

    // 3. 데이터가 있을 때 (두 번째 사진 구현 - 카드 리스트)
    return _buildDataList(context, logic.notes);
  }

  // 데이터가 없을 때의 UI (첫 번째 사진의 중앙 정렬 영역)
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 상단 제목 섹션 (하드코딩 유지)
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(
              color: Color(0x3310595F), shape: OvalBorder()),
          child: Center(
            child: Image.asset('assets/images/my_write_note_green.png', width: 48, height: 43),
          ),
        ),
        const SizedBox(height: 30),
        const Text('내가 작성한 노트', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        const Text('지금까지 작성한 0개의 노트를 확인해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 100),

        // 하단 Empty State
        Image.asset('assets/images/my_write_note_gray.png', width: 75, height: 68),
        const SizedBox(height: 20),
        const Text('아직 작성한 노트가 없습니다', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 10),
        const Text('첫 번째 노트를 작성해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16)),
        const SizedBox(height: 25),

        // '새 노트 작성' 버튼
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x3310595F), foregroundColor: const Color(0xFF10595F), elevation: 0,
            minimumSize: const Size(170, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.add, size: 24),
          label: const Text('새 노트 작성', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
        ),
      ],
    );
  }

  // 데이터가 있을 때의 UI (두 번째 사진 구현 - 카드 리스트)
  Widget _buildDataList(BuildContext context, List<NoteModel> notes) {
    final logic = Provider.of<StudyShareLogic>(context, listen: false);
    final noteCount = notes.length;

    return Column(
      // 💡 [핵심 수정] 모든 콘텐츠를 중앙 정렬
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 상단 제목 및 카운트
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(
              color: Color(0x3310595F), shape: OvalBorder()),
          child: Center(
            child: Image.asset('assets/images/my_write_note_green.png', width: 48, height: 43),
          ),
        ),
        const SizedBox(height: 30),
        const Text('내가 작성한 노트', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        Text(
            '지금까지 작성한 $noteCount개의 노트를 확인해보세요',
            style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 50),

        // ❌ 테이블 헤더 제거 (카드 디자인과 충돌)
        /*
        Row(
          children: const <Widget>[
            _TableHeaderItem(title: '구분', flex: 1),
            _TableHeaderItem(title: '제목', flex: 3),
            _TableHeaderItem(title: '작성자', flex: 1),
            _TableHeaderItem(title: '조회수', flex: 1),
            _TableHeaderItem(title: '등록일', flex: 1),
          ],
        ),
        const Divider(height: 1, thickness: 2, color: Color(0xFFFFCC33)),
        */

        // 노트 데이터 목록 (카드 반복)
        ...notes.map((note) {
          final subjectName = logic.getSubjectNameById(note.noteSubjectId);
          final displayDate = logic.formatRelativeTime(note.createDate);

          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            // 💡 [핵심 수정] 카드 자체에 최대 너비 제약 (중앙 정렬 보장)
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
                child: NoteCardContent(
                  title: note.title.isNotEmpty ? note.title : "(제목 없음)",
                  subject: subjectName,
                  author: note.userId.toString(),
                  date: displayDate,
                  preview: note.noteContent.length > 100
                      ? "${note.noteContent.substring(0, 100)}..."
                      : note.noteContent,
                  likes: note.likesCount,
                  comments: note.commentsCount,
                ),
              ),
            ),
          );
        }).toList(),

        // '새 노트 작성' 버튼 (목록 아래에도 추가)
        const SizedBox(height: 50),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4C542), foregroundColor: Colors.white, elevation: 0,
              minimumSize: const Size(170, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add, size: 24),
            label: const Text('새 노트 작성', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// =================================================================
// NoteCardContent 클래스 (HomeMainScreen에서 복사)
// =================================================================
class NoteCardContent extends StatelessWidget {
  final String title;
  final String subject;
  final String author;
  final String date;
  final String preview;
  final int likes;
  final int comments;

  const NoteCardContent({
    super.key,
    required this.title,
    required this.subject,
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
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 26, fontFamily: 'Inter', fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black54, width: 1.0),
                ),
                child: Text(subject, style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text(
                '$author · $date',
                style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            preview,
            style: const TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Inter', fontWeight: FontWeight.w500),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
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

// =================================================================
// Helper Classes (이전 코드에서 사용했으나 현재는 불필요할 수 있음)
// =================================================================
// Note: _TableHeaderItem과 _TableDataCell은 현재 카드 리스트에서는 사용되지 않지만,
// 혹시 모를 다른 곳에서 사용될 가능성을 염두에 두고 파일에 남겨둡니다.

class _TableHeaderItem extends StatelessWidget {
  final String title;
  final int flex;
  const _TableHeaderItem({super.key, required this.title, required this.flex});
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
        _TableDataCell(text: category, flex: 1),
        _TableDataCell(text: title, flex: 3, alignment: Alignment.centerLeft),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
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