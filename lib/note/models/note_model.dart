// lib/note/models/note_model.dart

class NoteModel {
  final int id;
  final int noteSubjectId;
  final int userId;
  final String title;
  final String noteContent;
  final String noteFileUrl;
  final int likesCount;
  final int commentsCount;
  final int commentsLikesCount;
  final String createDate;
  final int bookmarksCount;

  final bool isLiked;
  final bool isBookmarked;

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
    required this.bookmarksCount,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      // ID
      id: (json['id'] as num?)?.toInt() ?? 0,

      // 과목 ID (백엔드: note_subject_id)
      noteSubjectId: (json['noteSubjectId'] as num?)?.toInt() ??
          (json['note_subject_id'] as num?)?.toInt() ?? 0,

      // 유저 ID (백엔드: user_id)
      userId: (json['userId'] as num?)?.toInt() ??
          (json['noteUserId'] as num?)?.toInt() ??
          (json['user_id'] as num?)?.toInt() ?? 0,

      // 제목 (백엔드: note_title)
      title: json['title'] as String? ??
          json['noteTitle'] as String? ??
          json['note_title'] as String? ?? '',

      // 내용 (백엔드: note_content)
      noteContent: json['noteContent'] as String? ??
          json['note_content'] as String? ?? '',

      // 파일 URL (백엔드: note_file_url)
      noteFileUrl: json['noteFileUrl'] as String? ??
          json['note_file_url'] as String? ?? '',

      // 카운트들 (백엔드: note_likes_count 등)
      likesCount: (json['likesCount'] as num?)?.toInt() ??
          (json['noteLikesCount'] as num?)?.toInt() ??
          (json['note_likes_count'] as num?)?.toInt() ?? 0,

      commentsCount: (json['commentsCount'] as num?)?.toInt() ??
          (json['noteCommentsCount'] as num?)?.toInt() ??
          (json['note_comments_count'] as num?)?.toInt() ?? 0,

      commentsLikesCount: (json['commentsLikesCount'] as num?)?.toInt() ??
          (json['noteCommentsLikesCount'] as num?)?.toInt() ??
          (json['note_comments_likes_count'] as num?)?.toInt() ?? 0,

      bookmarksCount: (json['bookmarksCount'] as num?)?.toInt() ??
          (json['noteBookmarksCount'] as num?)?.toInt() ??
          (json['note_bookmarks_count'] as num?)?.toInt() ?? 0,

      // 날짜 (백엔드: note_create_date)
      createDate: json['createDate'] as String? ??
          json['noteCreateDate'] as String? ??
          json['note_create_date'] as String? ?? '',

      // 상태값
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  // 💡 [이 부분이 없어서 오류가 났습니다]
  NoteModel copyWith({
    int? id,
    int? noteSubjectId,
    int? userId,
    String? title,
    String? noteContent,
    String? noteFileUrl,
    int? likesCount,
    int? commentsCount,
    int? commentsLikesCount,
    String? createDate,
    int? bookmarksCount,

    bool? isLiked,
    bool? isBookmarked,
  }) {
    return NoteModel(
      id: id ?? this.id,
      noteSubjectId: noteSubjectId ?? this.noteSubjectId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      noteContent: noteContent ?? this.noteContent,
      noteFileUrl: noteFileUrl ?? this.noteFileUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      commentsLikesCount: commentsLikesCount ?? this.commentsLikesCount,
      createDate: createDate ?? this.createDate,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,

      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}