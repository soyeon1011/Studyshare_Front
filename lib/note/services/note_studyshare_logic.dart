// lib/Write_Post/studyshare_logic.dart

import 'package:flutter/material.dart';
import 'package:studyshare/note/models/note_model.dart';

import 'note_service.dart';

class StudyShareLogic extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  // --- 상태 변수 및 초기화 로직 (유지) ---
  bool _isServerConnected = false;
  bool _isLoadingStatus = true;
  List<NoteModel> _notes = [];

  bool get isServerConnected => _isServerConnected;
  bool get isLoadingStatus => _isLoadingStatus;
  List<NoteModel> get notes => _notes;
  final String currentAuthorName = 'Zl회Zone';

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
    final fetchedNotes = await _noteService.fetchAllNotes();
    _notes = fetchedNotes;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await initializeData();
  }
  // --- 상태 변수 및 초기화 로직 (끝) ---

  // 💡 [수정] 모든 과목 ID를 이름으로 변환하는 로직
  String getSubjectNameById(int id) {
    switch (id) {
      case 1:
        return "국어(공통)";
      case 2:
        return "화법과작문";
      case 3:
        return "독서";
      case 4:
        return "언어와 매체";
      case 5:
        return "문학";
      case 6:
        return "국어(기타)";
      case 7:
        return "수학(공통)";
      case 8:
        return "수학 I";
      case 9:
        return "수학 II";
      case 10:
        return "미적분";
      case 11:
        return "확률과 통계";
      case 12:
        return "기하";
      case 13:
        return "경제 수학";
      case 14:
        return "수학(기타)";
      case 15:
        return "영어(공통)";
      case 16:
        return "영어독해와 작문";
      case 17:
        return "영어회화";
      case 18:
        return "영어(기타)";
      case 19:
        return "한국사";
      case 20:
        return "통합사회";
      case 21:
        return "지리";
      case 22:
        return "역사";
      case 23:
        return "경제";
      case 24:
        return "정치와 법";
      case 25:
        return "윤리";
      case 26:
        return "사회(기타)";
      case 27:
        return "통합과학";
      case 28:
        return "물리학";
      case 29:
        return "화학";
      case 30:
        return "생명과학";
      case 31:
        return "지구과학";
      case 32:
        return "과학탐구실험";
      case 33:
        return "과학(기타)";
      case 0: // DB 스크린샷에서 0으로 넘어오는 경우 명시
      default:
        return "기타";
    }
  }

  // 💡 [핵심] 등록일(createDate)을 상대 시간으로 변환하는 로직 (안전성 강화)
  String formatRelativeTime(String createDateString) {
    // 1. 입력 문자열이 null이거나 비어있을 경우 즉시 처리
    // note_model.dart에서 이미 null/empty 처리를 했으므로 이 코드는 유지합니다.
    if (createDateString == null || createDateString.isEmpty) {
      return '날짜 정보 없음';
    }

    // 2. 안전하게 DateTime 객체로 변환 시도 (tryParse 사용)
    final createdDate = DateTime.tryParse(createDateString);

    // 3. 변환 실패 시 (잘못된 형식) 처리
    if (createdDate == null) {
      return '날짜 형식 오류';
    }

    final now = DateTime.now();
    final difference = now.difference(createdDate);

    // 4. 상대 시간 로직 (요청 조건 반영)
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
      // 32일 이상: "X달 전"
      final months = difference.inDays ~/ 30;
      return '$months달 전';
    }
  }
}
