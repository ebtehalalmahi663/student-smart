import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SmartAssistantApp());
}

class SmartAssistantApp extends StatelessWidget {
  const SmartAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المساعد الذكي للمراجعة',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', ''),
      supportedLocales: const [Locale('ar', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const MainSelectionScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// الشاشة الأولى: اختيار الكلية، القسم، والسمستر
// -----------------------------------------------------------------------------
class MainSelectionScreen extends StatefulWidget {
  const MainSelectionScreen({super.key});

  @override
  State<MainSelectionScreen> createState() => _MainSelectionScreenState();
}

class _MainSelectionScreenState extends State<MainSelectionScreen> {
  // بيانات الكليات والأقسام والسمسترات
  final Map<String, Map<String, dynamic>> facultiesData = {
    'كلية علوم الحاسوب وتقانة المعلومات': {
      'semesters': 10,
      'departments': ['علوم الحاسوب', 'تقانة المعلومات', 'نظم المعلومات']
    },
    'كلية الطب': {
      'semesters': 10,
      'departments': ['المختبرات', 'الطب البيطري', 'الطب البشري', 'تمريض']
    },
    'كلية التربيه': {
      'semesters': 8,
      'departments': [
        'تربيه كيمياء واحياء',
        'تربيه لغه عربيه',
        'تربيه فيزياء ورياضيات',
        'تربيه انجليزي',
        'تربيه خاصه',
        'تربيه علم نفس'
      ]
    },
    'كلية الاقتصاد': {
      'semesters': 8,
      'departments': ['محاسبه', 'اقتصاد', 'نظم معلومات', 'إداره']
    },
    'كلية القانون': {
      'semesters': 8,
      'departments': ['القانون العام', 'القانون الخاص', 'الشريعة والقانون']
    },
  };

  String? selectedFaculty;
  String? selectedDepartment;
  int? selectedSemester;

  @override
  void initState() {
    super.initState();
    _checkSavedState();
  }

  // التنبيه عند فتح التطبيق واسترجاع آخر موضع للمذاكرة
  Future<void> _checkSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final faculty = prefs.getString('last_faculty');
    final dept = prefs.getString('last_dept');
    final sem = prefs.getInt('last_sem');
    final course = prefs.getString('last_course') ?? 'مقدمة في البرمجة';
    final lec = prefs.getInt('last_lec') ?? 3;
    final slide = prefs.getInt('last_slide') ?? 14;

    if (faculty != null && dept != null && sem != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.history, color: Colors.indigo),
              SizedBox(width: 8),
              Text('تنبيه متابعة المذاكرة'),
            ],
          ),
          content: Text(
            'أهلاً بك مجدداً! أنتا كنت واقف في $faculty - قسم $dept - السمستر $sem - مقرر $course - المحاضرة $lec - في الاسلايد رقم $slide.',
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً، فهمت'),
            )
          ],
        ),
      );
    }
  }

  void _saveCurrentSelection() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedFaculty != null) prefs.setString('last_faculty', selectedFaculty!);
    if (selectedDepartment != null) prefs.setString('last_dept', selectedDepartment!);
    if (selectedSemester != null) prefs.setInt('last_sem', selectedSemester!);
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableDepartments = selectedFaculty != null
        ? List<String>.from(facultiesData[selectedFaculty]!['departments'])
        : [];

    int maxSemesters = selectedFaculty != null
        ? facultiesData[selectedFaculty]!['semesters']
        : 8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعد الذكي للمراجعة الجامعية'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.school, size: 60, color: Colors.indigo),
                      const SizedBox(height: 10),
                      const Text(
                        'اختر مسارك الأكاديمي',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                      const Divider(height: 30),

                      // اختيار الكلية
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'الكلية',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                        value: selectedFaculty,
                        items: facultiesData.keys.map((String faculty) {
                          return DropdownMenuItem(
                              value: faculty, child: Text(faculty));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedFaculty = val;
                            selectedDepartment = null;
                            selectedSemester = null;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // اختيار القسم
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'القسم',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.class_),
                        ),
                        value: selectedDepartment,
                        items: availableDepartments.map((String dept) {
                          return DropdownMenuItem(
                              value: dept, child: Text(dept));
                        }).toList(),
                        onChanged: selectedFaculty == null
                            ? null
                            : (val) {
                                setState(() {
                                  selectedDepartment = val;
                                });
                              },
                      ),
                      const SizedBox(height: 15),

                      // اختيار السمستر
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'السمستر (الفصل الدراسي)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timeline),
                        ),
                        value: selectedSemester,
                        items: List.generate(maxSemesters, (index) => index + 1)
                            .map((int sem) {
                          return DropdownMenuItem(
                              value: sem, child: Text('السمستر $sem'));
                        }).toList(),
                        onChanged: selectedDepartment == null
                            ? null
                            : (val) {
                                setState(() {
                                  selectedSemester = val;
                                });
                              },
                      ),
                      const SizedBox(height: 25),

                      // زر عرض المقررات
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.menu_book),
                          label: const Text('عرض المقررات',
                              style: TextStyle(fontSize: 18)),
                          onPressed: (selectedFaculty != null &&
                                  selectedDepartment != null &&
                                  selectedSemester != null)
                              ? () {
                                  _saveCurrentSelection();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainDashboardScreen(
                                        faculty: selectedFaculty!,
                                        department: selectedDepartment!,
                                        semester: selectedSemester!,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
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
// -----------------------------------------------------------------------------
// الشاشة الرئيسية الشاملة (تضم 3 شاشات في تبويبات)
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

  // قائمة المقررات المضافة
  List<Map<String, dynamic>> courses = [];

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CourseDetailsTab(
        courses: courses,
        onAddCourse: (course) {
          setState(() {
            courses.add(course);
          });
        },
        onAddFile: (courseIndex, fileName) {
          setState(() {
            courses[courseIndex]['files'].add(fileName);
          });
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
// التبويب الأول: تفاصيل المقرر
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
                    labelText: 'اللغات/الأدوات الخاصة بالمعمل'),
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
                  'lab': labLangController.text,
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
                final List<String> files = course['files'];
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
                        if (course['lab'].toString().isNotEmpty)
                          Text('أدوات/لغات المعمل: ${course['lab']}',
                              style: const TextStyle(color: Colors.black87)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الملفات والمحاضرات المدرجة:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: () {
                                String newFileName =
                                    'محاضرة_${files.length + 1}.pdf';
                                onAddFile(index, newFileName);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('تم إدراج $newFileName')),
                                );
                              },
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
                                              size: 16),
                                          label: Text(f),
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
// التبويب الثاني: شات الإجابة الذكية من المحاضرات
// -----------------------------------------------------------------------------
class SmartChatTab extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  const SmartChatTab({super.key, required this.courses});

  @override
  State<SmartChatTab> createState() => _SmartChatTabState();
}

