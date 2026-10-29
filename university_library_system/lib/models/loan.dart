class Loan {
  final String id;
  final String bookId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;

  const Loan({
    required this.id,
    required this.bookId,
    required this.studentId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
  });

  bool get isActive => returnDate == null;
  bool get isReturned => returnDate != null;

  Loan copyWith({DateTime? returnDate}) => Loan(
        id: id,
        bookId: bookId,
        studentId: studentId,
        borrowDate: borrowDate,
        dueDate: dueDate,
        returnDate: returnDate ?? this.returnDate,
      );
}