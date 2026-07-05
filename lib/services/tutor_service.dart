import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tutor_model.dart';

class TutorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // সব tutor আনো
  Stream<List<TutorModel>> getTutors() {
    return _firestore.collection('tutors').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TutorModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Tutor add করো
  Future<void> addTutor(TutorModel tutor) async {
    await _firestore.collection('tutors').add(tutor.toMap());
  }

  // Subject দিয়ে search করো
  Stream<List<TutorModel>> searchTutors(String subject) {
    return _firestore
        .collection('tutors')
        .where('subject', isGreaterThanOrEqualTo: subject)
        .where('subject', isLessThanOrEqualTo: '$subject\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TutorModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}