import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/student.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final String title = 'Student SQLite Demo with Loading Animation';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: StudentHomePage(title: title),
    );
  }
}

class StudentHomePage extends StatefulWidget {
  final String title;

  const StudentHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final dbHelper = DatabaseHelper.instance;

  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей формы
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _studentGroupController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  // Переменная для обновления FutureBuilder
  late Future<List<Student>> _studentListFuture;

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentGroupController.dispose();
    _gpaController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void _refreshStudentList() {
    setState(() {
      _studentListFuture = dbHelper.getAllStudents();
    });
  }

  void _clearForm() {
    _fullNameController.clear();
    _studentGroupController.clear();
    _gpaController.clear();
    _dateOfBirthController.clear();
  }

  void _insertStudent() async {
    if (_formKey.currentState!.validate()) {
      Student student = Student(
        fullName: _fullNameController.text,
        group: _studentGroupController.text,
        gpa: double.parse(_gpaController.text),
        dateOfBirth: _dateOfBirthController.text,
      );
      await dbHelper.insertStudent(student);
      _clearForm();
      _refreshStudentList();
    }
  }

  void _editStudent(Student student) {
    // Заполняем форму данными выбранного студента
    _fullNameController.text = student.fullName;
    _studentGroupController.text = student.group;
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
            child: _buildFormFields(),
          ),
          actions: [
            ElevatedButton(
              child: Text('Сохранить'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Student updatedStudent = Student(
                    id: student.id,
                    fullName: _fullNameController.text,
                    group: _studentGroupController.text,
                    gpa: double.parse(_gpaController.text),
                    dateOfBirth: _dateOfBirthController.text,
                  );
                  await dbHelper.updateStudent(updatedStudent);
                  Navigator.of(context).pop();
                  _clearForm();
                  _refreshStudentList();
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

  Widget _buildFormFields() {
    return SingleChildScrollView(
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
            controller: _studentGroupController,
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
            keyboardType: TextInputType.numberWithOptions(decimal: true),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Форма для добавления студента
            Form(
              key: _formKey,
              child: _buildFormFields(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _insertStudent,
              child: const Text('Добавить студента'),
            ),
            const SizedBox(height: 20),
            // FutureBuilder для отображения списка студентов
            Expanded(
              child: FutureBuilder<List<Student>>(
                future: _studentListFuture,
                builder: (context, AsyncSnapshot<List<Student>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Отображаем индикатор загрузки
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Обрабатываем ошибки
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Если данных нет
                    return const Center(child: Text('Список студентов пуст'));
                  } else {
                    // Отображаем список студентов
                    final students = snapshot.data!;
                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Card(
                          child: ListTile(
                            title: Text(student.fullName),
                            subtitle: Text(
                              'Группа: ${student.group}\n'
                              'Средний балл: ${student.gpa}\n'
                              'Дата рождения: ${student.dateOfBirth}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editStudent(student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteStudent(student.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
