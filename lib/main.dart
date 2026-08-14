import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

// -----------------------------------------------------------------------------
// دالة التشغيل الرئيسية وبداية التطبيق
// -----------------------------------------------------------------------------
void main() {
  runApp(const SmartAcademicAssistantApp());
}

class SmartAcademicAssistantApp extends StatelessWidget {
  const SmartAcademicAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'المساعد الأكاديمي الذكي',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // دعم اللغة العربية
      ],
      locale: const Locale('ar', ''),
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// شاشة الإعداد الأولية (تحديد الكلية، القسم، والسمستر)
// -----------------------------------------------------------------------------
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _facultyController = TextEditingController(text: 'الحاسوب وتقانة المعلومات');
  final _departmentController = TextEditingController(text: 'علوم الحاسوب');
  int _selectedSemester = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد المساعد الأكاديمي'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مرحباً بك! يرجى إدخال البيانات الأكاديمية:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'الكلية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'القسم / التخصص',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<int>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'السمستر الحالي',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(10, (index) => index + 1)
                    .map((sem) => DropdownMenuItem(
                          value: sem,
                          child: Text('السمستر $sem'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSemester = value);
                  }
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_facultyController.text.isNotEmpty &&
                        _departmentController.text.isNotEmpty) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainDashboardScreen(
                            faculty: _facultyController.text,
                            department: _departmentController.text,
                            semester: _selectedSemester,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('الدخول للتطبيق', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// -----------------------------------------------------------------------------
// الشاشة الرئيسية الشاملة (تضم 3 شاشات في تبويبات مع حفظ دائم للبيانات)
// -----------------------------------------------------------------------------
class MainDashboardScreen extends StatefulWidget {
  final String faculty;
  final String department;
  final int semester;

  const MainDashboardScreen({
    super.key,
    required this.faculty,
    required this.department,
    required this.semester,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCourses();
  }

  String get _storageKey => 'courses_${widget.faculty}_${widget.department}_${widget.semester}';

  Future<void> _loadSavedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_storageKey);
    if (savedData != null) {
      setState(() {
        List<dynamic> decodedList = jsonDecode(savedData);
        courses = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(courses);
    await prefs.setString(_storageKey, encodedData);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CourseDetailsTab(
        courses: courses,
        onAddCourse: (course) {
          setState(() {
            courses.add(course);
          });
          _saveCourses();
        },
        onAddFile: (courseIndex, fileName) {
          setState(() {
            courses[courseIndex]['files'].add(fileName);
          });
          _saveCourses();
        },
      ),
      SmartChatTab(courses: courses),
      QuizGeneratorTab(courses: courses),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} - سمستر ${widget.semester}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'تفاصيل المقرر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'الشات الذكي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'مقياس المذاكرة',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// التبويب الأول: تفاصيل المقرر (مع اختيار ملفات حقيقية وحفظ)
// -----------------------------------------------------------------------------
class CourseDetailsTab extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Function(Map<String, dynamic>) onAddCourse;
  final Function(int, String) onAddFile;

  const CourseDetailsTab({
    super.key,
    required this.courses,
    required this.onAddCourse,
    required this.onAddFile,
  });

  Future<void> _pickRealFile(BuildContext context, int courseIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        String fileName = result.files.single.name;
        onAddFile(courseIndex, fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إدراج الملف الحقيقي: $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح متصفح الملفات، يرجى التحقق من الصلاحيات.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final hoursController = TextEditingController();
    final labLangController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مقرر جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المقرر'),
              ),
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'عدد الساعات'),
              ),
              TextField(
                controller: labLangController,
                decoration: const InputDecoration(
                    labelText: 'اللغات/الأدوات الخاصة بالمعمل (إن وجدت)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                onAddCourse({
                  'name': nameController.text,
                  'hours': hoursController.text,
                  'lab': labLangController.text.isEmpty ? 'لا يوجد' : labLangController.text,
                  'files': <String>[],
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourseDialog(context),
        label: const Text('إضافة مقرر'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text(
                'لا يوجد مقررات مضافة حالياً.\nاضغط على "إضافة مقرر" للبدء.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final List<dynamic> files = course['files'] ?? [];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              course['name'],
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                            Chip(
                              label: Text('${course['hours']} ساعات'),
                              backgroundColor: Colors.indigo.shade50,
                            ),
                          ],
                        ),
                        Text('أدوات/لغات المعمل: ${course['lab']}',
                            style: const TextStyle(color: Colors.black87)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الملفات والمحاضرات:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: () => _pickRealFile(context, index),
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('إدراج ملف المحاضرة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        files.isEmpty
                            ? const Text('لم يتم إدراج ملفات بعد.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13))
                            : Wrap(
                                spacing: 8,
                                children: files
                                    .map((f) => Chip(
                                          avatar: const Icon(Icons.picture_as_pdf,
                                              size: 16, color: Colors.indigo),
                                          label: Text(f.toString()),
                                        ))
                                    .toList(),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
// -----------------------------------------------------------------------------
// التبويب الثاني: الشات الذكي (SmartChatTab)
// -----------------------------------------------------------------------------
class SmartChatTab extends StatefulWidget {
  final List<Map<String, dynamic>> courses;

  const SmartChatTab({super.key, required this.courses});

  @override
  State<SmartChatTab> createState() => _SmartChatTabState();
}

class _SmartChatTabState extends State<SmartChatTab> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final userMsg = _controller.text;
    setState(() {
      messages.add({'sender': 'user', 'text': userMsg});
      messages.add({
        'sender': 'ai',
        'text': 'أنا مساعدك الأكاديمي الذكي. قرأت استفسارك حول ($userMsg)، وستتم الإجابة بناءً على المقررات المرفقة عندك!'
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Text('ابدأ المحادثة وسؤال المساعد الذكي عن أي جزئية.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final isUser = messages[index]['sender'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.indigo.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(messages[index]['text'] ?? ''),
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
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'اكتب سؤالك هنا...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.indigo),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// التبويب الثالث: مولد الاختبارات (QuizGeneratorTab)
// -----------------------------------------------------------------------------
class QuizGeneratorTab extends StatefulWidget {
  final List<Map<String, dynamic>> courses;

  const QuizGeneratorTab({super.key, required this.courses});

  @override
  State<QuizGeneratorTab> createState() => _QuizGeneratorTabState();
}

class _QuizGeneratorTabState extends State<QuizGeneratorTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 80, color: Colors.indigo),
            const SizedBox(height: 15),
            const Text(
              'مقياس المذاكرة والاختبارات الذكية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.courses.isEmpty
                  ? 'يرجى إضافة مقررات أولاً للبدء في توليد الأسئلة.'
                  : 'عدد المقررات المتاحة لتوليد الأسئلة: ${widget.courses.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: widget.courses.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري إنشاء اختبار تجريبي للمقررات...'),
                        ),
                      );
                    },
              child: const Text('توليد اختبار تجريبي'),
            ),
          ],
        ),
      ),
    );
  }
}
