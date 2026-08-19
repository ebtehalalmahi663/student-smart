import 'dart:convert';

class Course {
  final String name;
  final int hours;
  final String labLanguages;
  List<String> files;

  Course({
    required this.name,
    required this.hours,
    required this.labLanguages,
    List<String>? files,
  }) : files = files ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hours': hours,
      'labLanguages': labLanguages,
      'files': files,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      name: map['name'] ?? '',
      hours: map['hours'] ?? 0,
      labLanguages: map['labLanguages'] ?? '',
      files: List<String>.from(map['files'] ?? []),
    );
  }
}
