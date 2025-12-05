// lib/comment/services/comment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb; // 웹 여부 확인
import '../models/comment_model.dart';

class CommentService {

  // 💡 [수정] 다른 서비스들과 똑같이 8081 포트로 설정
  static String get _baseUrl {
    const port = '8081';
    if (kIsWeb) {
      return 'http://localhost:$port/comments';
    } else {
      // 안드로이드 에뮬레이터
      return 'http://10.0.2.2:$port/comments';
    }
  }

  // 1. 댓글 작성
  Future<bool> writeComment({int? noteId, int? communityId, required String content, int userId = 1}) async {
    final url = Uri.parse(_baseUrl);

    final Map<String, dynamic> bodyData = {
      'content': content,
      'user_id': userId, // (임시)
    };

    // 노트인지 커뮤니티인지 구분해서 ID 넣기
    if (noteId != null) bodyData['noteId'] = noteId;
    if (communityId != null) bodyData['communityId'] = communityId;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'}, // UTF-8 추가
        body: jsonEncode(bodyData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('댓글 작성 에러: $e');
      return false;
    }
  }

  // 2. 댓글 목록 조회
  // type: "note" 또는 "community"
  Future<List<CommentModel>> getComments(String type, int id) async {
    // 예: http://localhost:8081/comments/note/1
    final url = Uri.parse('$_baseUrl/$type/$id');

    try {
      final response = await http.get(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'} // 한글 깨짐 방지
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('댓글 조회 에러: $e');
      return [];
    }
  }
}