// lib/community/services/community_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/community_model.dart';

class CommunityService {

  static String get _baseUrl {
    const port = '8081';
    if (kIsWeb) {
      return 'http://localhost:$port/communities';
    } else {
      return 'http://10.0.2.2:$port/communities';
    }
  }

  // 서버 상태 체크
  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      print("❌ 서버 연결 실패 ($_baseUrl): $e");
      return false;
    }
  }

  // 게시글 등록
  Future<bool> registerPost({
    required String title,
    required String content,
    required String category,
    int userId = 1,
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
      print('❌ 게시글 등록 오류: $e');
      return false;
    }
  }

  // 모든 게시글 조회
  Future<List<CommunityModel>> fetchAllPosts(int userId) async {
    try {
      final url = Uri.parse('$_baseUrl?userId=$userId');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => CommunityModel.fromJson(json)).toList();
      }
      print('❌ 전체 조회 실패: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ 전체 조회 오류: $e');
      return [];
    }
  }

  // 💡 [디버깅 추가] 작성글 조회
  Future<List<CommunityModel>> getPostsByUserId(int userId) async {
    final url = '$_baseUrl/user/$userId';
    print("🔍 [요청 시작] 내 작성글 조회 URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      print("🔍 [응답 코드] ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        print("✅ [데이터 수신] ${jsonList.length}개의 게시글 발견");

        return jsonList.map((json) => CommunityModel.fromJson(json)).toList();
      } else {
        print("❌ [서버 응답 오류] 상태 코드: ${response.statusCode}");
        print("❌ [서버 메시지] ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ [앱 내부 오류] 작성글 조회 중 에러 발생: $e");
      return [];
    }
  }

  // 좋아요 요청
  Future<bool> sendLikeRequest(int id, int userId) async {
    try {
      final url = Uri.parse('$_baseUrl/$id/like?userId=$userId');
      final response = await http.post(url);
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // 북마크 요청
  Future<bool> sendBookmarkRequest(int id, int userId) async {
    try {
      final url = Uri.parse('$_baseUrl/$id/bookmark?userId=$userId');
      final response = await http.post(url);
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // 💡 [디버깅 추가] 내가 북마크한 커뮤니티 글 목록
  Future<List<CommunityModel>> fetchBookmarkedCommunities(int userId) async {
    final url = Uri.parse('$_baseUrl/user/$userId/bookmarks');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        print("✅ [북마크] ${list.length}개 발견");
        return list.map((json) => CommunityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ 북마크 목록 조회 실패: $e');
      return [];
    }
  }

  // 💡 [디버깅 추가] 내가 좋아요한 커뮤니티 글 목록
  Future<List<CommunityModel>> fetchLikedCommunities(int userId) async {
    final url = Uri.parse('$_baseUrl/user/$userId/likes');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        print("✅ [좋아요] ${list.length}개 발견");
        return list.map((json) => CommunityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ 좋아요 목록 조회 실패: $e');
      return [];
    }
  }
}