class _SmartChatTabState extends State<SmartChatTab> {
  final List<Map<String, String>> messages = [
    {
      'sender': 'bot',
      'text':
          'أهلاً بك! أنا مساعدك الذكي. قم بتقديم أي سؤال وسأجيبك مباشرة بناءً على المحاضرات والملفات التي قمت بإدراجها.'
    }
  ];

  final TextEditingController textController = TextEditingController();

  void _sendMessage() {
    if (textController.text.trim().isEmpty) return;

    final userQuery = textController.text;
    setState(() {
      messages.add({'sender': 'user', 'text': userQuery});
      textController.clear();
    });

    // محاكاة إجابة المساعد الذكي
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        messages.add({
          'sender': 'bot',
          'text':
              'بناءً على ملفات المحاضرة المرفوعة الإجابة على سؤالك ("$userQuery") هي: هذه النقاط الموضحة في الشريحة رقم 5 تبيّن المفاهيم الأساسية للموضوع بشكل مبسط.'
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isBot = msg['sender'] == 'bot';
              return Align(
                alignment:
                    isBot ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBot ? Colors.indigo.shade50 : Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(
                      color: isBot ? Colors.black87 : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'اكتب سؤالك عن المحاضرة هنا...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.indigo),
                onPressed: _sendMessage,
              )
            ],
          ),
        )
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// التبويب الثالث: مقياس المذاكرة وتكوين الاختبار
// -----------------------------------------------------------------------------
class QuizGeneratorTab extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  const QuizGeneratorTab({super.key, required this.courses});

  @override
  State<QuizGeneratorTab> createState() => _QuizGeneratorTabState();
}

class _QuizGeneratorTabState extends State<QuizGeneratorTab> {
  int lecturesCount = 3;
  int questionsCount = 5;
  String questionType = 'اختيار من متعدد';

