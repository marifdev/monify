import 'package:monify/models/account.dart';
import 'package:monify/models/category.dart';
import 'package:monify/models/currency.dart';
import 'package:monify/models/transaction.dart';

class UserModel {
  final String uid;
  final String? name;
  final String email;
  final Currency currency;
  List<Category>? categories;
  List<TransactionModel>? transactions;
  List<Account>? accounts;
  bool isPremium;

  UserModel({
    required this.uid,
    this.name,
    required this.email,
    required this.currency,
    this.categories,
    this.transactions,
    this.accounts,
    this.isPremium = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      currency: Currency.fromJson(json['currency']),
      categories:
          json['categories'] != null ? (json['categories'] as List).map((e) => Category.fromJson(e)).toList() : null,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List).map((e) => TransactionModel.fromJson(e)).toList()
          : null,
      accounts: json['accounts'] != null ? (json['accounts'] as List).map((e) => Account.fromJson(e)).toList() : null,
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'currency': currency,
      'categories': categories,
      'transactions': transactions,
      'accounts': accounts,
      'isPremium': isPremium,
    };
  }
}
