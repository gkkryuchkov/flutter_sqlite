import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/student.dart';

class DatabaseHelper {
  // Создаем singleton
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Названия таблицы и столбцов
  final String tableStudents = 'students';
  final String columnId = 'id';
  final String columnFullName = 'full_name';
  final String columnGroup = 'group_name';
  final String columnGpa = 'gpa';
  final String columnDateOfBirth = 'date_of_birth';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStudents ($columnId INTEGER PRIMARY KEY,$columnFullName TEXT NOT NULL,$columnGroup TEXT NOT NULL,$columnGpa REAL NOT NULL,$columnDateOfBirth TEXT NOT NULL);
    ''');
  }

  Future<int> insertStudent(Student student) async {
    final db = await instance.database;
    return await db.insert(tableStudents, student.toMap());
  }

  Future<Student?> getStudent(int id) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableStudents,
      columns: [
        columnId,
        columnFullName,
        columnGroup,
        columnGpa,
        columnDateOfBirth
      ],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Student>> getAllStudents() async {
    await Future.delayed(const Duration(seconds: 5));
    final db = await instance.database;
    final result = await db.query(tableStudents);
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return await db.update(
      tableStudents,
      student.toMap(),
      where: '$columnId = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableStudents,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
