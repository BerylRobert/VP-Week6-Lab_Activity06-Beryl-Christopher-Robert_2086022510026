import 'package:flutter/material.dart';

import 'models/repository/library_repository.dart';
import 'models/services/book_service.dart';
import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key});

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  late final LibraryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = LibraryViewModel(LibraryRepository(const BookService()));
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Library System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: LibraryScreen(vm: _vm),
    );
  }
}