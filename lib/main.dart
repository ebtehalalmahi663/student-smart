import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? savedName = prefs.getString('user_name');
  final String? savedCollege = prefs.getString('user_college');
  final String? savedDept = prefs.getString('user_department');
  final String? savedSemester = prefs.getString('user_semester');

  final bool isAlreadyLoggedIn = savedName != null && savedName.isNotEmpty;

  runApp(SmartAcademicAssistantApp(
    isLoggedIn: isAlreadyLoggedIn,
    savedName: savedName ?? '',
    savedCollege: savedCollege ?? '',
    savedDept: savedDept ?? '',
    savedSemester: savedSemester ?? '',
  ));
}

class SmartAcademicAssistantApp extends StatelessWidget {
  final bool isLoggedIn;
  final String savedName;
  final String savedCollege;
  final String savedDept;
  final String savedSemester;

  const SmartAcademicAssistantApp({
    super.key,
    required this.isLoggedIn,
    required this.savedName,
    required this.savedCollege,
    required this.savedDept,
    required this.savedSemester,
  });

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
      home: isLoggedIn
          ? MainNavigationScreen(
              userName: savedName,
              college: savedCollege,
              department: savedDept,
              semester: savedSemester,
            )
          : const WelcomeScreen(),
    );
  }
}
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Map<String, Map<String, dynamic>> _collegeData = {
    'كلية علوم الحاسوب وتقانة المعلومات': {
      'departments': ['تقانة المعلومات', 'نظم المعلومات', 'علوم الحاسوب'],
      'semestersCount': 10,
    },
    'كلية الطب': {
      'departments': ['طب بشري', 'طب بيطري', 'تمريض', 'مختبرات'],
      'semestersCount': 10,
    },
    'كلية القانون': {
      'departments': ['عام'],
      'semestersCount': 8,
    },
    'كلية الاقتصاد': {
      'departments': ['نظم معلومات', 'محاسبة', 'اقتصاد', 'اداره'],
      'semestersCount': 8,
    },
    'كلية التربيه': {
      'departments': [
        'لغة عربيه',
        'لغة انجليزيه',
        'فيزياء ورياضيات',
        'كيمياء واحياء',
        'علم نفس',
        'تربيه خاصه'
      ],
      'semestersCount': 8,
    },
  };

  late String _selectedCollege;
  late String _selectedDepartment;
  late String _selectedSemester;

  @override
  void initState() {
    super.initState();
    _selectedCollege = _collegeData.keys.first;
    _selectedDepartment = _collegeData[_selectedCollege]!['departments'].first;
    _selectedSemester = 'السمستر 1';
  }

  void _onCollegeChanged(String? newCollege) {
    if (newCollege != null) {
      setState(() {
        _selectedCollege = newCollege;
        _selectedDepartment = _collegeData[newCollege]!['departments'].first;
        _selectedSemester = 'السمستر 1';
      });
    }
  }

  Future<void> _saveUserData(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_college', _selectedCollege);
    await prefs.setString('user_department', _selectedDepartment);
    await prefs.setString('user_semester', _selectedSemester);
  }

  void _submitAndProceed() async {
    if (_formKey.currentState!.validate()) {
      final userName = _nameController.text.trim();
      await _saveUserData(userName);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(
            userName: userName,
            college: _selectedCollege,
            department: _selectedDepartment,
            semester: _selectedSemester,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentDepartments =
        List<String>.from(_collegeData[_selectedCollege]!['departments']);
    int currentSemestersCount = _collegeData[_selectedCollege]!['semestersCount'];
    List<String> currentSemesters =
        List.generate(currentSemestersCount, (i) => 'السمستر ${i + 1}');

    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 60, color: Colors.indigo),
                      const SizedBox(height: 10),
                      const Text(
                        'مرحباً بك في المساعد الأكاديمي',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'يرجى إدخال بياناتك لمتابعة دراستك',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال اسمك أولاً';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'الاسم الكامل',
                          hintText: 'أدخل اسمك هنا',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _selectedCollege,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'الكلية',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.account_balance),
                        ),
                        items: _collegeData.keys.map((college) {
                          return DropdownMenuItem(
                            value: college,
                            child: Text(college, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: _onCollegeChanged,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'القسم',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: currentDepartments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDepartment = val);
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'الفصل الدراسي (السمستر)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.timeline),
                        ),
                        items: currentSemesters.map((sem) {
                          return DropdownMenuItem(
                            value: sem,
                            child: Text(sem, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSemester = val);
                        },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitAndProceed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text(
                            'دخول التطبيق',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ==========================================
// شاشة التنقل الرئيسية والمقررات
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  final String userName;
  final String college;
  final String department;
  final String semester;

  const MainNavigationScreen({
    super.key,
    required this.userName,
    required this.college,
    required this.department,
    required this.semester,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        userName: widget.userName,
        college: widget.college,
        department: widget.department,
        semester: widget.semester,
      ),
      SmartChatScreen(semester: widget.semester),
      QuizScreen(semester: widget.semester),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'المقررات'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الشات الذكي'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'قياس المذاكرة'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final String college;
  final String department;
  final String semester;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.college,
    required this.department,
    required this.semester,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, List<String>> _coursesData = {
    'السمستر 1': ['مقدمة حاسوب', 'ریاضيات 1', 'لغة إنجليزية 1', 'المهارات الأكاديمية'],
    'السمستر 2': ['برمجة 1 (Java)', 'فيزياء حاسوب', 'رياضيات 2', 'إحصاء احتمالات'],
    'السمستر 3': ['برمجة 2 (OOP)', 'تراكيب بيانات', 'تصميم منطقي', 'رياضيات متقطعة'],
    'السمستر 4': ['خوارزميات', 'قواعد بيانات', 'هندسة سوفتوير', 'معمارية الحاسوب'],
    'السمستر 5': ['ذكاء اصطناعي', 'شبكات حاسوب', 'أنظمة تشغيل', 'تحليل نظم'],
    'السمستر 6': ['تعلم آلة', 'أمن معلومات', 'تطوير ويب', 'مشروع 1'],
    'السمستر 7': ['معالجة لغة طبيعية', 'رؤية حاسوبية', 'حوسبة سحابية', 'تطوير تطبيقات'],
    'السمستر 8': ['تنقيب بيانات', 'أنظمة وزعة', 'إدارة مشاريع', 'أخلاقيات مهنة'],
    'السمستر 9': ['مشروع تخرج 1', 'تدريب ميداني', 'حوسبة موجهة'],
    'السمستر 10': ['مشروع تخرج 2', 'مناقشة علمية', 'موضوعات متقدمة'],
  };

  final Map<String, List<PlatformFile>> _uploadedPdfs = {};

  Future<void> _pickPDF(String courseName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _uploadedPdfs.putIfAbsent(courseName, () => []).add(result.files.first);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع ملف "${result.files.first.name}" بنجاح!')),
        );
      }
    }
  }

  void _openPdfFile(PlatformFile file) {
    if (file.path != null) {
      OpenFilex.open(file.path!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الملف مباشرة')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentCourses = _coursesData[widget.semester] ?? ['مادة عامة 1', 'مادة عامة 2'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.college} - ${widget.semester}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.indigo, size: 30),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Text('مرحباً: ${widget.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('القسم: ${widget.department}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('مواد هذا السمستر:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentCourses.length,
              itemBuilder: (context, index) {
                String course = currentCourses[index];
                List<PlatformFile> files = _uploadedPdfs[course] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.book, color: Colors.indigo),
                    title: Text(course, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload_file, color: Colors.indigo),
                      onPressed: () => _pickPDF(course),
                    ),
                    children: [
                      if (files.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('لا توجد ملفات مرفوعة لهذه المادة', style: TextStyle(color: Colors.grey)),
                        )
                      else
                        ...files.map(
                          (file) => ListTile(
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            title: Text(file.name),
                            subtitle: Text('${(file.size / 1024).toStringAsFixed(1)} KB'),
                            onTap: () => _openPdfFile(file),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// الشات الذكي
// ==========================================
class SmartChatScreen extends StatefulWidget {
  final String semester;
  const SmartChatScreen({super.key, required this.semester});

  @override
  State<SmartChatScreen> createState() => _SmartChatScreenState();
}

class _SmartChatScreenState extends State<SmartChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    String query = _chatController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _isLoading = true;
    });
    _chatController.clear();

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY_HERE',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "أنت مساعد أكاديمي ذكي تدرس في ${widget.semester}."},
            {"role": "user", "content": query}
          ]
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        String aiReply = data['choices'][0]['message']['content'];
        setState(() => _messages.add({'sender': 'ai', 'text': aiReply}));
      } else {
        setState(() => _messages.add({'sender': 'ai', 'text': 'حدث خطأ في الاتصال بالسيرفر.'}));
      }
    } catch (e) {
      setState(() => _messages.add({'sender': 'ai', 'text': 'تأكد من الاتصال بالإنترنت.'}));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الشات الذكي الأكاديمي'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index]['text'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(hintText: 'اسأل عن أي مفهوم دراسي...', border: OutlineInputBorder()),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.indigo), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// قياس المذاكرة والاختبارات
// ==========================================
class QuizScreen extends StatefulWidget {
  final String semester;
  const QuizScreen({super.key, required this.semester});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'ما هو المفهوم الأساسي للبرمجة كائنية التوجه (OOP)؟',
      'options': ['الوراثة والتغليف', 'التجميع والتفكيك', 'المصفوفات الثابتة', 'لا شيء مما سبق'],
      'answer': 0
    },
    {
      'question': 'أي مما يلي يستخدم لإدارة قاعدة البيانات؟',
      'options': ['HTML', 'SQL', 'CSS', 'Flutter'],
      'answer': 1
    }
  ];

  final Map<int, int> _selectedAnswers = {};
  bool _showScore = false;
  int _score = 0;

  void _calculateScore() {
    int scoreCounter = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['answer']) {
        scoreCounter++;
      }
    }

    setState(() {
      _score = scoreCounter;
      _showScore = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نتيجة الاختبار', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _score == _questions.length ? Icons.emoji_events : Icons.stars,
              color: Colors.amber,
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              'حصلت على $_score من أصل ${_questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _selectedAnswers.clear();
      _showScore = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قياس المستوى الأكاديمي'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetQuiz,
            tooltip: 'إعادة الاختبار',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, qIndex) {
                var q = _questions[qIndex];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text(
                          '${qIndex + 1}. ${q['question']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          q['options'].length,
                          (oIndex) {
                            bool isCorrect = q['answer'] == oIndex;
                            bool isSelected = _selectedAnswers[qIndex] == oIndex;

                            Color tileColor = Colors.transparent;
                            if (_showScore) {
                              if (isCorrect) {
                                tileColor = Colors.green.shade50;
                              } else if (isSelected && !isCorrect) {
                                tileColor = Colors.red.shade50;
                              }
                            }

                            return Container(
                              color: tileColor,
                              child: RadioListTile<int>(
                                title: Text(q['options'][oIndex]),
                                value: oIndex,
                                groupValue: _selectedAnswers[qIndex],
                                activeColor: Colors.indigo,
                                onChanged: _showScore
                                    ? null
                                    : (int? value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedAnswers[qIndex] = value;
                                          });
                                        }
                                      },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedAnswers.length < _questions.length || _showScore
                    ? null
                    : _calculateScore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'تسليم وإظهار النتيجة',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

