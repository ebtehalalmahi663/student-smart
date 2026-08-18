import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

// نموذج بيانات المقرر المحدث بدعم الحفظ وملفات المحاضرات
class Course {
  final String name;
  final int hours;
  final String labLanguages;
  List<String> files; // قائمة بأسماء/مسارات الملفات المرفوعة

  Course({
    required this.name,
    required this.hours,
    required this.labLanguages,
    List<String>? files,
  }) : files = files ?? [];

  // تحويل البيانات إلى Map للحفظ
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hours': hours,
      'labLanguages': labLanguages,
      'files': files,
    };
  }

  // استرجاع البيانات من Map
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      name: map['name'] ?? '',
      hours: map['hours'] ?? 0,
      labLanguages: map['labLanguages'] ?? '',
      files: List<String>.from(map['files'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Course.fromJson(String source) => Course.fromMap(json.decode(source));
}

class StudentSmartApp extends StatelessWidget {
  const StudentSmartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();

  void _login() {
    if (_idController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CollegeSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text(
                'تطبيق الطالب الذكي',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'الرقم الجامعي / اسم المستخدم',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: const Text('دخول', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة اختيار الكلية والقسم والسمستر
class CollegeSelectionScreen extends StatefulWidget {
  const CollegeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CollegeSelectionScreen> createState() => _CollegeSelectionScreenState();
}

class _CollegeSelectionScreenState extends State<CollegeSelectionScreen> {
  final Map<String, Map<String, dynamic>> collegeData = {
    'كلية علوم الحاسوب وتقانة المعلومات': {
      'departments': ['علوم الحاسوب', 'تقانة المعلومات', 'نظم المعلومات'],
      'semesters': 10,
    },
    'كلية الطب': {
      'departments': ['الطب البشري', 'الطب البيطري', 'التمريض', 'المختبرات الطبية'],
      'semesters': 10,
    },
    'كلية القانون': {
      'departments': ['القانون'],
      'semesters': 8,
    },
    'كلية الاقتصاد': {
      'departments': ['المحاسبة', 'إدارة الأعمال', 'الاقتصاد', 'نظم المعلومات الإدارية'],
      'semesters': 8,
    },
    'كلية التربية': {
      'departments': ['لغة عربية', 'لغة إنجليزية', 'رياضيات', 'فيزياء', 'كيمياء', 'أحياء'],
      'semesters': 8,
    },
  };

  late String selectedCollege;
  late String selectedDepartment;
  late String selectedSemester;

  @override
  void initState() {
    super.initState();
    selectedCollege = collegeData.keys.first;
    selectedDepartment = collegeData[selectedCollege]!['departments'][0];
    selectedSemester = 'السمستر الأول';
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentDepartments = List<String>.from(collegeData[selectedCollege]!['departments']);
    int totalSemesters = collegeData[selectedCollege]!['semesters'];
    List<String> currentSemesters = List.generate(totalSemesters, (i) => 'السمستر ${i + 1}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر الكلية والقسم والسمستر'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الكلية:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCollege,
                items: collegeData.keys.map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCollege = val!;
                    selectedDepartment = collegeData[selectedCollege]!['departments'][0];
                    selectedSemester = 'السمستر الأول';
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('القسم:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedDepartment,
                items: currentDepartments.map((String d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => selectedDepartment = val!),
              ),
              const SizedBox(height: 20),
              const Text('السمستر:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedSemester,
                items: currentSemesters.map((String s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedSemester = val!),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainNavigationScreen(
                          college: selectedCollege,
                          semester: selectedSemester,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: const Text('متابعة', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// شاشة التنقل الرئيسية (تبويبات المقررات، الشات، والاختبارات)
class MainNavigationScreen extends StatefulWidget {
  final String college;
  final String semester;

  const MainNavigationScreen({
    Key? key,
    required this.college,
    required this.semester,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(college: widget.college, semester: widget.semester),
      const ChatScreen(),
      const QuizScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'المقررات'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الشات الذكي'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'قياس المذاكرة'),
        ],
      ),
    );
  }
}

// الشاشة الرئيسية (مواد السمستر - فارغة بزار إضافة مقرر)
class _HomeScreenState extends State<HomeScreen> {
  List<Course> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses(); // تحميل المقررات المحفوظة فور فتح الشاشة
  }

  // دالة تحميل المقررات من ذاكرة الهاتف
  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesData = prefs.getString('saved_courses_${widget.college}_${widget.semester}');
    if (coursesData != null) {
      final List<dynamic> decodedList = json.decode(coursesData);
      setState(() {
        courses = decodedList.map((item) => Course.fromMap(item)).toList();
      });
    }
  }

  // دالة حفظ المقررات في ذاكرة الهاتف
  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(courses.map((c) => c.toMap()).toList());
    await prefs.setString('saved_courses_${widget.college}_${widget.semester}', encodedData);
  }

  // دالة اختيار ورفع ملف محاضرة
  Future<void> _pickAndUploadFile(int courseIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );

    if (result != null && result.files.single.name.isNotEmpty) {
      String fileName = result.files.single.name;
      setState(() {
        courses[courseIndex].files.add(fileName);
      });
      await _saveCourses(); // حفظ التحديث فور رفع الملف

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع الملف: $fileName بنجاح')),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final hoursController = TextEditingController();
    final langController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('إضافة مقرر جديد', textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'اسم المقرر', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'عدد الساعات', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: langController,
                    decoration: const InputDecoration(labelText: 'لغات البرمجة بالمعمل', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    setState(() {
                      courses.add(
                        Course(
                          name: nameController.text.trim(),
                          hours: int.tryParse(hoursController.text) ?? 0,
                          labLanguages: langController.text.trim(),
                        ),
                      );
                    });
                    await _saveCourses(); // حفظ المقرر الجديد دائماً
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.college} - ${widget.semester}', style: const TextStyle(fontSize: 16)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCourseDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مقرر'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('مرحباً: ابتهال', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('القسم: تقانة المعلومات', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'مواد هذا السمستر:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: courses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.folder_open, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              'لا توجد مقررات مضافة بعد.\nاضغط على "إضافة مقرر" للبدء.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ExpansionTile(
                              leading: const Icon(Icons.book, color: Colors.indigo),
                              title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'الساعات: ${course.hours} ${course.labLanguages.isNotEmpty ? "| المعمل: ${course.labLanguages}" : ""}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.file_upload_outlined, color: Colors.indigo),
                                tooltip: 'رفع ملف المحاضرة',
                                onPressed: () => _pickAndUploadFile(index),
                              ),
                              children: [
                                if (course.files.isNotEmpty) ...[
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'الملفات المرفوعة (${course.files.length}):',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  ...course.files.map((file) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                        title: Text(file, style: const TextStyle(fontSize: 13)),
                                      )),
                                ]
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة الشات الذكي
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'user', 'text': _msgController.text.trim()});
        _messages.add({'sender': 'bot', 'text': 'مرحباً! أنا المساعد الذكي لمساعدتك في أداء واجبتك ومذاكرة موادك.'});
      });
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشات الذكي'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('اسأل المساعد الذكي أي سؤال بخصوص موادك!'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['sender'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.indigo : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['text']!,
                              style: TextStyle(color: isUser ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب سؤالك هنا...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.indigo),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// شاشة قياس المذاكرة والاختبارات
class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قياس المذاكرة'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختبارات قصيرة لتحديد المستوى:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.indigo),
                  title: const Text('اختبار تجريبي تقييمي'),
                  subtitle: const Text('عدد الأسئلة: 10 أسئلة'),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                    child: const Text('ابدأ الآن', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
