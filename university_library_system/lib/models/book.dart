enum BookStatus { available, borrowed, overdue, missing }

class Book {
  final String id;
  final String title;
  final String author;
  final int replacementPrice;

  final int stock;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
    this.stock = 1,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        replacementPrice: json['replacementPrice'] as int,
        stock: (json['stock'] as int?) ?? 1,
      );
}