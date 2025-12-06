// lib/community/models/community_model.dart

class CommunityModel {
  final int id;
  final int userId;
  final String title;
  final String category;
  final String content;
  final int likesCount;
  final int commentCount;
  final int commentLikeCount;
  final String createDate;

  // 💡 추가된 필드
  final int bookmarksCount;
  final bool isLiked;
  final bool isBookmarked;

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
    required this.bookmarksCount,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      // 🚨 [중요] id가 null이면 0이 되므로, 서버에서 id를 보내는지 확인 필수
      id: (json['id'] as num?)?.toInt() ?? 0,

      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',

      // 🚨 [중요] 서버 DTO의 @JsonProperty("likesCount")와 일치해야 함
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,

      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      commentLikeCount: (json['commentLikeCount'] as num?)?.toInt() ?? 0,

      // 🚨 [중요] 서버 DTO의 @JsonProperty("bookmarksCount")와 일치해야 함
      bookmarksCount: (json['bookmarksCount'] as num?)?.toInt() ?? 0,

      createDate: json['createDate'] ?? '',

      // 🚨 [중요] 서버 DTO의 @JsonProperty("isLiked")와 일치해야 함
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }
}