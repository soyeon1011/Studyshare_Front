// lib/models/comment_model.dart

class Comment {
  final int id;
  final int userId;
  final String content;
  final String createDate;
  final int? parentCommentId;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createDate,
    this.parentCommentId,
  });

  // JSON 데이터를 Dart 객체로 변환 (Factory 생성자)
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      createDate: json['createDate'] ?? '',
      parentCommentId: json['parentCommentId'],
    );
  }
}