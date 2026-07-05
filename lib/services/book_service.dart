import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // সব book আনো
  Stream<List<BookModel>> getBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Book add করো
  Future<void> addBook(BookModel book) async {
    final map = book.toMap();
    map['createdAt'] = DateTime.now();
    await _firestore.collection('books').add(map);
  }

  // Book delete করো
  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }
}