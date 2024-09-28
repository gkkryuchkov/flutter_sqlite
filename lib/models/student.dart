class Student {
  int? id;
  String fullName;
  String group;
  double gpa;
  String dateOfBirth;

  Student({
    this.id,
    required this.fullName,
    required this.group,
    required this.gpa,
    required this.dateOfBirth,
  });

  // Преобразование объекта Student в Map для хранения в базе данных
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'full_name': fullName,
      'group_name': group,
      'gpa': gpa,
      'date_of_birth': dateOfBirth,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Создание объекта Student из Map, полученного из базы данных
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      fullName: map['full_name'],
      group: map['group_name'],
      gpa: map['gpa'],
      dateOfBirth: map['date_of_birth'],
    );
  }
}
