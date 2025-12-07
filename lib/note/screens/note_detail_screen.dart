// lib/note/screens/note_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../models/note_model.dart';
import 'package:studyshare/comment/widgets/comment_section.dart';
import 'note_writing_screen.dart'; // 💡 작성 화면(수정용) 임포트

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("노트 상세", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),

        // 💡 [핵심] 수정 버튼 추가
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            tooltip: '노트 수정',
            onPressed: () async {
              // 수정 화면으로 이동 (기존 note 데이터를 넘겨줌)
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteWritingScreen(note: note),
                ),
              );

              // 수정이 완료되어 돌아왔다면(true), 상세 화면도 닫아서 목록을 갱신하게 함
              if (result == true) {
                if (context.mounted) {
                  Navigator.pop(context); // 목록으로 돌아감 (거기서 새로고침 됨)
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 제목
            Text(
              note.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 2. 작성자 및 날짜 정보
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text("User ${note.userId}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 15),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(note.createDate, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 30, thickness: 1),

            // 3. 본문 내용 (HTML 뷰어)
            HtmlWidget(
              note.noteContent,
              textStyle: const TextStyle(fontSize: 16, height: 1.5),
              customStylesBuilder: (element) {
                if (element.localName == 'img') {
                  return {'max-width': '100%', 'height': 'auto'};
                }
                return null;
              },
            ),

            const SizedBox(height: 50),

            // 4. 댓글 영역
            CommentSection(
              postId: note.id,
              type: 'note',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}