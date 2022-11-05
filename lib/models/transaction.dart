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
    this.fromAccountId,
    this.isIncome = false,
  });

  TransactionModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        date = json['date'].toDate(),
        amount = json['amount'].toDouble(),
        categoryId = json['categoryId'].toString(),
        accountId = json['accountId'].toString(),
        type = json['type'] != null
            ? getTransactionType(json['type'])
            : json['isIncome']
                ? TransactionType.income
                : TransactionType.expense,
        toAccountId = json['toAccountId'].toString(),
        fromAccountId = json['fromAccountId'].toString(),
        isIncome = json['isIncome'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
        'type': getTransactionType(type),
        'toAccountId': toAccountId,
        'fromAccountId': fromAccountId,
      };
}

getTransactionType(type) {
  if (type is TransactionType) {
    switch (type) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
      case TransactionType.transfer:
        return 'transfer';
      case TransactionType.payment:
        return 'payment';
    }
  } else if (type is String) {
    switch (type) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      case 'payment':
        return TransactionType.payment;
    }
  }
}

enum TransactionType { expense, income, transfer, payment }

Map<TransactionType, Color> transactionTypeColorMap = {
  TransactionType.expense: const Color(0xFFB00020),
  TransactionType.income: const Color(0xFF209653),
  TransactionType.transfer: const Color(0xFF00B0F0),
  TransactionType.payment: const Color(0xFFB00020),
};
