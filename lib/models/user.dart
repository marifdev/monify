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

  UserModel({
    required this.uid,
    this.name,
    required this.email,
    required this.currency,
    this.categories,
    this.transactions,
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
    };
  }
}
