import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package0:open_filex/open_filex.dart'; // حزمة فتح الملفات

// -----------------------------------------------------------------------------
// 1. نموذج البيانات للمقرر الدراسي (Course Model)
// -----------------------------------------------------------------------------
class Course {
  String id;
  String name;
  int creditHours;
  String labTools;
  String? fileName;
  String? filePath;

  Course({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.labTools,
    this.fileName,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'creditHours': creditHours,
        'labTools': labTools,
        'fileName': fileName,
        'filePath': filePath,
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'],
        name: json['name'],
        creditHours: json['creditHours'],
        labTools: json['labTools'],
        fileName: json['fileName'],
        filePath: json['filePath'],
      );
}

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
        Locale('ar', ''),
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
// 2. شاشة الإعداد الأولية (القوائم المنسدلة للكلية والقسم والسمستر)
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

              // قائمة الكلية
              DropdownButtonFormField<String>(
                value: selectedFaculty,
                decoration: const InputDecoration(
                  labelText: 'الكلية',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school, color: Colors.indigo),
                ),
                items: academicData.keys
                    .map((fac) => DropdownMenuItem(
                          value: fac,
                          child: Text(fac),
                        ))
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

              // قائمة القسم
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'القسم / التخصص',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.domain, color: Colors.indigo),
                ),
                items: availableDepartments
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedDepartment = value);
                },
              ),
              const SizedBox(height: 20),

              // قائمة السمستر
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
                  if (value != null) {
                    setState(() => selectedSemester = value);
                  }
                },
              ),
              const SizedBox(height: 35),

              // زر الدخول للتطبيق
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
// 3. الشاشة الرئيسية للتطبيق (Main Dashboard)
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

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // حفظ واسترجاع المقررات
  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saveData = prefs.getString('courses_data');
    if (saveData != null) {
      final List<dynamic> decodedList = jsonDecode(saveData);
      setState(() {
        courses = decodedList.map((item) => Course.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(courses.map((c) => c.toJson()).toList());
    await prefs.setString('courses_data', encodedData);
  }

  // إدراج ملف المحاضرة
  Future<void> _pickFileForCourse(Course course) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        course.fileName = result.files.single.name;
        course.filePath = result.files.single.path;
      });
      await _saveCourses();
    }
  }

  // دالة فتح الملف وقراءة محتواه عند الضغط
  Future<void> _openCourseFile(String? filePath) async {
    if (filePath != null && filePath.isNotEmpty) {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر فتح الملف: ${result.message}')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مسار الملف غير متوفر أو تم حذفه')),
        );
      }
    }
  }

  // نافذة إضافة مقرر جديد
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
                  courses.add(Course(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    creditHours: int.tryParse(hoursController.text) ?? 3,
                    labTools: labController.text.isEmpty
                        ? 'لا يوجد'
                        : labController.text,
                  ));
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
          const Center(child: Text('الشات الذكي (قريباً)')),
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

  // واجهة تفاصيل المقررات
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
                if (course.fileName != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _openCourseFile(course.filePath),
                      icon: const Icon(Icons.picture_as_pdf,
                          color: Colors.indigo),
                      label: Text(
                        course.fileName!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
