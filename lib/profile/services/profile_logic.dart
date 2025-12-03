// lib/profile/logic/profile_logic.dart

import 'package:flutter/material.dart';
// NoteService와 CommunityService는 이미 정의되어 있다고 가정하고 import
import 'package:studyshare/note/services/note_service.dart';
import 'package:studyshare/community/services/community_service.dart';

class ProfileLogic extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  final CommunityService _communityService = CommunityService();

  // --- 상태 변수 ---
  bool _isLoading = true;
  int _noteCount = 0;
  int _postCount = 0;
  int _likeCount = 0;
  final int _currentUserId = 1; // 💡 임시 사용자 ID (로그인 구현 시 변경 필요)

  bool get isLoading => _isLoading;
  int get noteCount => _noteCount;
  int get postCount => _postCount;
  int get likeCount => _likeCount;

  ProfileLogic() {
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 작성한 노트 개수 가져오기 (NoteService.getNotesByUserId 호출 필요)
      // 현재 NoteService에는 getNotesByUserId가 없으므로, 모든 노트를 가져와서 count하는 방식으로 임시 구현합니다.
      // 🚨 주의: 백엔드에서 getNotesByUserId(1) API가 구현되어 있어야 합니다.
      final notes = await _noteService.getNotesByUserId(_currentUserId);

      // 2. 작성한 게시글 개수 가져오기
      final posts = await _communityService.getPostsByUserId(_currentUserId);

      // 3. 좋아요 개수 가져오기 (현재 API에 LikesService가 없으므로 임시로 0으로 설정)
      final likes = 0; // LikesService 구현 후 변경 예정

      _noteCount = notes.length;
      _postCount = posts.length;
      _likeCount = likes;

    } catch (e) {
      print('Profile data fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}