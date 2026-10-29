import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';
import 'widgets/fine_summary.dart';
import 'widgets/loan_card.dart';

class BorrowedBooksScreen extends StatelessWidget {
  final LibraryViewModel vm;

  const BorrowedBooksScreen({super.key, required this.vm});

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
        final loans = vm.loans;

        return Scaffold(
          appBar: AppBar(title: const Text('Pinjaman Saya')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: FineSummary(
                  totalFine: vm.totalFine,
                  activeCount: vm.activeCount,
                  overdueCount: vm.overdueCount,
                  missingCount: vm.missingCount,
                ),
              ),
              Expanded(
                child: loans.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined, size: 48),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada pinjaman.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: loans.length,
                        itemBuilder: (context, i) {
                          final loan = loans[i];
                          return LoanCard(
                            bookTitle: vm.bookTitle(loan),
                            borrowDate: loan.borrowDate,
                            dueDate: loan.dueDate,
                            returnDate: loan.returnDate,
                            status: vm.getOverdueStatus(loan),
                            fine: vm.calculateFine(loan),
                            onReturn: loan.isActive
                                ? () => _showMessage(
                                      context,
                                      vm.returnBook(loan.id),
                                    )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}