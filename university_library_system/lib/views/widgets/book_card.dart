import 'package:flutter/material.dart';

import '../../models/book.dart';
import 'fine_summary.dart' show formatRupiah;
import 'loan_status_badge.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final int replacementPrice;
  final int availableCopies;
  final int totalStock;
  final BookStatus status;

  final VoidCallback? onBorrow;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.replacementPrice,
    required this.availableCopies,
    required this.totalStock,
    required this.status,
    this.onBorrow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                BookStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 4),
            Text(author, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Tersedia: $availableCopies dari $totalStock',
                style: theme.textTheme.bodySmall),
            Text('Harga ganti: ${formatRupiah(replacementPrice)}',
                style: theme.textTheme.bodySmall),
            if (onBorrow != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onBorrow,
                  child: const Text('Pinjam'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}