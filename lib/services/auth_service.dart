import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // User Type আনো
  Future<String> getUserType() async {
    if (_auth.currentUser == null) return 'student';
    final doc = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    return doc.data()?['userType'] ?? 'student';
  }

  // Student Register
  Future<String?> registerStudent({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String university,
  }) async {
    // 10 digit ID check
    if (studentId.length != 10) {
      return 'Student ID অবশ্যই ১০ সংখ্যার হতে হবে';
    }
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'studentId': studentId,
        'university': university,
        'userType': 'student',
        'createdAt': DateTime.now(),
      });
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Guardian Register
  Future<String?> registerGuardian({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'userType': 'guardian',
        'createdAt': DateTime.now(),
      });
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
    await NotificationService.clearToken();
    await _auth.signOut();
    notifyListeners();
  }
}