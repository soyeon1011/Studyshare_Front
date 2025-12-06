// lib/community/screens/community_writing_screen.dart

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:studyshare/community/services/community_service.dart';
import 'my_write_community_screen.dart'; // [필수] 목록 화면 import

class CommunityWritingScreen extends StatefulWidget {
  const CommunityWritingScreen({super.key});

  @override
  State<CommunityWritingScreen> createState() => _CommunityWritingScreenState();
}

class _CommunityWritingScreenState extends State<CommunityWritingScreen> {
  final CommunityService _communityService = CommunityService();

  bool _isServerConnected = false;
  bool _isLoadingStatus = true;
  final String selectedCategory = '자유';

  final HtmlEditorController _htmlController = HtmlEditorController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkInitialServerStatus();
  }

  void _checkInitialServerStatus() async {
    final isConnected = await _communityService.checkServerStatus();
    if (mounted) {
      setState(() {
        _isServerConnected = isConnected;
        _isLoadingStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitPost() async {
    final title = _titleController.text;
    final content = await _htmlController.getText();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
      return;
    }

    if (!_isServerConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔴 서버 미연결')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시글 등록 중...')));

    final success = await _communityService.registerPost(
      title: title,
      content: content,
      category: selectedCategory,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 등록 완료')));

        // 💡 [핵심] 작성 완료 후 목록 화면으로 이동 (새로고침 효과)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyWriteCommunityScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ 등록 실패')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('자유 게시글 작성', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          if (!_isServerConnected && !_isLoadingStatus)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(8), color: Colors.red.withOpacity(0.1),
              child: const Center(child: Text('🔴 서버 연결 실패', style: TextStyle(color: Colors.red))),
            ),

          Expanded(
            // 여기 패딩은 입력 폼이므로 적당히 유지
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('제목', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '제목을 입력해 주세요',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          height: 400,
                          child: HtmlEditor(
                            key: UniqueKey(),
                            controller: _htmlController,
                            htmlEditorOptions: const HtmlEditorOptions(
                              hint: '내용을 입력하세요...',
                              initialText: '',
                            ),
                            htmlToolbarOptions: const HtmlToolbarOptions(
                              toolbarPosition: ToolbarPosition.aboveEditor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _submitPost,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF4A908),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('등록하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('취소', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}