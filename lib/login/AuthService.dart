// AuthService.dart

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AuthService {
  // 로그인 상태 확인 및 토큰 자동 갱신 시도
  Future<bool> checkKakaoLoginStatus() async {
    try {
      // 유효한 토큰이 있으면 로그인 상태 유지, 만료 시 자동 갱신 시도
      await UserApi.instance.accessTokenInfo();
      print('로그인 상태 유지 확인: 유효한 토큰 존재');
      return true;
    } catch (error) {
      // 토큰 부재 또는 갱신 실패
      print('로그인 상태 유지 실패: $error');
      return false;
    }
  }

  // 카카오 로그아웃 기능
  Future<void> kakaoLogout() async {
    try {
      await UserApi.instance.logout();
      print('카카오 로그아웃 성공');
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }
}
