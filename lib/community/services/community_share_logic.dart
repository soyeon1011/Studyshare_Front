// lib/community/services/community_share_logic.dart

import 'package:flutter/material.dart';
import '../models/community_model.dart';
import 'community_service.dart';

class CommunityShareLogic extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  final int currentUserId = 1; // 임시 유저 ID

  bool _isServerConnected = false;
  bool _isLoadingStatus = true;
  List<CommunityModel> _posts = [];

  bool get isServerConnected => _isServerConnected;
  bool get isLoadingStatus => _isLoadingStatus;
  List<CommunityModel> get posts => _posts;

  CommunityShareLogic() {
    initializeData();
  }

  Future<void> initializeData() async {
    await _checkInitialServerStatus();
    await fetchPosts();
  }

  Future<void> _checkInitialServerStatus() async {
    final isConnected = await _communityService.checkServerStatus();
    _isServerConnected = isConnected;
    _isLoadingStatus = false;
    notifyListeners();
  }

  Future<void> fetchPosts() async {
    final fetchedPosts = await _communityService.fetchAllPosts(currentUserId);

    // 최신순(날짜 내림차순) 정렬 적용
    fetchedPosts.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a.createDate) ?? DateTime(2000);
      DateTime dateB = DateTime.tryParse(b.createDate) ?? DateTime(2000);
      return dateB.compareTo(dateA); // 최신 날짜가 먼저 오도록
    });

    _posts = fetchedPosts;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await initializeData();
  }

  // 좋아요 토글
  Future<void> toggleLike(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final newIsLiked = !post.isLiked;
    final newCount = newIsLiked ? post.likesCount + 1 : post.likesCount - 1;

    _posts[index] = post.copyWith(
      isLiked: newIsLiked,
      likesCount: newCount < 0 ? 0 : newCount,
    );
    notifyListeners();

    final success = await _communityService.sendLikeRequest(postId, currentUserId);
    if (!success) {
      _posts[index] = post; // 실패 시 롤백
      notifyListeners();
    }
  }

  // 💡 [추가됨] 북마크 토글 (이 부분이 없어서 오류가 났습니다)
  Future<void> toggleBookmark(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final newIsBookmarked = !post.isBookmarked;
    final newCount = newIsBookmarked ? post.bookmarksCount + 1 : post.bookmarksCount - 1;

    // 화면 즉시 갱신 (Optimistic Update)
    _posts[index] = post.copyWith(
      isBookmarked: newIsBookmarked,
      bookmarksCount: newCount < 0 ? 0 : newCount,
    );
    notifyListeners();

    // 서버 전송
    final success = await _communityService.sendBookmarkRequest(postId, currentUserId);

    // 실패 시 롤백
    if (!success) {
      _posts[index] = post;
      notifyListeners();
    }
  }

  String formatRelativeTime(String createDateString) {
    if (createDateString.isEmpty) return '날짜 정보 없음';
    final createdDate = DateTime.tryParse(createDateString);
    if (createdDate == null) return '날짜 형식 오류';
    final now = DateTime.now();
    final difference = now.difference(createdDate);
    if (difference.inSeconds < 60) return '${difference.inSeconds < 1 ? 1 : difference.inSeconds}초 전';
    else if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    else if (difference.inHours < 24) return '${difference.inHours}시간 전';
    else if (difference.inDays <= 31) return '${difference.inDays}일 전';
    else return '${difference.inDays ~/ 30}달 전';
  }
}

// Model Extension
extension CommunityModelExtension on CommunityModel {
  CommunityModel copyWith({bool? isLiked, int? likesCount, bool? isBookmarked, int? bookmarksCount}) {
    return CommunityModel(
      id: id, userId: userId, title: title, category: category, content: content,
      likesCount: likesCount ?? this.likesCount,
      commentCount: commentCount, commentLikeCount: commentLikeCount,
      createDate: createDate,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}