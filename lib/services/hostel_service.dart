import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hostel_model.dart';

class HostelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // সব hostel আনো
  Stream<List<HostelModel>> getHostels() {
    return _firestore
        .collection('hostels')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HostelModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Type দিয়ে filter করো
  Stream<List<HostelModel>> getHostelsByType(String type) {
    return _firestore
        .collection('hostels')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HostelModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Hostel add করো
  Future<void> addHostel(HostelModel hostel) async {
    await _firestore.collection('hostels').add(hostel.toMap());
  }
}