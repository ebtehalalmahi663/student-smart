import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package0:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // لقراءة ملفات الـ PDF
import 'package:http/http.dart' as http; // للاتصال بـ Gemini API

// ⚠️ حطي مفتاح Gemini API بتاعك هنا
const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

// -----------------------------------------------------------------------------
// 1. نماذج البيانات (CourseFile & Course & ChatMessage)
// -----------------------------------------------------------------------------
class CourseFile {
  String name;
  String path;

  CourseFile({required this.name, required this.path});

  Map<String, dynamic> toJson() => {'name': name, 'path': path};

  factory CourseFile.fromJson(Map<String, dynamic> json) => CourseFile(
        name: json['name'],
        path: json['path'],
      );
}

class Course {
  String id;
  String name;
  int creditHours;
  String labTools;
  List<CourseFile> files;

  Course({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.labTools,
    List<CourseFile>? files,
  }) : files = files ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'creditHours': creditHours,
        'labTools': labTools,
        'files': files.map((f) => f.toJson()).toList(),
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'],
        name: json['name'],
        creditHours: json['creditHours'],
        labTools: json['labTools'],
        files: json['files'] != null
            ? (json['files'] as List)
                .map((item) => CourseFile.fromJson(item))
                .toList()
            : [],
      );
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? sourceCourse;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.sourceCourse,
  });
}

// -----------------------------------------------------------------------------
// دالة استخراج النص الحقيقي من ملفات PDF
// -----------------------------------------------------------------------------
Future<String> extractTextFromFiles(List<CourseFile> files) async {
  StringBuffer fullText = StringBuffer();

  for (var file in files) {
    try {
      if (file.path.endsWith('.pdf')) {
        final File pdfFile = File(file.path);
        final List<int> bytes = await pdfFile.readAsBytes();
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        String text = PdfTextExtractor(document).extractText();
        document.dispose();

        fullText.writeln('--- محتوى الملف: ${file.name} ---');
        fullText.writeln(text);
      } else {
        fullText.writeln('--- ملف: ${file.name} (اسم الملف كمرجع) ---');
      }
    } catch (e) {
      debugPrint('خطأ أثناء قراءة الملف ${file.name}: $e');
    }
  }

  return fullText.toString();
}

