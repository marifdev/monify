import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monify/models/category.dart';
import 'package:monify/models/user.dart';
import '../models/transaction.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get transactions
  Future<List<QueryDocumentSnapshot>> getTransactions(String uid) async {
    List<QueryDocumentSnapshot> transactions = [];
    try {
      QuerySnapshot result = await _firestore.collection('users').doc(uid).collection('transactions').get();
      transactions = result.docs;
    } catch (e) {
      print(e.toString());
    }
    return transactions;
  }

  //get categories
  Future<List<QueryDocumentSnapshot>> getCategories(String uid) async {
    List<QueryDocumentSnapshot> categories = [];
    try {
      QuerySnapshot result = await _firestore.collection('users').doc(uid).collection('categories').get();
      categories = result.docs;
    } catch (e) {
      print(e.toString());
    }
    return categories;
  }

  //add transaction
  Future<void> addTransaction({
    required TransactionModel transaction,
    required String uid,
  }) async {
    try {
      var docRef = await _firestore.collection('users').doc(uid).collection('transactions').add({
        'title': transaction.title,
        'amount': transaction.amount,
        'isIncome': transaction.isIncome,
        'categoryId': transaction.categoryId,
        'date': transaction.date,
      });
      await _firestore.collection('users').doc(uid).collection('transactions').doc(docRef.id).update({
        'id': docRef.id,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //add category
  Future<void> addCategory({
    required Category category,
    required String uid,
  }) async {
    try {
      var docRef = await _firestore.collection('users').doc(uid).collection('categories').add({
        'name': category.name,
      });
      await _firestore.collection('users').doc(uid).collection('categories').doc(docRef.id).update({
        'id': docRef.id,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //delete transaction
  Future<void> deleteTransaction(String id, String uid) async {
    try {
      await _firestore.collection('users').doc(uid).collection('transactions').doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  //delete category
  Future<void> deleteCategory(String id, String uid) async {
    try {
      await _firestore.collection('users').doc(uid).collection('categories').doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  //update transaction
  Future<void> updateTransaction({
    required TransactionModel transaction,
    required String uid,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).collection('transactions').doc(transaction.id).update({
        'title': transaction.title,
        'amount': transaction.amount,
        'isIncome': transaction.isIncome,
        'categoryId': transaction.categoryId,
        'date': transaction.date,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //update category
  Future<void> updateCategory({
    required String id,
    required String title,
    required String icon,
    required bool isIncome,
  }) async {
    try {
      await _firestore.collection('categories').doc(id).update({
        'title': title,
        'icon': icon,
        'isIncome': isIncome,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //get user
  Future<UserModel> getUser(String uid) async {
    DocumentSnapshot user = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromJson(user.data()! as Map<String, dynamic>);
  }

  //update user
  Future<void> updateUser({
    required Map<String, dynamic> updatedFields,
    required String uid,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update(updatedFields);
    } catch (e) {
      print(e.toString());
    }
  }
}
