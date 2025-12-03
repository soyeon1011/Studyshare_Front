// studyshare/lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // [추가] Provider import
import 'package:studyshare/community/services/community_share_logic.dart';
import 'package:studyshare/login/Login_UI.dart';
import 'package:studyshare/login/auth_check.dart';
import 'package:studyshare/main/screens/home_main_screen.dart';
import 'package:studyshare/note/screens/my_note_screen.dart';
import 'package:studyshare/note/screens/my_write_note_screen.dart';
import 'package:studyshare/note/services/note_share_logic.dart'; // [추가] Logic import
// import 'package:studyshare/main/screens/home_main_screen.dart'; // 주석 처리
// import 'package:studyshare/note/screens/my_note_screen.dart'; // 주석 처리

void main() {
  runApp(
    // 💡 [수정] MultiProvider로 앱을 감싸서 Logic을 등록합니다!
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyShareLogic()),

        ChangeNotifierProvider(create: (_) => CommunityShareLogic()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: MyWriteNoteScreen(), // 이미 Provider를 등록했으므로 화면은 그대로
      home: MainScreen(),
    );
  }
}