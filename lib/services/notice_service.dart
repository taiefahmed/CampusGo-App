import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // সব notice আনো
  Stream<List<NoticeModel>> getNotices() {
    return _firestore
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Category দিয়ে filter করো
  Stream<List<NoticeModel>> getNoticesByCategory(String category) {
    return _firestore
        .collection('notices')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Notice add করো
  Future<void> addNotice(NoticeModel notice) async {
    await _firestore.collection('notices').add(notice.toMap());
  }

  // Notice delete করো
  Future<void> deleteNotice(String noticeId) async {
    await _firestore.collection('notices').doc(noticeId).delete();
  }
}