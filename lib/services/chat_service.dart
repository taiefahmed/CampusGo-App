import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Messages আনো
  Stream<List<ChatModel>> getMessages(String groupId) {
    return _firestore
        .collection('study_groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Message পাঠাও
  Future<void> sendMessage({
    required String groupId,
    required String message,
    required String senderId,
    required String senderName,
  }) async {
    final chat = ChatModel(
      id: '',
      message: message,
      senderId: senderId,
      senderName: senderName,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('study_groups')
        .doc(groupId)
        .collection('messages')
        .add(chat.toMap());
  }
}