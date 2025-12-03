// lib/Write_Post/note_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:studyshare/note/models/note_model.dart';

// 과목 이름과 DB ID 매핑 데이터
final Map<String, int> subjectToId = {
  '국어(공통)': 1, '화법과작문': 2, '독서': 3, '언어와 매체': 4, '문학': 5, '국어(기타)': 6,
  '수학(공통)': 7, '수학 I': 8, '수학 II': 9, '미적분': 10, '확률과 통계': 11, '기하': 12, '경제 수학': 13, '수학(기타)': 14,
  '영어(공통)': 15, '영어독해와 작문': 16, '영어회화': 17, '영어(기타)': 18,
  '한국사': 19, '통합사회': 20, '지리': 21, '역사': 22, '경제': 23, '정치와 법': 24, '윤리': 25, '사회(기타)': 26,
  '통합과학': 27, '물리학': 28, '화학': 29, '생명과학': 30, '지구과학': 31, '과학탐구실험': 32, '과학(기타)': 33,
};

class NoteService {

  static String get _baseUrl {
    const port = '8081'; // 백엔드 포트 8081

    if (kIsWeb) {
      return 'http://localhost:$port/notes';
    } else {
      return 'http://10.0.2.2:$port/notes';
    }
  }

  /// 서버의 상태를 확인합니다.
  Future<bool> checkServerStatus() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("서버 연결 실패 ($_baseUrl): $e");
      return false;
    }
  }

  /// 노트 등록 API (POST /notes)
  Future<bool> registerNote({
    required String title,
    required String bodyHtml,
    required String selectedSubject,
    required int userId,
    required int id2,
  }) async {
    final subjectId = subjectToId[selectedSubject] ?? 0;
    const fileUrl = '';

    final postData = {
      'title': title,
      'noteSubjectId': subjectId,
      'noteContent': bodyHtml,
      'noteFileUrl': fileUrl,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('서버 응답 실패: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('네트워크 통신 오류: $e');
      return false;
    }
  }


  /// 모든 노트 조회 (GET /notes)
  Future<List<NoteModel>> fetchAllNotes() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> notesJson =
        jsonDecode(utf8.decode(response.bodyBytes));

        return notesJson
            .map((json) {
          try {
            return NoteModel.fromJson(json);
          } catch (e) {
            print('JSON 변환 오류: $e');
            return null;
          }
        })
            .whereType<NoteModel>()
            .toList();
      } else {
        print('노트 조회 실패: ${response.statusCode}');
        return [];
      }
    } on TimeoutException {
      print('네트워크 요청 시간 초과');
      return [];
    } catch (e) {
      print('네트워크 통신 오류 (조회): $e');
      return [];
    }
  }

  // ⬇️⬇️⬇️ [추가된 함수] ⬇️⬇️⬇️

  /// 특정 사용자가 작성한 노트 조회 (GET /notes/user/{userId})
  Future<List<NoteModel>> getNotesByUserId(int userId) async {
    try {
      // 백엔드 엔드포인트: /notes/user/{userId}
      final url = Uri.parse('$_baseUrl/user/$userId');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> notesJson =
        jsonDecode(utf8.decode(response.bodyBytes));

        return notesJson
            .map((json) => NoteModel.fromJson(json))
            .toList();
      } else {
        print('유저별 노트 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('네트워크 통신 오류 (유저별 조회): $e');
      return [];
    }
  }
}