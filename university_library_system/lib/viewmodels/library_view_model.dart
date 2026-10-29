import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/loan.dart';
import '../models/repository/library_repository.dart';
import '../models/services/fine_policy.dart';

class ActionResult {
  final bool success;
  final String message;
  const ActionResult.ok(this.message) : success = true;
  const ActionResult.fail(this.message) : success = false;
}

class LibraryViewModel extends ChangeNotifier {
  final LibraryRepository _repo;
  final DateTime Function() _clock;
  final String currentStudentId;

  LibraryViewModel(
    this._repo, {
    DateTime Function()? clock,
    this.currentStudentId = 'S001',
  }) : _clock = clock ?? DateTime.now;

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _simulatedDate;
  String _searchQuery = '';
  BookStatus? _statusFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  BookStatus? get statusFilter => _statusFilter;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repo.init();
    } catch (_) {
      _errorMessage = 'Gagal memuat katalog buku.';
    }
    _isLoading = false;
    notifyListeners();
  }

  DateTime get today {
    final d = _simulatedDate ?? _clock();
    return DateTime.utc(d.year, d.month, d.day);
  }

  bool get isSimulatingDate => _simulatedDate != null;

  void setSimulatedDate(DateTime date) {
    _simulatedDate = DateTime.utc(date.year, date.month, date.day);
    notifyListeners();
  }

  void advanceDays(int days) {
    _simulatedDate = today.add(Duration(days: days));
    notifyListeners();
  }

  void jumpToMissingDate() {
  final futureMissingDates = _repo
      .getLoans()
      .where((l) => l.isActive)
      .map((l) => FinePolicy.missingDate(l.dueDate))
      .where((missingDate) => missingDate.isAfter(today))
      .toList();
  if (futureMissingDates.isEmpty) return;
  futureMissingDates.sort();
  _simulatedDate = futureMissingDates.first;
  notifyListeners();
  }

  void resetSimulatedDate() {
    _simulatedDate = null;
    notifyListeners();
  }

  DateTime _asOf(Loan loan) => loan.returnDate ?? today;

  LoanStatus getOverdueStatus(Loan loan) => FinePolicy.status(
        dueDate: loan.dueDate,
        asOf: _asOf(loan),
        isReturned: loan.isReturned,
      );

  int calculateFine(Loan loan) => FinePolicy.calculateFine(
        dueDate: loan.dueDate,
        asOf: _asOf(loan),
        replacementPrice: _repo.findBook(loan.bookId)?.replacementPrice ?? 0,
      );

  String bookTitle(Loan loan) =>
      _repo.findBook(loan.bookId)?.title ?? 'Buku tidak dikenal';

  bool _holdsCopy(Loan loan) =>
      loan.isActive || getOverdueStatus(loan) == LoanStatus.missing;

  List<Book> get books => _repo.getBooks();

  int availableCopies(String bookId) {
    final book = _repo.findBook(bookId);
    if (book == null) return 0;
    final held = _repo
        .getLoans()
        .where((l) => l.bookId == bookId && _holdsCopy(l))
        .length;
    return math.max(0, book.stock - held);
  }

  BookStatus bookStatus(Book book) {
    if (availableCopies(book.id) > 0) return BookStatus.available;
    final statuses = _repo
        .getLoans()
        .where((l) => l.bookId == book.id && _holdsCopy(l))
        .map(getOverdueStatus);
    if (statuses.contains(LoanStatus.missing)) return BookStatus.missing;
    if (statuses.contains(LoanStatus.overdue)) return BookStatus.overdue;
    return BookStatus.borrowed;
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void setStatusFilter(BookStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  List<Book> get filteredBooks => books.where((b) {
        final matchesQuery = _searchQuery.isEmpty ||
            b.title.toLowerCase().contains(_searchQuery) ||
            b.author.toLowerCase().contains(_searchQuery);
        final matchesStatus =
            _statusFilter == null || bookStatus(b) == _statusFilter;
        return matchesQuery && matchesStatus;
      }).toList();

  List<Loan> get loans => _repo.getLoans().reversed.toList();
  List<Loan> get activeLoans => loans.where((l) => l.isActive).toList();
  List<Loan> get overdueLoans => loans
      .where((l) => l.isActive && getOverdueStatus(l) == LoanStatus.overdue)
      .toList();
  List<Loan> get missingLoans =>
      loans.where((l) => getOverdueStatus(l) == LoanStatus.missing).toList();

  int get totalFine => loans.fold(0, (sum, l) => sum + calculateFine(l));
  int get activeCount => activeLoans.length;
  int get overdueCount => overdueLoans.length;
  int get missingCount => missingLoans.length;

  ActionResult borrowBook(String bookId, String studentId) {
    final book = _repo.findBook(bookId);
    if (book == null) return const ActionResult.fail('Buku tidak ditemukan.');

    final alreadyBorrowed = _repo.getLoans().any(
        (l) => l.isActive && l.bookId == bookId && l.studentId == studentId);
    if (alreadyBorrowed) {
      return const ActionResult.fail('Kamu sudah meminjam buku ini.');
    }
    if (availableCopies(bookId) <= 0) {
      return const ActionResult.fail('Stok buku habis.');
    }

    final loan = Loan(
      id: _repo.nextLoanId(),
      bookId: bookId,
      studentId: studentId,
      borrowDate: today,
      dueDate: FinePolicy.dueDateFrom(today),
    );
    _repo.addLoan(loan);
    notifyListeners();
    return ActionResult.ok('Berhasil meminjam "${book.title}".');
  }

  ActionResult returnBook(String loanId) {
    final loan = _repo.findLoan(loanId);
    if (loan == null) return const ActionResult.fail('Data pinjaman tidak ditemukan.');
    if (loan.isReturned) {
      return const ActionResult.fail('Buku ini sudah dikembalikan.');
    }

    final updated = loan.copyWith(returnDate: today);
    _repo.updateLoan(updated);
    notifyListeners();

    if (getOverdueStatus(updated) == LoanStatus.missing) {
      return const ActionResult.ok(
          'Buku berstatus Missing. Tagihan tetap berlaku dan menunggu keputusan perpustakaan.');
    }
    return const ActionResult.ok('Buku berhasil dikembalikan.');
  }
}