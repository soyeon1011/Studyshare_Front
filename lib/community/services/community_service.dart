import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/community_model.dart'; // 커뮤니티 모델 임포트

class CommunityService {

  // 💡 [수정] 백엔드 포트 8081과 /communities 엔드포인트 사용
  static String get _baseUrl {
    const port = '8081';
    if (kIsWeb) {
      return 'http://localhost:$port/communities';
    } else {
      // 안드로이드 에뮬레이터는 10.0.2.2 사용
      return 'http://10.0.2.2:$port/communities';
    }
  }

  // 서버 상태 체크
  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      print("서버 연결 실패 ($_baseUrl): $e");
      return false;
    }
  }

  // 모든 게시글 조회 (GET /communities)
  Future<List<CommunityModel>> fetchAllPosts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => CommunityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('네트워크 통신 오류 (커뮤니티 조회): $e');
      return [];
    }
  }

  // 💡 [핵심 추가] 이 메서드가 없어서 오류가 발생했습니다.
  Future<List<CommunityModel>> getPostsByUserId(int userId) async {
    try {
      // URL 예시: http://localhost:8081/communities/user/1
      final url = '$_baseUrl/user/$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => CommunityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('네트워크 통신 오류 (사용자 게시글 조회): $e');
      return [];
    }
  }

  // 게시글 등록 (POST /communities)
  Future<bool> registerPost({
    required String title,
    required String content,
    required String category,
    int userId = 1, // 로그인 구현 전 임시 ID
  }) async {
    final postData = {
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(postData),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('게시글 등록 오류: $e');
      return false;
    }
  }
}