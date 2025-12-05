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
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',

      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      commentLikeCount: (json['commentLikeCount'] as num?)?.toInt() ?? 0,
      bookmarksCount: (json['bookmarksCount'] as num?)?.toInt() ?? 0, // 💡 추가

      createDate: json['createDate'] ?? '',

      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }
}