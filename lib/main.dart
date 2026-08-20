import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const StudentSmartApp());
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

// 1. شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();

  void _login() {
    if (_idController.text.trim().isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CollegeSelectionScreen(),
        ),
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

// 2. شاشة اختيار الكلية والقسم والسمستر
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

// 3. شاشة التنقل الرئيسية
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
      HomeScreen(
        college: widget.college,
        semester: widget.semester,
      ),
      const Center(child: Text('الشات الذكي')),
      const Center(child: Text('قياس المذاكرة')),
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
