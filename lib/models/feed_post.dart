import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorHandle;
  final String? authorPhotoUrl;
  final String caption;
  final String? imageUrl;
  final DateTime? createdAt;
  final List<String> likedBy;
  final List<String> savedBy;
  final int commentCount;
  final String type; // general | job | notice

  FeedPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorHandle,
    this.authorPhotoUrl,
    required this.caption,
    this.imageUrl,
    this.createdAt,
    this.likedBy = const [],
    this.savedBy = const [],
    this.commentCount = 0,
    this.type = 'general',
  });

  factory FeedPost.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorHandle: data['authorHandle'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      caption: data['caption'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      savedBy: List<String>.from(data['savedBy'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      type: data['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorHandle': authorHandle,
      'authorPhotoUrl': authorPhotoUrl,
      'caption': caption,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'likedBy': <String>[],
      'savedBy': <String>[],
      'commentCount': 0,
      'type': type,
    };
  }
}