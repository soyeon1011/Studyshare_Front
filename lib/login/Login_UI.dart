// Login_UI.dart

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'auth_check.dart'; // MainScreen 사용을 위해 임포트

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ⭐️ Flutter Web용 카카오 로그인 함수 (디버그 추적 코드 추가됨)
  Future<void> _signInWithKakaoWeb() async {
    const String redirectUri = 'http://localhost:8080/';

    print('--- 1. 카카오 로그인 시도 시작 ---');

    try {
      // 1. 인증 코드 요청 (여기서 팝업/새 창이 떠야 합니다)
      final authCode = await AuthCodeClient.instance.authorizeWithNewScopes(
        redirectUri: redirectUri,
        scopes: [],
      );

      print('--- 2. 인증 코드 획득 성공 (팝업에서 돌아옴) ---');

      // 2. 인증 코드로 토큰 발급
      final OAuthToken token = await AuthApi.instance.issueAccessToken(
        authCode: authCode,
      );

      print('--- 3. 액세스 토큰 발급 성공 ---');

      // 3. 토큰 설정 (로컬 스토리지에 저장)
      TokenManagerProvider.instance.manager.setToken(token);

      print('--- 4. 토큰 로컬 스토리지 저장 완료 ---');

      // 4. 사용자 정보 가져오기 (로그인 성공 확인)
      await UserApi.instance.me();

      print('--- 5. 사용자 정보 획득 및 로그인 최종 성공 ---');

      // ⭐️ 로그인 성공 후 메인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (error) {
      // 에러 발생 시, 어느 단계에서 멈췄는지 확인
      print('--- ❌ 카카오 로그인 처리 중 예외 발생 ---');
      print('발생 오류: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패! 브라우저 환경 및 설정 (${error.toString()})')),
      );
    }
  }

  Widget _buildLoginForm(BuildContext context) {
    const Color buttonColor = Color(0xFFFFC107);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 중앙 로고
          Image.asset('StudyShare_Logo.png', height: 60),
          const SizedBox(height: 50),

          // ID/이메일 입력 필드 (더미)
          _buildInputField('스터디쉐어 ID (아이디 또는 이메일)'),
          const SizedBox(height: 10),
          _buildInputField('비밀번호', obscureText: true),
          const SizedBox(height: 10),

          // 로그인 상태 유지 체크박스 (더미)
          Row(
            children: [
              SizedBox(
                height: 20.0,
                width: 20.0,
                child: Checkbox(
                  value: false,
                  onChanged: (val) {},
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '로그인 상태 유지',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 스터디쉐어 ID 로그인 버튼 (더미)
          ElevatedButton(
            onPressed: () {}, // ⭐️ 더미 기능
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 0,
            ),
            child: const Text(
              '스터디쉐어 ID 로그인',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 링크 (더미)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLinkText('ID찾기'),
              _buildLinkDivider(),
              _buildLinkText('비밀번호 찾기'),
              _buildLinkDivider(),
              _buildLinkText('회원가입'),
            ],
          ),
          const SizedBox(height: 40),

          // '또는' 구분선
          _buildOrDivider(),
          const SizedBox(height: 40),

          // ⭐️ 카카오 로그인 버튼: 활성 기능
          TextButton(
            onPressed: _signInWithKakaoWeb, // ⭐️ 카카오 로그인 함수 연결
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/kakao_logo.png', height: 20),
                const SizedBox(width: 8),
                const Text(
                  'kakao 로그인',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // (이하 기존 UI 위젯 함수들 유지)
  Widget _buildInputField(String hint, {bool obscureText = false}) {
    /* ... */
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: Colors.black54, width: 1.0),
        ),
      ),
    );
  }

  Widget _buildLinkText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          decoration: TextDecoration.none,
          decorationColor: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLinkDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 1.0,
      height: 12.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildOrDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('또는', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildLoginForm(context)],
            ),
          ),
        ),
      ),
    );
  }
}