// -----------------------------------------------------------------------------
// دالة إرسال النص والسؤال لـ Gemini API للحصول على إجابة حقيقية
// -----------------------------------------------------------------------------
Future<String> getGeminiResponse(String prompt, String contextText) async {
  if (geminiApiKey == 'YOUR_GEMINI_API_KEY' || geminiApiKey.isEmpty) {
    return 'يرجى إدخال مفتاح Gemini API الخاص بك في الكود للبدء في توليد الإجابات الذكية.';
  }

  final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey');

  final systemInstruction =
      'أنت مساعد أكاديمي ذكي. أجب على سؤال الطالب بناءً على المحتوى المستخرج من ملفات المحاضرات التالية فقط بأسلوب واضح ودقيق باللغة العربية:\n\n$contextText';

  final body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': '$systemInstruction\n\nسؤال الطالب: $prompt'}
        ]
      }
    ]
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final reply = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      return reply;
    } else {
      return 'حدث خطأ أثناء التواصل مع الذكاء الاصطناعي (${response.statusCode}).';
    }
  } catch (e) {
    return 'تعذر الاتصال بالشبكة لتقييم المحتوى: $e';
  }
}

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
      supportedLocales: const [Locale('ar', '')],
      locale: const Locale('ar', ''),
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const SetupScreen(),
    );
  }
}
// -----------------------------------------------------------------------------
// 2. شاشة الإعداد الأولية (نفس التصميم تماماً بدون أي تغيير)
// -----------------------------------------------------------------------------
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final Map<String, Map<String, dynamic>> academicData = {
    'علوم الحاسوب وتقانة المعلومات': {
      'semesters': 10,
      'departments': ['تقانة المعلومات', 'نظم المعلومات', 'علوم الحاسوب'],
    },
    'الطب': {
      'semesters': 10,
      'departments': ['المختبرات', 'الطب البشري', 'الطب البيطري', 'التمريض'],
    },
    'الاقتصاد': {
      'semesters': 8,
      'departments': ['محاسبة', 'اقتصاد', 'إدارة', 'نظم معلومات'],
    },
    'التربية': {
      'semesters': 8,
      'departments': [
        'لغة عربية',
        'كيمياء وأحياء',
        'فيزياء ورياضيات',
        'لغة إنجليزية',
        'تربية خاصة'
      ],
    },
  };

  String? selectedFaculty;
  String? selectedDepartment;
  int selectedSemester = 1;

  @override
  void initState() {
    super.initState();
    selectedFaculty = academicData.keys.first;
    selectedDepartment = academicData[selectedFaculty]!['departments'].first;
  }

  @override
  Widget build(BuildContext context) {
    final currentFacultyInfo = academicData[selectedFaculty]!;
    final List<String> availableDepartments =
        List<String>.from(currentFacultyInfo['departments']);
    final int maxSemesters = currentFacultyInfo['semesters'];

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
                'مرحباً بك! يرجى اختيار البيانات الأكاديمية:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                value: selectedFaculty,
                decoration: const InputDecoration(
                  labelText: 'الكلية',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school, color: Colors.indigo),
                ),
                items: academicData.keys
                    .map((fac) => DropdownMenuItem(value: fac, child: Text(fac)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFaculty = value;
                      selectedDepartment =
                          academicData[value]!['departments'].first;
                      selectedSemester = 1;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'القسم / التخصص',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.domain, color: Colors.indigo),
                ),
                items: availableDepartments
                    .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                    .toList(),
                onChanged: (value) => setState(() => selectedDepartment = value),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: selectedSemester > maxSemesters ? 1 : selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'السمستر الحالي',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.format_list_numbered, color: Colors.indigo),
                ),
                items: List.generate(maxSemesters, (index) => index + 1)
                    .map((sem) => DropdownMenuItem(
                          value: sem,
                          child: Text('السمستر $sem'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedSemester = value);
                },
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (selectedFaculty != null && selectedDepartment != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainDashboardScreen(
                            faculty: selectedFaculty!,
                            department: selectedDepartment!,
                            semester: selectedSemester,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'الدخول للتطبيق',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
// 3. الشاشة الرئيسية والشات الذي يجيب إجابة حقيقية من المحتوى
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
  List<Course> courses = [];
  Course? selectedChatCourse;
  bool _isLoadingResponse = false;
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'مرحباً بك! حدد المقرر الدراسي من القائمة بالأعلى واسألني أي سؤال يدور حول محتوى المحاضرات والملفات التي أدرجتها.',
      isUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saveData = prefs.getString('courses_data');
    if (saveData != null) {
      final List<dynamic> decodedList = jsonDecode(saveData);
      setState(() {
        courses = decodedList.map((item) => Course.fromJson(item)).toList();
        if (courses.isNotEmpty) {
          selectedChatCourse = courses.first;
        }
      });
    }
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(courses.map((c) => c.toJson()).toList());
    await prefs.setString('courses_data', encodedData);
  }

  Future<void> _pickFileForCourse(Course course) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.path != null) {
            course.files.add(CourseFile(name: file.name, path: file.path!));
          }
        }
      });
      await _saveCourses();
    }
  }

  Future<void> _deleteCourseFile(Course course, int index) async {
    setState(() {
      course.files.removeAt(index);
    });
    await _saveCourses();
  }

  Future<void> _openCourseFile(String filePath) async {
    if (filePath.isNotEmpty) {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر فتح الملف: ${result.message}')),
        );
      }
    }
  }

  // إرسال السؤال وقراءة الملفات الحقيقية للإجابة
  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty || _isLoadingResponse) return;

    final query = _chatController.text;
    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true));
      _chatController.clear();
      _isLoadingResponse = true;
    });

    if (selectedChatCourse == null) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'يرجى اختيار المقرر الدراسي أولاً من القائمة بالأعلى.',
          isUser: false,
        ));
        _isLoadingResponse = false;
      });
      return;
    }

    if (selectedChatCourse!.files.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'لم تقمي بإدراج أي ملفات لمقرر "${selectedChatCourse!.name}" بعد.',
          isUser: false,
          sourceCourse: selectedChatCourse!.name,
        ));
        _isLoadingResponse = false;
      });
      return;
    }

    // 1. استخراج النصوص الحقيقية من ملفات المقرر
    String extractedContext =
        await extractTextFromFiles(selectedChatCourse!.files);

    // 2. طلب الإجابة من الذكاء الاصطناعي بناءً على محتوى الملفات
    String aiAnswer = await getGeminiResponse(query, extractedContext);

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(
        text: aiAnswer,
        isUser: false,
        sourceCourse: selectedChatCourse!.name,
      ));
      _isLoadingResponse = false;
    });
  }

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final hoursController = TextEditingController();
    final labController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                controller: labController,
                decoration: const InputDecoration(
                    labelText: 'أدوات/لغات المعمل (مثال: لا يوجد)'),
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
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final newCourse = Course(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    creditHours: int.tryParse(hoursController.text) ?? 3,
                    labTools: labController.text.isEmpty
                        ? 'لا يوجد'
                        : labController.text,
                  );
                  courses.add(newCourse);
                  selectedChatCourse ??= newCourse;
                });
                _saveCourses();
                Navigator.pop(context);
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
      appBar: AppBar(
        title: Text('${widget.department} - سمستر ${widget.semester}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildCourseDetailsTab(),
          _buildSmartChatTab(),
          const Center(child: Text('مقياس المذاكرة (قريباً)')),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddCourseDialog,
              backgroundColor: Colors.indigo,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('إضافة مقرر',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'تفاصيل المقرر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'الشات الذكي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'مقياس المذاكرة',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDetailsTab() {
    if (courses.isEmpty) {
      return const Center(
        child: Text('لا توجد مقررات مضافة بعد. اضغط على "+ إضافة مقرر"'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${course.creditHours} ساعات'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('أدوات/لغات المعمل: ${course.labTools}'),
                const Divider(height: 25),
                Row(
                  children: [
                    const Text('الملفات والمحاضرات: '),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _pickFileForCourse(course),
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('إدراج ملف المحاضرة'),
                    ),
                  ],
                ),
                if (course.files.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(course.files.length, (fileIndex) {
                      final file = course.files[fileIndex];
                      return InputChip(
                        avatar: const Icon(Icons.picture_as_pdf,
                            color: Colors.indigo, size: 18),
                        label: Text(
                          file.name,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        onPressed: () => _openCourseFile(file.path),
                        onDeleted: () => _deleteCourseFile(course, fileIndex),
                        deleteIcon: const Icon(Icons.cancel,
                            size: 18, color: Colors.red),
                        backgroundColor: Colors.grey.shade100,
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmartChatTab() {
    return Column(
      children: [
        Container(
          color: Colors.indigo.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.indigo),
              const SizedBox(width: 10),
              const Text('اسأل من ملفات:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<Course>(
                  isExpanded: true,
                  value: selectedChatCourse,
                  hint: const Text('اختر المقرر'),
                  underline: const SizedBox(),
                  items: courses.map((c) {
                    return DropdownMenuItem<Course>(
                      value: c,
                      child: Text(
                        '${c.name} (${c.files.length} ملفات)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedChatCourse = val);
                  },
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
              return Align(
                alignment:
                    msg.isUser ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: msg.isUser ? Colors.indigo : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoadingResponse)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'اكتب سؤالك حول المحاضرات والملفات...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
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
