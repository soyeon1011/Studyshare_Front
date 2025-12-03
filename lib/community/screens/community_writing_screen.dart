import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:studyshare/community/services/community_service.dart';

class CommunityWritingScreen extends StatefulWidget {
  const CommunityWritingScreen({super.key});

  @override
  State<CommunityWritingScreen> createState() => _CommunityWritingScreenState();
}

class _CommunityWritingScreenState extends State<CommunityWritingScreen> {

  final CommunityService _communityService = CommunityService();

  // --- 상태 변수 ---
  bool _isServerConnected = false;
  bool _isLoadingStatus = true;

  // 💡 [수정] 카테고리 관련 상태 변수와 메뉴 컨트롤러 제거
  final HtmlEditorController _htmlController = HtmlEditorController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkInitialServerStatus();
  }

  // 서버 상태 확인 로직
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

  /// 게시글 등록 버튼 클릭 시 호출되는 함수입니다.
  void _submitPost() async {
    final title = _titleController.text;
    final content = await _htmlController.getText();

    // 1. UI 유효성 검사
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    // 서버 연결 상태 확인
    if (!_isServerConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔴 서버에 연결되지 않아 등록할 수 없습니다.')),
      );
      return;
    }

    // UI 로직: 로딩 상태 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시글 등록 중...')),
    );

    // 2. 비즈니스 로직 위임 (Service 호출)
    // 💡 [핵심 수정] 하드코딩된 단일 카테고리 '자유' 전송
    final success = await _communityService.registerPost(
      title: title,
      content: content,
      category: '자유', // ⬅️ 단일 카테고리 '자유'로 고정
    );

    // 3. UI 로직: 결과에 따른 피드백 제공
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 게시글이 성공적으로 등록되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 게시글 등록에 실패했습니다. 서버/네트워크 오류 확인.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('자유 게시글 작성'), // 💡 타이틀 수정
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text('등록하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildServerStatusWidget(), // 서버 상태 표시 위젯
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. 타이틀
                            const Text('자유 게시판 글쓰기', // 💡 타이틀 수정
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            Container(
                                width: double.infinity,
                                height: 4,
                                color: const Color(0xFFF4A908)),

                            // 2. 제목 입력 줄 (카테고리 메뉴 제거)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300))),
                              child: Row(
                                children: [
                                  const SizedBox(width: 20),
                                  const Text('제목',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 40),

                                  // 제목 입력창
                                  Expanded(
                                    child: TextField(
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        hintText: '제목을 입력해 주세요 (자유 게시판)',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade400),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // HTML Editor 적용 영역
                            Container(
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SizedBox(
                                height: 480,
                                child: HtmlEditor(
                                  key: UniqueKey(),
                                  controller: _htmlController,
                                  htmlEditorOptions: const HtmlEditorOptions(
                                    hint: '내용을 입력하세요...',
                                    initialText: '',
                                    autoAdjustHeight: false,
                                  ),
                                  htmlToolbarOptions:
                                  const HtmlToolbarOptions(
                                    toolbarPosition: ToolbarPosition.aboveEditor,
                                    toolbarType: ToolbarType.nativeScrollable,
                                  ),
                                  otherOptions: const OtherOptions(
                                    height: 480,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                            const Divider(color: Colors.grey, thickness: 0.5),
                            const SizedBox(height: 40),

                            // 작성 팁 섹션
                            _buildTipSection(),

                            const SizedBox(height: 50),

                            // 등록/취소 버튼
                            Center(
                              child: SizedBox(
                                width: 400,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 60,
                                        child: ElevatedButton(
                                          onPressed: _submitPost,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFFF4A908),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(0)),
                                          ),
                                          child: const Text('등록하기',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: SizedBox(
                                        height: 60,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFFAAAAAA),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(0)),
                                          ),
                                          child: const Text('취소',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Stack으로 메뉴 관련 코드를 관리하지 않으므로 제거
        ],
      ),
    );
  }

  // Helper Widget for Tip Section
  Widget _buildTipSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('작성 팁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tipTextRow(Icons.edit_note, '구조화된 작성'),
                  const SizedBox(height: 15),
                  _tipText('제목과 소제목을 활용하세요'),
                  _tipText('번호나 불릿 포인트로 정리하세요'),
                  _tipText('예제와 설명을 분리하세요'),
                ],
              )),
              const SizedBox(width: 40),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tipTextRow(Icons.lightbulb_outline, '효과적인 학습', color: const Color(0xFFD4AF37)),
                  const SizedBox(height: 15),
                  _tipText('핵심 개념을 명확히 하세요'),
                  _tipText('실제 예제를 포함하세요'),
                  _tipText('자신만의 이해 방법을 추가하세요'),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget for Tip Text Row
  Widget _tipTextRow(IconData icon, String text, {Color color = Colors.grey}) {
    return Row(children: [
      Icon(icon, size: 22, color: color),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    ]);
  }

  // Helper Widget for Tip Text
  Widget _tipText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 15, height: 1.2)),
          const SizedBox(width: 5),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 15, height: 1.2))),
        ],
      ),
    );
  }

  // 서버 상태를 시각적으로 보여주는 위젯 (이전 코드에서 복사)
  Widget _buildServerStatusWidget() {
    Color color;
    String message;
    IconData icon;

    if (_isLoadingStatus) {
      color = Colors.blueGrey;
      message = '서버 연결 상태 확인 중...';
      icon = Icons.sync;
    } else if (_isServerConnected) {
      color = Colors.green.shade700;
      message = '🟢 서버 연결됨: API 호출 준비 완료 (localhost:8081)';
      icon = Icons.check_circle;
    } else {
      color = Colors.red.shade700;
      message = '🔴 서버 연결 실패: Spring Boot 서버(8081)를 실행하세요.';
      icon = Icons.warning;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: color.withOpacity(0.1),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}