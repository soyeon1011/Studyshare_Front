// lib/profile/services/profile_logic.dart

import 'package:flutter/material.dart';
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
  int _bookmarkCount = 0; // 북마크 개수 추가

  final int _currentUserId = 1; // 💡 임시 사용자 ID

  bool get isLoading => _isLoading;
  int get noteCount => _noteCount;
  int get postCount => _postCount;
  int get likeCount => _likeCount;
  int get bookmarkCount => _bookmarkCount; // Getter 추가

  ProfileLogic() {
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 작성한 노트 & 커뮤니티 글 가져오기
      final notes = await _noteService.getNotesByUserId(_currentUserId);
      final posts = await _communityService.getPostsByUserId(_currentUserId);

      // 2. 좋아요한 노트 & 커뮤니티 글 가져오기 (서비스에 추가된 메서드 사용)
      final likedNotes = await _noteService.fetchLikedNotes(_currentUserId);
      final likedCommunities = await _communityService.fetchLikedCommunities(_currentUserId);

      // 3. 북마크한 노트 & 커뮤니티 글 가져오기 (서비스에 추가된 메서드 사용)
      final bookmarkedNotes = await _noteService.fetchBookmarkedNotes(_currentUserId);
      final bookmarkedCommunities = await _communityService.fetchBookmarkedCommunities(_currentUserId);

      //final likedCommunities = await _communityService.fetchLikedCommunities(_currentUserId);

      // 개수 업데이트 (노트 + 커뮤니티 합산)
      _noteCount = notes.length;
      _postCount = posts.length;
      _likeCount = likedNotes.length + likedCommunities.length;
      _bookmarkCount = bookmarkedNotes.length + bookmarkedCommunities.length;

    } catch (e) {
      print('Profile data fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}