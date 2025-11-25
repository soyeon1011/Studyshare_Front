// auth_check.dart

import 'package:flutter/material.dart';
import 'Login_UI.dart'; // ⭐️ Login_UI.dart 파일 임포트
import 'AuthService.dart'; // AuthService 임포트

// ⚠️ 임시 메인 화면 (실제 앱의 메인 화면으로 변경하세요)
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // 로그아웃 버튼 로직
  Future<void> _kakaoLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.kakaoLogout();

    // 로그아웃 후 로그인 화면으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메인 화면')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '로그인 성공! 사이트 접속 상태 유지 중.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _kakaoLogout(context),
              child: const Text('카카오 로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

// ⭐️ 앱 시작 시 로그인 상태를 확인하는 UI 위젯
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(); // AuthService 인스턴스 생성

    return FutureBuilder<bool>(
      future: authService.checkKakaoLoginStatus(), // AuthService의 메서드 호출
      builder: (context, snapshot) {
        // 로딩 중 (상태 확인 중)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 상태 확인 완료 후
        if (snapshot.data == true) {
          // 로그인 상태: 메인 화면 표시
          return const MainScreen();
        } else {
          // 로그아웃 상태: 로그인 화면 표시
          return const LoginScreen();
        }
      },
    );
  }
}
