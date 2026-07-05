class BookModel {
  final String id;
  final String title;
  final String author;
  final double price;
  final String condition;
  final String phone;
  final String userId;
  final String sellerName;
  final String imageUrl;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.condition,
    required this.phone,
    required this.userId,
    required this.sellerName,
    this.imageUrl = '',
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    return BookModel(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      condition: map['condition'] ?? '',
      phone: map['phone'] ?? '',
      userId: map['userId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'price': price,
      'condition': condition,
      'phone': phone,
      'userId': userId,
      'sellerName': sellerName,
      'imageUrl': imageUrl,
    };
  }
}