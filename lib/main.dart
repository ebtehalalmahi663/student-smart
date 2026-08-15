import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package0:open_filex/open_filex.dart';
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
      home: const WelcomeScreen(),
    );
  }
}

// ==========================================
// 1. واجهة الاختيار والترحيب (تظهر أولاً)
// ==========================================
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // خريطة الكليات والأقسام وعدد السمسترات الخاصة بكل كلية
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

  // تحديث الأقسام والسمسترات عند تغيير الكلية
  void _onCollegeChanged(String? newCollege) {
    if (newCollege != null) {
      setState(() {
        _selectedCollege = newCollege;
        _selectedDepartment = _collegeData[newCollege]!['departments'].first;
        _selectedSemester = 'السمستر 1';
      });
    }
  }

  void _submitAndProceed() {
    if (_formKey.currentState!.validate()) {
      final userName = _nameController.text.trim();
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
    List<String> currentDepartments = List<String>.from(_collegeData[_selectedCollege]!['departments']);
    int currentSemestersCount = _collegeData[_selectedCollege]!['semestersCount'];
    List<String> currentSemesters = List.generate(currentSemestersCount, (i) => 'السمستر ${i + 1}');

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

                      // إدخال الاسم
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

                      // اختيار الكلية
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

                      // اختيار القسم
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

                      // اختيار السمستر
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

                      // زر الدخول
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
// الشاشة الرئيسية لربط الشاشات الثلاث
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
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      StudyProgressScreen(
        userName: widget.userName,
        college: widget.college,
        department: widget.department,
        semester: widget.semester,
      ),
      SmartChatScreen(userName: widget.userName),
      const CourseDetailsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
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

// ==========================================
// 2. شاشة مقياس المذاكرة (تكوين الاختبار)
// ==========================================
class StudyProgressScreen extends StatefulWidget {
  final String userName;
  final String college;
  final String department;
  final String semester;

  const StudyProgressScreen({
    super.key,
    required this.userName,
    required this.college,
    required this.department,
    required this.semester,
  });

  @override
  State<StudyProgressScreen> createState() => _StudyProgressScreenState();
}

class _StudyProgressScreenState extends State<StudyProgressScreen> {
  String? _selectedLecture = 'جميع المحاضرات المضافة';
  int _questionCount = 10;
  String _questionType = 'اختيار من متعدد (MCQ)';

  final List<String> _availableLectures = [
    'جميع المحاضرات المضافة',
    'المحاضرة 1: مقدمة في المقرر',
    'المحاضرة 2: المفاهيم الأساسية',
    'المحاضرة 3: التطبيقات العملية',
  ];

  final List<int> _questionCountOptions = [5, 10, 15, 20, 30];
  final List<String> _questionTypes = [
    'اختيار من متعدد (MCQ)',
    'صح أو خطأ',
    'أسئلة مقالية قصيرة',
    'مزيج من جميع الأنواع',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.college} - ${widget.semester}'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة التنبيه المخصصة بأسماء الزول
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.indigo),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'أهلاً بك يا ${widget.userName}! (قسم ${widget.department}) جاهز لاختبار معلوماتك اليوم؟',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'تكوين اختبار جديد',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.quiz, color: Colors.indigo),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text('اختر المحاضرة / الملف:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedLecture,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        fillColor: Colors.grey.shade50,
                        filled: true,
                      ),
                      items: _availableLectures.map((lecture) {
                        return DropdownMenuItem(
                          value: lecture,
                          child: Text(lecture, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedLecture = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('نوع الأسئلة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _questionType,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  fillColor: Colors.grey.shade50,
                                  filled: true,
                                ),
                                items: _questionTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type, style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _questionType = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('عدد الأسئلة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                value: _questionCount,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  fillColor: Colors.grey.shade50,
                                  filled: true,
                                ),
                                items: _questionCountOptions.map((count) {
                                  return DropdownMenuItem(
                                    value: count,
                                    child: Text('$count أسئلة', style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _questionCount = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('يا ${widget.userName}، جاري إنشاء اختبار مكون من $_questionCount سؤال...'),
                              backgroundColor: Colors.indigo,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.auto_awesome, color: Colors.white),
                        label: const Text(
                          'تكوين الامتحان الآن',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.bar_chart, color: Colors.indigo, size: 30),
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
// ==========================================
// 3. شاشة الشات الذكي
// ==========================================
class SmartChatScreen extends StatefulWidget {
  final String userName;

  const SmartChatScreen({super.key, required this.userName});

  @override
  State<SmartChatScreen> createState() => _SmartChatScreenState();
}

class _SmartChatScreenState extends State<SmartChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, String>> _messages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'sender': 'ai',
        'text': 'مرحباً بك يا ${widget.userName}! أنا مساعدك الأكاديمي الذكي. يمكنك الاستفسار عن محتوى أي مقرر أو ملف قم بإدراجه.'
      }
    ];
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    try {
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
            'text': 'عذراً يا ${widget.userName}، حدث خطأ أثناء الاتصال بالذكاء الاصطناعي.'
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': 'تعذر الاتصال بالشبكة:\n$e'
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
        title: const Text('المساعد الذكي'),
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
                    'الاستفسار من ملفات المحاضرات المرفقة',
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
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
                      hintText: 'اكتب سؤالك هنا...',
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

// ==========================================
// 4. شاشة تفاصيل المقرر وإدراج المحاضرات
// ==========================================
class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();
  final _labLangController = TextEditingController();

  bool _isCourseAdded = false;
  String _addedCourseName = "";
  String _addedCourseHours = "";
  String _addedCourseLang = "";

  final List<PlatformFile> _lectureFiles = [];

  Future<void> _pickLectureFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _lectureFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء اختيار الملف: $e')),
      );
    }
  }

  Future<void> _openFile(PlatformFile file) async {
    if (file.path != null) {
      await OpenFilex.open(file.path!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الملف (المسار غير صالح)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة و تفاصيل المقرر'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'بيانات المقرر الأكاديمي',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'اسم المقرر',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _labLangController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'لغة المعمل (إن وجدت)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'عدد الساعات',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء كتابة اسم المقرر أولاً')),
                  );
                  return;
                }
                setState(() {
                  _isCourseAdded = true;
                  _addedCourseName = _nameController.text.trim();
                  _addedCourseHours = _hoursController.text.trim();
                  _addedCourseLang = _labLangController.text.trim();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ بيانات المقرر بنجاح!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('حفظ وإضافة المقرر', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 25),
            const Divider(thickness: 1.5),
            if (_isCourseAdded) ...[
              Card(
                color: Colors.indigo.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('المقرر الحالي: $_addedCourseName', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 4),
                      Text('عدد الساعات: ${_addedCourseHours.isEmpty ? "غير محدد" : _addedCourseHours}  |  لغة المعمل: ${_addedCourseLang.isEmpty ? "لا يوجد" : _addedCourseLang}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _pickLectureFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade100,
                  foregroundColor: Colors.indigo.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('إضافة ملف محاضرات من الجهاز'),
              ),
              const SizedBox(height: 15),
              const Text(
                'ملفات المحاضرات المضافة:',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _lectureFiles.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'لم يتم إضافة أي ملفات بعد. اضغط على زر الإضافة أعلاه.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _lectureFiles.length,
                      itemBuilder: (context, index) {
                        final file = _lectureFiles[index];
                        final sizeInMb = (file.size / (1024 * 1024)).toStringAsFixed(2);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _lectureFiles.removeAt(index);
                                });
                              },
                            ),
                            title: Text(
                              file.name,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '$sizeInMb MB',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                            onTap: () => _openFile(file),
                          ),
                        );
                      },
                    ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'يرجى إدخال بيانات المقرر وحفظه أولاً لتتمكن من إضافة ملفات المحاضرات.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
