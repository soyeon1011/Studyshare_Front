// lib/services/comment_service.dart

import 'dart:convert';
import 'dart:io'; // Platform 확인용
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';

class CommentService {
  // 안드로이드 에뮬레이터: 'http://10.0.2.2:8080'
  // iOS 시뮬레이터: 'http://localhost:8080'
  final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8080/comments'
      : 'http://localhost:8080/comments';

  // 1. 댓글 작성 (POST)
  // noteId나 communityId 중 하나만 값을 넣고, 나머지는 null로 보내면 됩니다.
  Future<bool> writeComment({int? noteId, int? communityId, required String content}) async {
    final url = Uri.parse(baseUrl);

    // 보낼 데이터 (JSON)
    final Map<String, dynamic> bodyData = {
      'content': content,
    };
    if (noteId != null) bodyData['noteId'] = noteId;
    if (communityId != null) bodyData['communityId'] = communityId;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 201) {
        return true; // 성공
      } else {
        print('댓글 작성 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('에러 발생: $e');
      return false;
    }
  }

  // 2. 댓글 목록 조회 (GET)
  // type: "note" 또는 "community"
  Future<List<Comment>> getComments(String type, int id) async {
    // 예: /comments/note/1 또는 /comments/community/1
    final url = Uri.parse('$baseUrl/$type/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 한글 깨짐 방지 (utf8.decode)
        final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => Comment.fromJson(json)).toList();
      } else {
        print('댓글 조회 실패');
        return [];
      }
    } catch (e) {
      print('에러 발생: $e');
      return [];
    }
  }
}