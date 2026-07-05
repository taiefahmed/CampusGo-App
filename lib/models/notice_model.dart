class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String userId;
  final String posterName;
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.userId,
    required this.posterName,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    return NoticeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      userId: map['userId'] ?? '',
      posterName: map['posterName'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt']).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'userId': userId,
      'posterName': posterName,
      'createdAt': DateTime.now(),
    };
  }
}