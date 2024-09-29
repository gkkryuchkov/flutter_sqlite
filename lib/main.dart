import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/student.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student SQLite Demo',
      home: StudentHomePage(),
    );
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final dbHelper = DatabaseHelper.instance;

  final _formKey = GlobalKey<FormState>();

  // Контроллеры для текстовых полей
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  List<Student> students = [];

  @override
  void dispose() {
    _fullNameController.dispose();
    _groupController.dispose();
    _gpaController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void _insertStudent() async {
    if (_formKey.currentState!.validate()) {
      Student student = Student(
        fullName: _fullNameController.text,
        group: _groupController.text,
        gpa: double.parse(_gpaController.text),
        dateOfBirth: _dateOfBirthController.text,
      );
      await dbHelper.insertStudent(student);
      _refreshStudentList();
      _clearForm();
    }
  }

  void _refreshStudentList() async {
    List<Student> x = await dbHelper.getAllStudents();
    setState(() {
      students = x;
    });
  }

  void _clearForm() {
    _fullNameController.clear();
    _groupController.clear();
    _gpaController.clear();
    _dateOfBirthController.clear();
  }

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Student SQLite Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Форма для ввода данных студента
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(labelText: 'ФИО'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите ФИО';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _groupController,
                      decoration: InputDecoration(labelText: 'Группа'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите группу';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _gpaController,
                      decoration: InputDecoration(labelText: 'Средний балл'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите средний балл';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Пожалуйста, введите число';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _dateOfBirthController,
                      decoration: InputDecoration(labelText: 'Дата рождения'),
                      readOnly: true,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          _dateOfBirthController.text =
                              date.toIso8601String().split('T')[0];
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, выберите дату рождения';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _insertStudent,
                      child: Text('Добавить студента'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Список студентов
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    Student student = students[index];
                    return Card(
                      child: ListTile(
                        title: Text(student.fullName),
                        subtitle: Text(
                            'Группа: ${student.group}\nСредний балл: ${student.gpa}\nДата рождения: ${student.dateOfBirth}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editStudent(student);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteStudent(student.id!);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void _editStudent(Student student) {
    // Заполнить форму данными студента
    _fullNameController.text = student.fullName;
    _groupController.text = student.group;
    _gpaController.text = student.gpa.toString();
    _dateOfBirthController.text = student.dateOfBirth;

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Редактировать студента"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(labelText: 'ФИО'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите ФИО';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _groupController,
                    decoration: InputDecoration(labelText: 'Группа'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите группу';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _gpaController,
                    decoration: InputDecoration(labelText: 'Средний балл'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите средний балл';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Пожалуйста, введите число';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dateOfBirthController,
                    decoration: InputDecoration(labelText: 'Дата рождения'),
                    readOnly: true,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(student.dateOfBirth),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        _dateOfBirthController.text =
                            date.toIso8601String().split('T')[0];
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, выберите дату рождения';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text('Сохранить'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Student updatedStudent = Student(
                    id: student.id,
                    fullName: _fullNameController.text,
                    group: _groupController.text,
                    gpa: double.parse(_gpaController.text),
                    dateOfBirth: _dateOfBirthController.text,
                  );
                  await dbHelper.updateStudent(updatedStudent);
                  Navigator.of(context).pop();
                  _refreshStudentList();
                  _clearForm();
                }
              },
            ),
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(int id) async {
    await dbHelper.deleteStudent(id);
    _refreshStudentList();
  }
}
