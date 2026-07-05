import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroupModel {
  final String id;
  final String name;
  final String subject;
  final String description;
  final String location;
  final String time;
  final int maxMembers;
  final List<String> members;
  final String creatorId;
  final String creatorName;

  StudyGroupModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.description,
    required this.location,
    required this.time,
    required this.maxMembers,
    required this.members,
    required this.creatorId,
    required this.creatorName,
  });

  factory StudyGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyGroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      time: data['time'] ?? '',
      maxMembers: data['maxMembers'] ?? 5,
      members: List<String>.from(data['members'] ?? []),
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? 'Unknown',
    );
  }

  // service এ fromMap() call হচ্ছে তাই এটাও রাখো
  factory StudyGroupModel.fromMap(Map<String, dynamic> data, String id) {
    return StudyGroupModel(
      id: id,
      name: data['name'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      time: data['time'] ?? '',
      maxMembers: data['maxMembers'] ?? 5,
      members: List<String>.from(data['members'] ?? []),
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subject': subject,
      'description': description,
      'location': location,
      'time': time,
      'maxMembers': maxMembers,
      'members': members,
      'creatorId': creatorId,
      'creatorName': creatorName,
    };
  }
}