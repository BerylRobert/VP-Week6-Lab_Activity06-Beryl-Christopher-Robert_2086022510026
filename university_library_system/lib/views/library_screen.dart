import 'package:flutter/material.dart';

import '../models/book.dart';
import '../viewmodels/library_view_model.dart';
import 'borrowed_books.dart';
import 'widgets/book_card.dart';
import 'widgets/fine_summary.dart';
import 'widgets/loan_card.dart' show formatDate;

class LibraryScreen extends StatelessWidget {
  final LibraryViewModel vm;

  const LibraryScreen({super.key, required this.vm});

  void _showMessage(BuildContext context, ActionResult result) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Perpustakaan Universitas'),
            actions: [
              IconButton(
                tooltip: 'Pinjaman saya',
                icon: const Icon(Icons.library_books_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BorrowedBooksScreen(vm: vm),
                  ),
                ),
              ),
            ],
          ),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return _MessageState(
        icon: Icons.error_outline,
        text: vm.errorMessage!,
        actionLabel: 'Coba lagi',
        onAction: vm.load,
      );
    }

    final books = vm.filteredBooks;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: FineSummary(
            totalFine: vm.totalFine,
            activeCount: vm.activeCount,
            overdueCount: vm.overdueCount,
            missingCount: vm.missingCount,
          ),
        ),
        _DateSimulationBar(vm: vm),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: TextField(
            onChanged: vm.setSearchQuery,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari judul atau penulis',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        _FilterChips(vm: vm),
        Expanded(
          child: books.isEmpty
              ? const _MessageState(
                  icon: Icons.menu_book_outlined,
                  text: 'Tidak ada buku yang cocok.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: books.length,
                  itemBuilder: (context, i) {
                    final book = books[i];
                    return BookCard(
                      title: book.title,
                      author: book.author,
                      replacementPrice: book.replacementPrice,
                      availableCopies: vm.availableCopies(book.id),
                      totalStock: book.stock,
                      status: vm.bookStatus(book),
                      onBorrow: () => _showMessage(
                        context,
                        vm.borrowBook(book.id, vm.currentStudentId),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final LibraryViewModel vm;

  const _FilterChips({required this.vm});

  static const _labels = <BookStatus, String>{
    BookStatus.available: 'Tersedia',
    BookStatus.borrowed: 'Dipinjam',
    BookStatus.overdue: 'Terlambat',
    BookStatus.missing: 'Missing',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Semua'),
            selected: vm.statusFilter == null,
            onSelected: (_) => vm.setStatusFilter(null),
          ),
          for (final entry in _labels.entries) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(entry.value),
              selected: vm.statusFilter == entry.key,
              onSelected: (_) => vm.setStatusFilter(entry.key),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateSimulationBar extends StatelessWidget {
  final LibraryViewModel vm;

  const _DateSimulationBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Tanggal: ${formatDate(vm.today)}'
            '${vm.isSimulatingDate ? ' (simulasi)' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ActionChip(
            label: const Text('+7 hari'),
            onPressed: () => vm.advanceDays(7),
          ),
          ActionChip(
            label: const Text('Ke batas Missing'),
            onPressed: vm.jumpToMissingDate,
          ),
          if (vm.isSimulatingDate)
            ActionChip(
              label: const Text('Reset'),
              onPressed: vm.resetSimulatedDate,
            ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAction, child: Text(actionLabel ?? 'OK')),
            ],
          ],
        ),
      ),
    );
  }
}