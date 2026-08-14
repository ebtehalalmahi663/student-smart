import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SmartAcademicAssistantApp());
}

class SmartAcademicAssistantApp extends StatelessWidget {
  const SmartAcademicAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المساعد الأكاديمي الذكي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = const [
    StudyProgressScreen(),
    SmartChatScreen(),
    CourseDetailsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'مقياس المذاكرة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'الشات الذكي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'تفاصيل المقرر',
          ),
        ],
      ),
    );
  }
}
class SmartChatScreen extends StatefulWidget {
  const SmartChatScreen({super.key});

  @override
  State<SmartChatScreen> createState() => _SmartChatScreenState();
}

class _SmartChatScreenState extends State<SmartChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'مرحباً بك! حدد المقرر الدراسي من القائمة بالأعلى واسألني أي سؤال يدور حول محتوى المحاضرات والملفات التي أدرجتها.'
    }
  ];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // ✅ تم دمج المفتاح ورابط Gemini 1.5 Flash مباشرة بدون متغيرات لضمان عدم حدوث خطأ 401 أو Undefined apiKey
      final Uri url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AQ.Ab8RN6L2NMyfy7EZKalu8iGnJ2j8y0EqHE3_QtZbCVnloMfiTQ',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': text}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'لم أتمكن من الحصول على إجابة.';
        setState(() {
          _messages.add({'sender': 'ai', 'text': replyText});
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': 'حدث خطأ أثناء التواصل مع الذكاء الاصطناعي (${response.statusCode}).'
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': 'تعذر الاتصال بالشبكة لتقييم المحتوى:\n$e'
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقانة المعلومات - سمستر 6'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.indigo.shade50,
            child: Row(
              children: const [
                Icon(Icons.auto_awesome, color: Colors.indigo),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اسأل من ملفات: الذكاء الاصطناعي (3 ملفات...)',
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.indigo),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo.shade700 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: _sendMessage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'اكتب سؤالك حول المحاضرات والملفات...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class StudyProgressScreen extends StatelessWidget {
  const StudyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقانة المعلومات - سمستر 6'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'خيارات مقياس المذاكرة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),

            // كروت الاختبارات السريعة
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    title: 'اختبار تجريبي: الذكاء الاصطناعي',
                    subtitle: '4/10 المنجز',
                    icon: Icons.quiz_outlined,
                    badgeText: 'نشط',
                    progress: 0.4,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOptionCard(
                    title: 'اختبار سريع: الفصل الأول',
                    subtitle: '6/10 المنجز',
                    icon: Icons.assignment_outlined,
                    badgeText: 'مكتمل',
                    progress: 0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // خطة الدراسة الأسبوعية
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Chip(
                          label: Text('نشط', style: TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: Colors.green,
                        ),
                        Text(
                          'خطة دراسة الأسبوع الحالي',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'متابعة ساعات المذاكرة والمحاضرات المتبقية لهذا الأسبوع.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.indigo.shade50,
                      color: Colors.indigo,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // بنك الأسئلة والمراجعة
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'بنك الأسئلة الشامل',
                    icon: Icons.menu_book_outlined,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionTile(
                    title: 'مراجعة المحاضرات',
                    icon: Icons.rate_review_outlined,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // قائمة المتصدرين / ملخص الإنجاز
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.leaderboard, color: Colors.indigo, size: 30),
                title: Text(
                  'ملخص التقدم الكلي',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'أنجزت 65% من الإختبارات والمراجعات لهذا الفصل',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required double progress,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(color: Colors.indigo, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(icon, color: Colors.indigo),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: color),
        ],
      ),
    );
  }
}
class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المقرر'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'تفاصيل المقرر والمحاضرات المرفوعة',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
