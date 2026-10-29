import 'package:flutter/material.dart';

String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}Rp$buffer';
}

class FineSummary extends StatelessWidget {
  final int totalFine;
  final int activeCount;
  final int overdueCount;
  final int missingCount;

  const FineSummary({
    super.key,
    required this.totalFine,
    required this.activeCount,
    required this.overdueCount,
    required this.missingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total denda & tagihan', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              formatRupiah(totalFine),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: totalFine > 0 ? scheme.error : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(label: 'Aktif', value: activeCount),
                _Stat(label: 'Terlambat', value: overdueCount),
                _Stat(label: 'Missing', value: missingCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}