  void _generateAndStartQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveQuizScreen(
          questionsCount: questionsCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.assessment, color: Colors.indigo, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'مقياس المذاكرة واختبار الفهم',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 30),

              // عدد المحاضرات
              Text('عدد المحاضرات المفترض تضمينها: $lecturesCount'),
              Slider(
                value: lecturesCount.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$lecturesCount',
                onChanged: (val) => setState(() => lecturesCount = val.toInt()),
              ),
              const SizedBox(height: 15),

              // عدد الأسئلة
              Text('عدد الأسئلة المطلوبة: $questionsCount'),
              Slider(
                value: questionsCount.toDouble(),
                min: 3,
                max: 20,
                divisions: 17,
                label: '$questionsCount',
                onChanged: (val) =>
                    setState(() => questionsCount = val.toInt()),
              ),
              const SizedBox(height: 15),

              // نوع الأسئلة
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'نوع الأسئلة',
                  border: OutlineInputBorder(),
                ),
                value: questionType,
                items: ['اختيار من متعدد', 'صح أم خطأ', 'أسئلة مقالية قصيرة']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => questionType = val!),
              ),
              const SizedBox(height: 25),

              // زر تكوين الاختبار
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('تكوين الاختبار الآن',
                      style: TextStyle(fontSize: 18)),
                  onPressed: widget.courses.isEmpty
                      ? null
                      : _generateAndStartQuiz,
                ),
              ),
              if (widget.courses.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    '* يرجى إضافة مقرر دراسي واحد على الأقل في الشاشة الأولى لتتمكن من إنشاء الاختبار.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
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
// شاشة أداء الاختبار
// -----------------------------------------------------------------------------
class ActiveQuizScreen extends StatefulWidget {
  final int questionsCount;
  const ActiveQuizScreen({super.key, required this.questionsCount});

  @override
  State<ActiveQuizScreen> createState() => _ActiveQuizScreenState();
}

class _ActiveQuizScreenState extends State<ActiveQuizScreen> {
  late List<int?> selectedAnswers;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.questionsCount, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاختبار التجريبي'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: widget.questionsCount,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سؤال ${index + 1}: ما هو المفهوم الأساسي في المحاضرة رقم ${(index % 3) + 1}؟',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  RadioListTile<int>(
                    title: const Text('الخيار الأول الصحيح للمفهوم'),
                    value: 0,
                    groupValue: selectedAnswers[index],
                    onChanged: (val) =>
                        setState(() => selectedAnswers[index] = val),
                  ),
                  RadioListTile<int>(
                    title: const Text('الخيار الثاني غير الدقيق'),
                    value: 1,
                    groupValue: selectedAnswers[index],
                    onChanged: (val) =>
                        setState(() => selectedAnswers[index] = val),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () {
            // تقديم الاختبار وعرض شاشة التقرير
            int correctCount =
                selectedAnswers.where((ans) => ans == 0).length;
            double percentage = (correctCount / widget.questionsCount) * 100;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuizReportScreen(
                  totalQuestions: widget.questionsCount,
                  correctCount: correctCount,
                  percentage: percentage,
                ),
              ),
            );
          },
          child: const Text('تم (إنهاء الاختبار)',
              style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// شاشة تقرير أداء الاختبار والنتائج
// -----------------------------------------------------------------------------
class QuizReportScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctCount;
  final double percentage;

  const QuizReportScreen({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير نتيجة الاختبار'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 70, color: Colors.orange),
                    const SizedBox(height: 10),
                    Text(
                      'نسبة النجاح: ${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'الإجابات الصحيحة: $correctCount من أصل $totalQuestions',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تفاصيل الإجابات النموذجية:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: totalQuestions,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text('السؤال رقم ${index + 1}'),
                    subtitle: const Text('الإجابة الصحيحة: الخيار الأول الصحيح للمفهوم'),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة للقائمة الرئيسية'),
            )
          ],
        ),
      ),
    );
  }
}
