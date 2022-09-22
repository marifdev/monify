import 'dart:ui';

class TransactionModel {
  String id;
  String title;
  DateTime date;
  double amount;
  String? categoryId;
  String? accountId;
  TransactionType type;
  String? fromAccountId;
  String? toAccountId;
  bool? isIncome;

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    this.categoryId,
    this.accountId,
    required this.type,
    this.toAccountId,
    this.isIncome = false,
  });

  TransactionModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        date = json['date'].toDate(),
        amount = json['amount'].toDouble(),
        categoryId = json['categoryId'].toString(),
        accountId = json['accountId'].toString(),
        type = json['type'] == 'income'
            ? TransactionType.income
            : json['type'] == 'transfer'
                ? TransactionType.transfer
                : json['isIncome']
                    ? TransactionType.income
                    : TransactionType.expense,
        toAccountId = json['toAccountId'].toString(),
        isIncome = json['isIncome'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
        'type': type == TransactionType.income
            ? 'income'
            : type == TransactionType.transfer
                ? 'transfer'
                : 'expense',
        'toAccountId': toAccountId,
      };
}

enum TransactionType { expense, income, transfer }

Map<TransactionType, Color> transactionTypeColorMap = {
  TransactionType.expense: const Color(0xFFB00020),
  TransactionType.income: const Color(0xFF209653),
  TransactionType.transfer: const Color(0xFF00B0F0),
};
