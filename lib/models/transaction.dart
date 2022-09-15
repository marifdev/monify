class TransactionModel {
  String id;
  String title;
  DateTime date;
  double amount;
  String? categoryId;
  bool isIncome;

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    this.categoryId,
    this.isIncome = false,
  });

  TransactionModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        date = json['date'].toDate(),
        amount = json['amount'].toDouble(),
        categoryId = json['categoryId'].toString(),
        isIncome = json['isIncome'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'amount': amount,
        'categoryId': categoryId,
        'isIncome': isIncome,
      };
}
