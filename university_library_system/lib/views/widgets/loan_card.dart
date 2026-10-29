import 'package:flutter/material.dart';

import '../../models/services/fine_policy.dart';
import 'fine_summary.dart' show formatRupiah;
import 'loan_status_badge.dart';

/// Format tanggal sederhana tanpa package: 2026-10-29 -> "29 Okt 2026"
String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class LoanCard extends StatelessWidget {
  final String bookTitle;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final LoanStatus status;
  final int fine;

  /// null = tombol Return tidak ditampilkan (mis. loan sudah dikembalikan).
  final VoidCallback? onReturn;

  const LoanCard({
    super.key,
    required this.bookTitle,
    required this.borrowDate,
    required this.dueDate,
    required this.status,
    required this.fine,
    this.returnDate,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
                    bookTitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                LoanStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dipinjam: ${formatDate(borrowDate)}',
                style: theme.textTheme.bodyMedium),
            Text('Jatuh tempo: ${formatDate(dueDate)}',
                style: theme.textTheme.bodyMedium),
            if (returnDate != null)
              Text('Dikembalikan: ${formatDate(returnDate!)}',
                  style: theme.textTheme.bodyMedium),
            if (fine > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Tagihan: ${formatRupiah(fine)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (onReturn != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: onReturn,
                  child: const Text('Kembalikan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}