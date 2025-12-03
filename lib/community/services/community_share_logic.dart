// lib/community/services/community_share_logic.dart

import 'package:flutter/material.dart';
import '../models/community_model.dart';
import 'community_service.dart';

class CommunityShareLogic extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();

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

  Future<void> fetchPosts() async {
    final fetchedPosts = await _communityService.fetchAllPosts();
    _posts = fetchedPosts;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await initializeData();
  }

  // [추가] Note Logic과 동일한 상대 시간 포매팅 함수
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