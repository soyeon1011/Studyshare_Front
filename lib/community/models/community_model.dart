// lib/community/models/community_model.dart

class CommunityModel {
  final int id;
  final int userId;
  final String title;
  final String category; // 과목 ID 대신 카테고리
  final String content;
  final int likesCount;
  final int commentCount;
  final int commentLikeCount;
  final String createDate;

  CommunityModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.content,
    required this.likesCount,
    required this.commentCount,
    required this.commentLikeCount,
    required this.createDate,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    // 백엔드의 카멜 케이스/스네이크 케이스 모두 체크
    return CommunityModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? (json['user_id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? json['community_title'] as String? ?? '',
      category: json['category'] as String? ?? json['community_category'] as String? ?? '',
      content: json['content'] as String? ?? json['community_content'] as String? ?? '',

      likesCount: (json['likesCount'] as num?)?.toInt() ?? (json['community_likes_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? (json['community_comment_count'] as num?)?.toInt() ?? 0,
      commentLikeCount: (json['commentLikeCount'] as num?)?.toInt() ?? (json['community_comment_like_count'] as num?)?.toInt() ?? 0,

      createDate: json['createDate'] as String? ?? json['community_create_date'] as String? ?? '',
    );
  }
}