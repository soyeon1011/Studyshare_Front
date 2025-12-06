// lib/Write_Post/note_writing_screen.dart

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:studyshare/note/services/note_service.dart';
import 'my_write_note_screen.dart'; // [추가] 내 노트 목록 화면 import

class NoteWritingScreen extends StatefulWidget {
  const NoteWritingScreen({super.key});

  @override
  State<NoteWritingScreen> createState() => _NoteWritingScreenState();
}

class _NoteWritingScreenState extends State<NoteWritingScreen> {
  // UI 표시를 위한 과목 데이터
  final Map<String, List<String>> subjectData = {
    '국어': ['국어(공통)', '화법과작문', '독서', '언어와 매체', '문학', '국어(기타)'],
    '수학': ['수학(공통)', '수학 I', '수학 II', '미적분', '확률과 통계', '기하', '경제 수학', '수학(기타)'],
    '영어': ['영어(공통)', '영어독해와 작문', '영어회화', '영어(기타)'],
    '한국사': ['한국사'],
    '사회': ['통합사회', '지리', '역사', '경제', '정치와 법', '윤리', '사회(기타)'],
    '과학': ['통합과학', '물리학', '화학', '생명과학', '지구과학', '과학탐구실험', '과학(기타)'],
  };

  final NoteService _noteService = NoteService();

  // 서버 상태 관련 상태 변수
  bool _isServerConnected = false;
  bool _isLoadingStatus = true;

  // 💡 수정: selectedSubject 초기값을 '국어(공통)'으로 설정
  String selectedCategory = '국어';
  String selectedSubject = '국어(공통)';
  bool _isMenuOpen = false;
  final HtmlEditorController _htmlController = HtmlEditorController();
  final TextEditingController _titleController = TextEditingController();
  String initialHtmlContent = '';

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 서버 상태 확인
    _checkInitialServerStatus();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _htmlController.setText('dddssddddssssss');
      }
    });
  }

  // 서버 상태 확인 로직
  void _checkInitialServerStatus() async {
    final isConnected = await _noteService.checkServerStatus();
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

  /// 노트 등록 버튼 클릭 시 호출되는 함수입니다.
  void _submitNote() async {
    final title = _titleController.text;
    final bodyHtml = await _htmlController.getText();

    // 1. UI 유효성 검사
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    // 서버 연결 상태를 확인하고, 연결이 안 된 경우 등록 중단
    if (!_isServerConnected) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔴 서버에 연결되지 않아 등록할 수 없습니다.')),
      );
      return;
    }

    // UI 로직: 로딩 상태 표시
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('노트 등록 중...')),
    );

    // 2. 비즈니스 로직 위임 (Service 호출)
    // 💡 [핵심 수정] DTO에 맞게 함수 인수를 정리하고 호출합니다.
    final success = await _noteService.registerNote(
      title: title,
      bodyHtml: bodyHtml,
      selectedSubject: selectedSubject,
      userId: 1,
      id2: 1, // Service 함수가 이 인수를 여전히 기대하므로, 값 1을 전달합니다.
    );

    // 3. UI 로직: 결과에 따른 피드백 제공 및 화면 이동
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar(); // 로딩 스낵바 제거
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 노트가 성공적으로 등록되었습니다.')),
        );
        // [수정] 성공 시 내 노트 목록 화면으로 이동 (현재 화면 대체)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 노트 등록에 실패했습니다. 서버/네트워크 오류 확인.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            // 서버 상태 위젯을 위에 추가하기 위해 Column으로 감쌈
            children: [
              _buildServerStatusWidget(), // 서버 상태 표시 위젯
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 120.0, vertical: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. 타이틀
                            const Text('노트 글쓰기',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            Container(
                                width: double.infinity,
                                height: 4,
                                color: const Color(0xFFF4C542)),

                            // 3. 제목 및 과목 선택 줄
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
                                        hintText: '제목을 입력해 주세요',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade400),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),

                                  // 4. 계층형 메뉴 (Nested Menu) - MenuAnchor
                                  MenuAnchor(
                                    controller: MenuController(),
                                    alignmentOffset: const Offset(0, 5),
                                    style: MenuStyle(
                                      backgroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                      elevation: WidgetStateProperty.all(4),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8)),
                                      ),
                                    ),
                                    builder: (BuildContext context,
                                        MenuController controller,
                                        Widget? child) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (controller.isOpen) {
                                              controller.close();
                                              _isMenuOpen = false;
                                            } else {
                                              controller.open();
                                              _isMenuOpen = true;
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: 180,
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                            BorderRadius.circular(4),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  selectedSubject,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: selectedSubject ==
                                                        '선택'
                                                        ? Colors.grey.shade500
                                                        : Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(Icons.arrow_drop_down,
                                                  color: Colors.black54),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    menuChildren:
                                    subjectData.entries.map((entry) {
                                      final String category = entry.key;
                                      final List<String> subjects = entry.value;

                                      return SubmenuButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                          WidgetStateProperty.resolveWith(
                                                  (states) {
                                                if (states.contains(
                                                    WidgetState.hovered)) {
                                                  return Colors.grey.shade100;
                                                }
                                                return Colors.white;
                                              }),
                                        ),
                                        menuChildren: subjects.map((subject) {
                                          return MenuItemButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedCategory = category;
                                                selectedSubject = subject;
                                                _isMenuOpen = false;
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                              WidgetStateProperty
                                                  .resolveWith((states) {
                                                if (states.contains(
                                                    WidgetState.hovered)) {
                                                  return Colors.grey.shade100;
                                                }
                                                return Colors.white;
                                              }),
                                            ),
                                            child: Container(
                                              width: 150,
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: Text(
                                                subject,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                  selectedSubject == subject
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color:
                                                  selectedSubject == subject
                                                      ? Colors.black
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        child: Container(
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                category,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // HTML Editor 적용 영역 (메뉴가 열려있을 때 입력 방지)
                            AbsorbPointer(
                              absorbing: _isMenuOpen,
                              child: Container(
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
                                      toolbarPosition:
                                      ToolbarPosition.aboveEditor,
                                      toolbarType: ToolbarType.nativeScrollable,
                                    ),
                                    otherOptions: const OtherOptions(
                                      height: 480,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                            const Divider(color: Colors.grey, thickness: 0.5),
                            const SizedBox(height: 40),

                            // 6. 작성 팁 (UI 유지)
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('작성 팁',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 25),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(children: const [
                                                Icon(Icons.edit_note,
                                                    size: 22, color: Colors.grey),
                                                SizedBox(width: 8),
                                                Text('구조화된 작성',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16)),
                                              ]),
                                              const SizedBox(height: 15),
                                              _tipText('제목과 소제목을 활용하세요'),
                                              _tipText('번호나 불릿 포인트로 정리하세요'),
                                              _tipText('예제와 설명을 분리하세요'),
                                            ],
                                          )),
                                      const SizedBox(width: 40),
                                      Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(children: const [
                                                Icon(Icons.lightbulb_outline,
                                                    size: 22,
                                                    color: Color(0xFFD4AF37)),
                                                SizedBox(width: 8),
                                                Text('효과적인 학습',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16)),
                                              ]),
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
                            ),
                            const SizedBox(height: 50),

                            // 7. 버튼
                            Center(
                              child: SizedBox(
                                width: 400,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 60,
                                        child: ElevatedButton(
                                          onPressed: _submitNote,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFFF4C542),
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

          // 메뉴가 열려있을 때 다른 위젯 상호작용 방지 (Stack으로 구현)
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuOpen = false;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 서버 상태를 시각적으로 보여주는 위젯
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
}