import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'course_model.dart';

class HomeScreen extends StatefulWidget {
  final String college;
  final String semester;

  const HomeScreen({
    Key? key,
    required this.college,
    required this.semester,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

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

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(courses.map((c) => c.toMap()).toList());
    await prefs.setString('saved_courses_${widget.college}_${widget.semester}', encodedData);
  }

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
      await _saveCourses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع الملف: $fileName بنجاح')),
        );
      }
    }
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
                    await _saveCourses();
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
            onPressed: () => Navigator.pop(context),
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
