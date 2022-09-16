// page for all transactions

import 'package:monify/models/currency.dart';
import 'package:monify/models/transaction.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../home/widgets/bottom_sheet.dart';
import '../home/widgets/transaction_card.dart';

class TransactionsView extends StatefulWidget {
  TransactionsView({
    Key? key,
    required this.transactions,
    required this.sortedTransactions,
    required this.categories,
    required this.currency,
  }) : super(key: key);

  List<TransactionModel> transactions;
  List<TransactionModel> sortedTransactions;
  List<Category> categories;
  final Currency currency;

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    var transactions = widget.transactions;
    var sortedTransactions = widget.sortedTransactions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        // actions: [
        //   IconButton(
        //     onPressed: () {

        //     },
        //     icon: const Icon(Icons.filter_alt),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          key: Key(transactions.length.toString()),
          children: sortedTransactions.map((tx) {
            var category = widget.categories.firstWhere(
              (element) => element.id == tx.categoryId,
            );
            return TransactionCard(
              transaction: tx,
              category: category,
              currency: widget.currency,
              onDelete: () async {
                setState(() {
                  FirestoreMethods().deleteTransaction(tx.id, userId);
                  setState(() {
                    transactions.remove(tx);
                    sortedTransactions.remove(tx);
                  });
                });
              },
              onEdit: () {
                _showBottomSheet(txToEdit: tx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBottomSheet({TransactionModel? txToEdit}) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return BottomSheetContainer(
          transactions: widget.transactions,
          tx: txToEdit,
          categories: widget.categories,
          onSave: (tx) async {
            setState(() {
              if (txToEdit != null) {
                FirestoreMethods().updateTransaction(transaction: tx, uid: userId);
                setState(() {
                  widget.transactions.remove(txToEdit);
                  widget.transactions.add(tx);
                });
              } else {
                FirestoreMethods().addTransaction(transaction: tx, uid: userId);
                setState(() {
                  widget.transactions.add(tx);
                });
              }
            });
            Navigator.pop(context);
          },
        );
      },
    ).then((value) => setState(() {
          widget.sortedTransactions = widget.transactions..sort((a, b) => b.date.compareTo(a.date));
        }));
  }
}
