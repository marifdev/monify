import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/models/user.dart';
import 'package:monify/resources/firestore_methods.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import 'base_model.dart';

class BaseController {
  final BaseModel model;

  BaseController(this.model);

  Future<void> init() async {
    model.setLoading(true);
    var user = await getUser();
    var categories = await getCategories();
    var transactions = await getTransactions();
    var accounts = await getAccounts();
    model.setUser(user);
    model.loadCategories(categories);
    model.loadTransactions(transactions);
    model.loadAccounts(accounts);
    model.setLoading(false);
  }

  Future<UserModel> getUser() async {
    var user = await FirestoreMethods().getUser(FirebaseAuth.instance.currentUser!.uid);

    return user;
  }

  Future<List<Category>> getCategories() async {
    List<Category> categories;
    var docs = await FirestoreMethods().getCategories(FirebaseAuth.instance.currentUser!.uid);
    categories = docs
        .map((e) {
          return Category.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<Category>();
    return categories;
  }

  Future<List<TransactionModel>> getTransactions() async {
    List<TransactionModel> transactions = [];
    var docs = await FirestoreMethods().getTransactions(FirebaseAuth.instance.currentUser!.uid);
    transactions = docs
        .map((e) {
          return TransactionModel.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<TransactionModel>();
    return transactions;
  }

  Future<List<Account>> getAccounts() async {
    List<Account> accounts = [];
    var docs = await FirestoreMethods().getAccounts(FirebaseAuth.instance.currentUser!.uid);
    accounts = docs
        .map((e) {
          return Account.fromJson(e.data() as Map<String, dynamic>);
        })
        .toList()
        .cast<Account>();
    return accounts;
  }
}
