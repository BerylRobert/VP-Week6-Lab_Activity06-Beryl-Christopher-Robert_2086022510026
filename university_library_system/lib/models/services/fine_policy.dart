enum LoanStatus { active, overdue, missing, returned }

class FinePolicy {
  static const int fineStep = 5000;
  static const int daysPerWeek = 7;
  static const int missingAfterMonths = 6;
  static const int loanPeriodDays = 14;

  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  static DateTime dueDateFrom(DateTime borrowDate) =>
      _dateOnly(borrowDate).add(const Duration(days: loanPeriodDays));

  static DateTime missingDate(DateTime dueDate) {
    final due = _dateOnly(dueDate);
    final targetMonth = due.month + missingAfterMonths;
    final year = due.year + (targetMonth - 1) ~/ 12;
    final month = (targetMonth - 1) % 12 + 1;
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    final day = due.day > lastDay ? lastDay : due.day;
    return DateTime.utc(year, month, day);
  }

  static int overdueDays(DateTime dueDate, DateTime asOf) {
    final days = _dateOnly(asOf).difference(_dateOnly(dueDate)).inDays;
    return days > 0 ? days : 0;
  }

  static bool isMissing(DateTime dueDate, DateTime asOf) =>
      !_dateOnly(asOf).isBefore(missingDate(dueDate));

  static int _accumulated(int totalOverdueDays) {
    int totalFine = 0;
    
    for (int day = daysPerWeek; day <= totalOverdueDays; day++) {
      int weekMultiplier = day ~/ daysPerWeek; 
      totalFine += weekMultiplier * fineStep;
    }
    
    return totalFine;
  }

  static int overdueFine(DateTime dueDate, DateTime asOf) {
    final cutoff = isMissing(dueDate, asOf) ? missingDate(dueDate) : asOf;
    return _accumulated(overdueDays(dueDate, cutoff));
  }

  static int calculateFine({
    required DateTime dueDate,
    required DateTime asOf,
    required int replacementPrice,
  }) {
    final fine = overdueFine(dueDate, asOf);
    return isMissing(dueDate, asOf) ? replacementPrice + fine : fine;
  }

  static LoanStatus status({
    required DateTime dueDate,
    required DateTime asOf,
    required bool isReturned,
  }) {
    if (isMissing(dueDate, asOf)) return LoanStatus.missing;
    if (isReturned) return LoanStatus.returned;
    return overdueDays(dueDate, asOf) > 0 ? LoanStatus.overdue : LoanStatus.active;
  }
}