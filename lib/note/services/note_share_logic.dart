// lib/note/services/note_share_logic.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'note_service.dart';

class StudyShareLogic extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  // 💡 [핵심] 로그인한 유저 ID (임시 1)
  final int currentUserId = 1;
  final String currentAuthorName = 'Zl회Zone';

  bool _isServerConnected = false;
  bool _isLoadingStatus = true;
  List<NoteModel> _notes = [];

  bool get isServerConnected => _isServerConnected;
  bool get isLoadingStatus => _isLoadingStatus;
  List<NoteModel> get notes => _notes;

  StudyShareLogic() {
    initializeData();
  }

  Future<void> initializeData() async {
    await _checkInitialServerStatus();
    await fetchNotes();
  }

  Future<void> _checkInitialServerStatus() async {
    final isConnected = await _noteService.checkServerStatus();
    _isServerConnected = isConnected;
    _isLoadingStatus = false;
    notifyListeners();
  }

  Future<void> fetchNotes() async {
    // 💡 [수정] userId를 전달해야 '내 좋아요' 상태를 알 수 있음
    final fetchedNotes = await _noteService.fetchAllNotes(currentUserId);
    _notes = fetchedNotes;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await initializeData();
  }

  String getSubjectNameById(int id) {
    switch (id) {
      case 1: return "국어(공통)";
    // ... (나머지 케이스들 생략, 기존 코드 그대로 사용) ...
      default: return "기타";
    }
  }

  String formatRelativeTime(String createDateString) {
    if (createDateString.isEmpty) return '날짜 정보 없음';
    final createdDate = DateTime.tryParse(createDateString);
    if (createdDate == null) return '날짜 형식 오류';

    final now = DateTime.now();
    final difference = now.difference(createdDate);
    // ... (시간 계산 로직 기존과 동일) ...
    return '${difference.inDays}일 전'; // 간단 예시
  }

  // 좋아요 토글
  Future<void> toggleLike(int noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    final note = _notes[index];
    final isCurrentlyLiked = note.isLiked;
    final newCount = isCurrentlyLiked ? note.likesCount - 1 : note.likesCount + 1;

    // 1. 화면 먼저 갱신 (낙관적 업데이트)
    _notes[index] = note.copyWith(
      isLiked: !isCurrentlyLiked,
      likesCount: newCount < 0 ? 0 : newCount,
    );
    notifyListeners();

    // 2. 서버 전송
    final success = await _noteService.sendLikeRequest(noteId, currentUserId);

    // 3. 실패 시 롤백
    if (!success) {
      print("서버 통신 실패: 좋아요 롤백");
      _notes[index] = note;
      notifyListeners();
    }
  }

  // 북마크 토글
  Future<void> toggleBookmark(int noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    final note = _notes[index];

    _notes[index] = note.copyWith(isBookmarked: !note.isBookmarked);
    notifyListeners();

    final success = await _noteService.sendBookmarkRequest(noteId, currentUserId);

    if (!success) {
      print("서버 통신 실패: 북마크 롤백");
      _notes[index] = note;
      notifyListeners();
    }
  }
}