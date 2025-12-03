import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 각 기능별 화면 및 로직 import
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/note/services/note_share_logic.dart';
import 'package:studyshare/community/services/community_share_logic.dart'; // [필수]
import 'package:studyshare/profile/services/profile_logic.dart'; // [필수]

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 MultiProvider를 사용하여 앱 전체에 로직 주입
    return MultiProvider(
      providers: [
        // 1. 노트 로직
        ChangeNotifierProvider(create: (_) => StudyShareLogic()),

        // 2. [필수 추가] 커뮤니티 로직 (MyWriteCommunityScreen 등에서 사용)
        ChangeNotifierProvider(create: (_) => CommunityShareLogic()),

        // 3. [필수 추가] 프로필 로직 (ProfileScreen에서 사용)
        ChangeNotifierProvider(create: (_) => ProfileLogic()),
      ],
      child: MaterialApp(
        title: 'Study Share',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter', // 폰트 설정 (asset에 있다면)
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const MainScreen(), // 앱 시작 시 메인 화면 표시
      ),
    );
  }
}