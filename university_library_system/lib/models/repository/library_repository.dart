import '../book.dart';
import '../loan.dart';
import '../services/book_service.dart';

class LibraryRepository {
  final BookService _bookService;

  final List<Book> _books = [];
  final List<Loan> _loans = [];
  int _loanCounter = 0;

  LibraryRepository(this._bookService);

  Future<void> init() async {
    final books = await _bookService.loadBooks();
    _books
      ..clear()
      ..addAll(books);
  }

  List<Book> getBooks() => List.unmodifiable(_books);

  Book? findBook(String id) {
    final i = _books.indexWhere((b) => b.id == id);
    return i == -1 ? null : _books[i];
  }

  List<Loan> getLoans() => List.unmodifiable(_loans);

  Loan? findLoan(String id) {
    final i = _loans.indexWhere((l) => l.id == id);
    return i == -1 ? null : _loans[i];
  }

  void addLoan(Loan loan) => _loans.add(loan);

  void updateLoan(Loan loan) {
    final i = _loans.indexWhere((l) => l.id == loan.id);
    if (i != -1) _loans[i] = loan;
  }

  String nextLoanId() => 'L${++_loanCounter}';
}