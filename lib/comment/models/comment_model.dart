// lib/comment/models/comment_model.dart

class CommentModel {
  final int id;
  final int userId;
  final String content;
  final String createDate;
  final int? parentCommentId; // 대댓글용 (나중에 쓸 수 있음)

  CommentModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createDate,
    this.parentCommentId,
  });

  // JSON 데이터를 Dart 객체로 변환하는 공장(Factory)
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      // 안전한 형변환 (null이나 다른 타입이 와도 죽지 않게 처리)
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      content: json['content'] as String? ?? '',

      // 날짜가 null이면 빈 문자열로 처리
      createDate: json['createDate'] as String? ?? '',

      parentCommentId: (json['parentCommentId'] as num?)?.toInt(),
    );
  }
}