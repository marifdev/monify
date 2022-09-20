class TransactionModel {
  String id;
  String title;
  DateTime date;
  double amount;
  String? categoryId;
  String? accountId;
  bool isIncome;

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    this.categoryId,
    this.accountId,
    this.isIncome = false,
  });

  TransactionModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        date = json['date'].toDate(),
        amount = json['amount'].toDouble(),
        categoryId = json['categoryId'].toString(),
        accountId = json['accountId'].toString(),
        isIncome = json['isIncome'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
        'isIncome': isIncome,
      };
}
