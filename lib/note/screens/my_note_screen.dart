// lib/note/screens/my_note_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyshare/bookmark/screens/my_bookmark_screen.dart';
import 'package:studyshare/community/screens/my_community_screen.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/profile/screens/profile_screen.dart';
import 'package:studyshare/search/screens/search_screen.dart';
import 'package:studyshare/widgets/header.dart';
import 'package:studyshare/note/services/note_share_logic.dart';
import 'package:studyshare/note/models/note_model.dart';
import '../screens/my_write_note_screen.dart';
import 'package:studyshare/note/screens/note_detail_screen.dart';

class MyNoteScreen extends StatelessWidget {
  const MyNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyShareLogic>(
      builder: (context, logic, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppHeader(
                  onLogoTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen())),
                  onSearchTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
                  onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
                  onWriteNoteTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen())),
                  onLoginTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                  onWriteCommunityTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCommunityScreen())),
                  onBookmarkTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookmarkScreen())),
                ),

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
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

  Widget _buildContent(BuildContext context, StudyShareLogic logic) {
    if (logic.isLoadingStatus) {
      return const Center(child: Padding(
        padding: EdgeInsets.only(top: 80.0),
        child: CircularProgressIndicator(),
      ));
    }
    if (logic.notes.isEmpty) {
      return _buildEmptyState(context);
    }
    return _buildDataList(context, logic.notes);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(color: Color(0x3310595F), shape: OvalBorder()),
          child: Center(child: Image.asset('assets/images/my_write_note_green.png', width: 48, height: 43)),
        ),
        const SizedBox(height: 30),
        const Text('내가 작성한 노트', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        const Text('지금까지 작성한 0개의 노트를 확인해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 100),
        Image.asset('assets/images/my_write_note_gray.png', width: 75, height: 68),
        const SizedBox(height: 20),
        const Text('아직 작성한 노트가 없습니다', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 10),
        const Text('첫 번째 노트를 작성해보세요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16)),
        const SizedBox(height: 25),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen())),
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

  Widget _buildDataList(BuildContext context, List<NoteModel> notes) {
    final logic = Provider.of<StudyShareLogic>(context, listen: false);
    final noteCount = notes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: const ShapeDecoration(color: Color(0x3310595F), shape: OvalBorder()),
          child: Center(child: Image.asset('assets/images/my_write_note_green.png', width: 48, height: 43)),
        ),
        const SizedBox(height: 30),
        const Text('내가 작성한 노트', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400)),
        const SizedBox(height: 15),
        Text('지금까지 작성한 $noteCount개의 노트를 확인해보세요', style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 20)),
        const SizedBox(height: 50),

        ...notes.map((note) {
          final subjectName = logic.getSubjectNameById(note.noteSubjectId);
          final displayDate = logic.formatRelativeTime(note.createDate);

          return Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: GestureDetector(
                // 💡 [핵심 수정] 상세화면 갔다가 돌아오면 데이터 새로고침
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailScreen(note: note),
                    ),
                  );
                  logic.refreshData(); // 데이터 갱신
                },
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
                    author: "User ${note.userId}",
                    date: displayDate,
                    preview: note.noteContent.length > 100 ? "${note.noteContent.substring(0, 100)}..." : note.noteContent,
                    likes: note.likesCount,
                    comments: note.commentsCount,
                    isLiked: note.isLiked,
                    isBookmarked: note.isBookmarked,
                    onLikeTap: () => logic.toggleLike(note.id),
                    onBookmarkTap: () => logic.toggleBookmark(note.id),
                    onCommentTap: () {},
                  ),
                ),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 50),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen())),
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

class NoteCardContent extends StatelessWidget {
  final String title;
  final String subject;
  final String author;
  final String date;
  final String preview;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback onLikeTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onCommentTap;

  const NoteCardContent({
    super.key,
    required this.title,
    required this.subject,
    required this.author,
    required this.date,
    required this.preview,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLikeTap,
    required this.onBookmarkTap,
    required this.onCommentTap,
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
              CircleAvatar(radius: 18, backgroundColor: Colors.transparent, child: Icon(Icons.person, size: 40, color: Colors.grey)),
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black54, width: 1.0)),
                child: Text(subject, style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text('$author · $date', style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 15),
          Text(preview.replaceAll(RegExp(r'<[^>]*>'), ''), style: const TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Inter', fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 47),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: onLikeTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey, size: 30),
                          const SizedBox(width: 5),
                          Text(likes.toString(), style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: onCommentTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.comment_outlined, color: Colors.black54, size: 25),
                          const SizedBox(width: 5),
                          Text(comments.toString(), style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onBookmarkTap,
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined, size: 30, color: isBookmarked ? const Color(0xFF10595F) : Colors.black54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}