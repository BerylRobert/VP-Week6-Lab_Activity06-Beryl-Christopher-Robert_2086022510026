import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../book.dart';

class BookService {
  static const String assetPath = 'books.json';

  const BookService();

  Future<List<Book>> loadBooks() async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}