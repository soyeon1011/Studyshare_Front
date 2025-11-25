// lib/Write_Post/note_model.dart

class NoteModel {
  final int id;
  final int noteSubjectId; // 과목 ID
  final int userId; // 작성자 ID
  final String title; // 제목
  final String noteContent;
  final String noteFileUrl;
  final int likesCount;
  final int commentsCount;
  final int commentsLikesCount;
  final String createDate; // 날짜는 String으로 받습니다.

  NoteModel({
    required this.id,
    required this.noteSubjectId,
    required this.userId,
    required this.title,
    required this.noteContent,
    required this.noteFileUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.commentsLikesCount,
    required this.createDate,
  });

  // JSON Map을 Dart 객체로 변환하는 팩토리 생성자
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    // 💡 [핵심] 날짜 필드의 안전한 값 추출 (스네이크 케이스와 카멜 케이스 모두 체크)
    final rawDateString =
        json['create_date'] as String? ?? json['createDate'] as String? ?? '';

    return NoteModel(
      // [유지] Null/타입 안전성 강화 로직 유지
      id: (json['id'] as num?)?.toInt() ?? 0,
      noteSubjectId: (json['note_subject_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,

      // 제목 필드 안전성 유지 (title 또는 note_title 키 체크)
      title: json['title'] as String? ?? json['note_title'] as String? ?? '',

      noteContent: json['note_content'] as String? ?? '',
      noteFileUrl: json['note_file_url'] as String? ?? '',

      // 카운트 필드 안전성 유지
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      commentsLikesCount: (json['comments_likes_count'] as num?)?.toInt() ?? 0,

      // 💡 [수정] 가장 안전한 키에서 추출한 값을 사용
      createDate: rawDateString,
    );
  }
}
