class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String description;
  final String phone;
  final String userId;
  final String posterName;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.phone,
    required this.userId,
    required this.posterName,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      salary: map['salary'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      phone: map['phone'] ?? '',
      userId: map['userId'] ?? '',
      posterName: map['posterName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'type': type,
      'description': description,
      'phone': phone,
      'userId': userId,
      'posterName': posterName,
      'createdAt': DateTime.now(),
    };
  }
}