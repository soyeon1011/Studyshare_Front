// lib/community/services/community_share_logic.dart

import 'package:flutter/material.dart';
import '../models/community_model.dart';
import 'community_service.dart';

class CommunityShareLogic extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();

  // 💡 [핵심] 현재 로그인한 유저 ID (임시 1)
  final int currentUserId = 1;

  // --- 상태 변수 ---
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

  // 💡 [수정] userId를 전달하여 조회하도록 변경
  Future<void> fetchPosts() async {
    final fetchedPosts = await _communityService.fetchAllPosts(currentUserId);
    _posts = fetchedPosts;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await initializeData();
  }

  // 💡 [추가] 좋아요 토글 (화면 즉시 갱신 + 서버 전송)
  Future<void> toggleLike(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    // 1. 좋아요 상태 반전 및 숫자 조정
    final newIsLiked = !post.isLiked;
    final newCount = newIsLiked ? post.likesCount + 1 : post.likesCount - 1;

    // 2. 화면 먼저 갱신 (Optimistic Update)
    _posts[index] = CommunityModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      category: post.category,
      content: post.content,
      likesCount: newCount < 0 ? 0 : newCount, // 음수 방지
      commentCount: post.commentCount,
      commentLikeCount: post.commentLikeCount,
      createDate: post.createDate,
      bookmarksCount: post.bookmarksCount,
      isLiked: newIsLiked, // 변경된 상태
      isBookmarked: post.isBookmarked,
    );
    notifyListeners();

    // 3. 서버로 전송
    final success = await _communityService.sendLikeRequest(postId, currentUserId);

    // 4. 실패 시 롤백 (원래대로 되돌림)
    if (!success) {
      print("서버 통신 실패: 좋아요 롤백");
      _posts[index] = post; // 원래 객체로 복구
      notifyListeners();
    }
  }

  // 💡 [추가] 북마크 토글 (화면 즉시 갱신 + 서버 전송)
  Future<void> toggleBookmark(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final newIsBookmarked = !post.isBookmarked;
    final newCount = newIsBookmarked ? post.bookmarksCount + 1 : post.bookmarksCount - 1;

    _posts[index] = CommunityModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      category: post.category,
      content: post.content,
      likesCount: post.likesCount,
      commentCount: post.commentCount,
      commentLikeCount: post.commentLikeCount,
      createDate: post.createDate,
      bookmarksCount: newCount < 0 ? 0 : newCount, // 변경된 숫자
      isLiked: post.isLiked,
      isBookmarked: newIsBookmarked, // 변경된 상태
    );
    notifyListeners();

    final success = await _communityService.sendBookmarkRequest(postId, currentUserId);

    if (!success) {
      print("서버 통신 실패: 북마크 롤백");
      _posts[index] = post;
      notifyListeners();
    }
  }

  // 상대 시간 포매팅 함수
  String formatRelativeTime(String createDateString) {
    if (createDateString.isEmpty) return '날짜 정보 없음';

    final createdDate = DateTime.tryParse(createDateString);
    if (createdDate == null) return '날짜 형식 오류';

    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inSeconds < 60) {
      final seconds = difference.inSeconds;
      return '${seconds < 1 ? 1 : seconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays <= 31) {
      return '${difference.inDays}일 전';
    } else {
      final months = difference.inDays ~/ 30;
      return '$months달 전';
    }
  }
}