class HostelModel {
  final String id;
  final String name;
  final String type;
  final String location;
  final double rent;
  final String facilities;
  final String phone;
  final String userId;
  final String ownerName;
  final String gender;

  HostelModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.rent,
    required this.facilities,
    required this.phone,
    required this.userId,
    required this.ownerName,
    required this.gender,
  });

  factory HostelModel.fromMap(Map<String, dynamic> map, String id) {
    return HostelModel(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      rent: (map['rent'] ?? 0).toDouble(),
      facilities: map['facilities'] ?? '',
      phone: map['phone'] ?? '',
      userId: map['userId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      gender: map['gender'] ?? 'যেকোনো',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'location': location,
      'rent': rent,
      'facilities': facilities,
      'phone': phone,
      'userId': userId,
      'ownerName': ownerName,
      'gender': gender,
      'createdAt': DateTime.now(),
    };
  }
}