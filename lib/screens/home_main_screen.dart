import 'package:flutter/material.dart';
// import 'package:study_note/screens/main_screen.dart'; // <--- 문제가 되었던 이 줄을 삭제했습니다!
import 'package:study_note/screens/profile_screen.dart';
import 'package:study_note/screens/search_screen.dart';
import 'package:study_note/widgets/header.dart';
import 'package:study_note/screens/my_write_note_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class NoteCardContent extends StatelessWidget {
  final String title;
  final String subject;
  final String author;
  final String date;
  final String preview;
  final int likes;
  final int comments;

  const NoteCardContent({
    super.key,
    required this.title,
    required this.subject,
    required this.author,
    required this.date,
    required this.preview,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 26, fontFamily: 'Inter', fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black54, width: 1.0),
                ),
                child: Text(subject, style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text(
                '$author · $date',
                style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            preview,
            style: const TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Inter', fontWeight: FontWeight.w500),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 47),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 30),
                  const SizedBox(width: 5),
                  Text(likes.toString(), style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  const SizedBox(width: 15),
                  const Icon(Icons.comment_outlined, color: Colors.black54, size: 25),
                  const SizedBox(width: 5),
                  Text(comments.toString(), style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ],
              ),
              const Icon(Icons.bookmark_border_outlined, size: 30, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppHeader(
              onLogoTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()));
              },
              onSearchTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  SearchScreen()));
              },
              onProfileTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  Profile()));
              },
              onWriteNoteTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWriteNoteScreen()),
                );
              },
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  'assets/images/StudyShare_Image1.png',
                  //width: double.infinity,
                  width: 1440,
                  height: 520,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFE4E4E4),
                        child: Icon(Icons.chevron_left, color: Colors.black, size: 40),
                      ),
                      SizedBox(width: 15),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.pause, color: Colors.black, size: 35),
                      ),
                      SizedBox(width: 15),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFE4E4E4),
                        child: Icon(Icons.chevron_right, color: Colors.black, size: 40),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    const Text('실시간 노트를 확인해 보세요', style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 30),
                    _buildNoteCard(
                      title: '미적분학 기본 개념 정리',
                      subject: '수학',
                      author: '김학생',
                      date: '2025-09-15',
                      preview: '극한, 연솟성, 미분의 기본 개념들을 정리했습니다. 함수의 극한값을 구하는 방법과 연속함수의 조건들을 상세히 성명했습니다.',
                      likes: 25,
                      comments: 9,
                    ),
                    const SizedBox(height: 30),
                    _buildNoteCard(
                      title: '유기화학 반응 메커니즘',
                      subject: '화학',
                      author: '이화학',
                      date: '2025-09-18',
                      preview: 'SN1, SN2 반응 메커니즘에 대한 상세한 설명과 반응속도론적 접근 방법을 다뤘습니다.',
                      likes: 18,
                      comments: 5,
                    ),
                    const SizedBox(height: 30),
                    _buildNoteCard(
                      title: '한국사 근현대사 요약',
                      subject: '역사',
                      author: '박역사',
                      date: '2025-09-20',
                      preview: '일제강점기부터 현대까지의 주요 사건들 정리. 독립운동, 해방, 분단, 한국전쟁 등을 시대순으로 정리했습니다.',
                      likes: 31,
                      comments: 12,
                    ),
                    const SizedBox(height: 100),
                    const Center(child: Text('내 공부 내용을 작성하고 공유해 보세요', style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w700))),
                    const SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCtaItem('assets/images/mainpage_write.png', '나만의 공부 노트를\n작성하세요', '작성하기'),
                        _buildCtaItem('assets/images/mainpage_share.png', '공부한 내용을 커뮤니티에\n공유 해보아요', '공유하기'),
                        _buildCtaItem('assets/images/mainpage_look.png', '자유롭게 이야기하고\n질문해 보세요', '둘러보기'),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildRecommendationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard({
    required String title,
    required String subject,
    required String author,
    required String date,
    required String preview,
    required int likes,
    required int comments,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFCFCFCF)),
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: NoteCardContent(
        title: title,
        subject: subject,
        author: author,
        date: date,
        preview: preview,
        likes: likes,
        comments: comments,
      ),
    );
  }

  Widget _buildCtaItem(String imagePath, String text, String buttonText) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(imagePath, width: 135, height: 149),
          const SizedBox(height: 30),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCB30),
              minimumSize: const Size(164, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Container(
      color: const Color(0xFF9780A9),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 2,
              child: Text(
                '다른 사용자들이 추천하는\n학습 자료를 확인하세요!',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildRecommendationCard('1', '수학 시험\n100점 맞는 법', '수학'),
                      const SizedBox(width: 20),
                      _buildRecommendationCard('2', '영어 단어\n쉽게 외우는 법', '영어'),
                      const SizedBox(width: 20),
                      _buildRecommendationCard('3', '코딩 테스트\n알고리즘 정리', '컴퓨터'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildRecommendationCard('4', '한국사\n핵심 요약 노트', '역사'),
                      const SizedBox(width: 20),
                      _buildRecommendationCard('5', '물리학\n공식 모음', '과학'),
                      const Expanded(child: SizedBox()),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String rank, String title, String subject) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 320,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rank, style: const TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Chip(label: Text(subject), backgroundColor: const Color(0xFFEFEFEF)),
            const Spacer(),
            const Text(
              '극한, 연솟성, 미분의 기본 개념들을 정리했습니다...',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}