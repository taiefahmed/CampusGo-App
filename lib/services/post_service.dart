import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/feed_post.dart';

class PostService {
  final _postsRef = FirebaseFirestore.instance.collection('posts');

  // Real-time feed, newest first
  Stream<List<FeedPost>> postsStream() {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FeedPost.fromDoc(d)).toList());
  }

  // Only posts current user saved
  Stream<List<FeedPost>> savedPostsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _postsRef
        .where('savedBy', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FeedPost.fromDoc(d)).toList());
  }

  Future<String?> _uploadImage(File file, String postId) async {
    final ref = FirebaseStorage.instance.ref().child('post_images/$postId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> createPost({
    required String caption,
    required String type,
    File? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    // user info Firestore theke niye asha (name/handle)
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final name = userDoc.data()?['name'] ?? 'Student';
    final handle = '@${(userDoc.data()?['name'] ?? 'user').toString().toLowerCase().replaceAll(' ', '')}';
    final photoUrl = userDoc.data()?['photoUrl'];

    final docRef = _postsRef.doc(); // pre-generate id, image upload er jonno lagbe
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, docRef.id);
    }

    final post = FeedPost(
      id: docRef.id,
      authorId: user.uid,
      authorName: name,
      authorHandle: handle,
      authorPhotoUrl: photoUrl,
      caption: caption,
      imageUrl: imageUrl,
      type: type,
    );

    await docRef.set(post.toMap());
  }

  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _postsRef.doc(postId).update({
      'likedBy': currentlyLiked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> toggleSave(String postId, bool currentlySaved) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _postsRef.doc(postId).update({
      'savedBy': currentlySaved
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }
}