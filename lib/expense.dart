class Expense {
  String id;
  String title;
  double amount;
  DateTime date;

  Expense({
    required this.amount,
    required this.date,
    required this.id,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // Convert date to a string for Firestore
    };
  }
}
