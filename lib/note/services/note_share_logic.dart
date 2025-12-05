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
    // userId를 전달해야 '내 좋아요' 상태를 알 수 있음
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
      case 2: return "화법과작문";
      case 3: return "독서";
      case 4: return "언어와 매체";
      case 5: return "문학";
      case 6: return "국어(기타)";
      case 7: return "수학(공통)";
      case 8: return "수학 I";
      case 9: return "수학 II";
      case 10: return "미적분";
      case 11: return "확률과 통계";
      case 12: return "기하";
      case 13: return "경제 수학";
      case 14: return "수학(기타)";
      case 15: return "영어(공통)";
      case 16: return "영어독해와 작문";
      case 17: return "영어회화";
      case 18: return "영어(기타)";
      case 19: return "한국사";
      case 20: return "통합사회";
      case 21: return "지리";
      case 22: return "역사";
      case 23: return "경제";
      case 24: return "정치와 법";
      case 25: return "윤리";
      case 26: return "사회(기타)";
      case 27: return "통합과학";
      case 28: return "물리학";
      case 29: return "화학";
      case 30: return "생명과학";
      case 31: return "지구과학";
      case 32: return "과학탐구실험";
      case 33: return "과학(기타)";
      default: return "기타";
    }
  }

  // 💡 [수정됨] 커뮤니티와 동일한 디테일한 시간 계산 로직 적용
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

  // 💡 [수정됨] 북마크 토글 시 숫자도 같이 변경되도록 수정
  Future<void> toggleBookmark(int noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;

    final note = _notes[index];

    // 북마크 상태 및 숫자 계산
    final isCurrentlyBookmarked = note.isBookmarked;
    final newCount = isCurrentlyBookmarked ? note.bookmarksCount - 1 : note.bookmarksCount + 1;

    // 화면 먼저 갱신
    _notes[index] = note.copyWith(
        isBookmarked: !isCurrentlyBookmarked,
        bookmarksCount: newCount < 0 ? 0 : newCount // 💡 숫자 업데이트 추가
    );
    notifyListeners();

    // 서버 전송
    final success = await _noteService.sendBookmarkRequest(noteId, currentUserId);

    if (!success) {
      print("서버 통신 실패: 북마크 롤백");
      _notes[index] = note;
      notifyListeners();
    }
  }
}