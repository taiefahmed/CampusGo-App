class ChatModel {
  final String id;
  final String message;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt']).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': DateTime.now(),
    };
  }
}