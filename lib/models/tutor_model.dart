class TutorModel {
  final String id;
  final String name;
  final String subject;
  final String location;
  final double hourlyRate;
  final double rating;
  final String phone;
  final String userId;

  TutorModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.location,
    required this.hourlyRate,
    required this.rating,
    required this.phone,
    required this.userId,
  });

  factory TutorModel.fromMap(Map<String, dynamic> map, String id) {
    return TutorModel(
      id: id,
      name: map['name'] ?? '',
      subject: map['subject'] ?? '',
      location: map['location'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      phone: map['phone'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subject': subject,
      'location': location,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'phone': phone,
      'userId': userId,
    };
  }
}