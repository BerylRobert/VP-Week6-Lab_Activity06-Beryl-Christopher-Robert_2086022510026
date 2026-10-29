import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../models/services/fine_policy.dart';

class LoanStatusBadge extends StatelessWidget {
  final LoanStatus status;

  const LoanStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (label, color) = switch (status) {
      LoanStatus.active => ('Dipinjam', scheme.primary),
      LoanStatus.overdue => ('Terlambat', Colors.orange.shade800),
      LoanStatus.missing => ('Missing', scheme.error),
      LoanStatus.returned => ('Dikembalikan', Colors.green.shade700),
    };

    return _Pill(label: label, color: color);
  }
}

class BookStatusBadge extends StatelessWidget {
  final BookStatus status;

  const BookStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (label, color) = switch (status) {
      BookStatus.available => ('Tersedia', Colors.green.shade700),
      BookStatus.borrowed => ('Dipinjam', scheme.primary),
      BookStatus.overdue => ('Terlambat', Colors.orange.shade800),
      BookStatus.missing => ('Missing', scheme.error),
    };

    return _Pill(label: label, color: color);
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}