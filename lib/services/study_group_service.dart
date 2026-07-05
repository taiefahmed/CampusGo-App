import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/study_group_model.dart';

class StudyGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // সব group আনো
  Stream<List<StudyGroupModel>> getGroups() {
    return _firestore
        .collection('study_groups')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => StudyGroupModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Group বানাও
  Future<void> createGroup(StudyGroupModel group) async {
    await _firestore.collection('study_groups').add(group.toMap());
  }

  // Group এ join করো
  Future<void> joinGroup(String groupId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('study_groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([uid]),
    });
  }

  // Group থেকে leave করো
  Future<void> leaveGroup(String groupId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('study_groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
  }
}
