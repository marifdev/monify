// page for all transactions

import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:monify/models/currency.dart';
import 'package:monify/models/transaction.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../home/widgets/bottom_sheet.dart';
import '../home/widgets/slidable_transaction_card.dart';

class TransactionsView extends StatefulWidget {
  TransactionsView({
    Key? key,
    required this.transactions,
    required this.sortedTransactions,
    required this.accounts,
    required this.categories,
    required this.currency,
  }) : super(key: key);

  List<TransactionModel> transactions;
  List<TransactionModel> sortedTransactions;
  List<Account> accounts;
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
        title: Text(LocaleKeys.transactions.tr()),
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
              orElse: () => Category(name: LocaleKeys.selectCategory.tr()),
            );
            var account = widget.accounts.firstWhere(
              (element) => element.id == tx.accountId,
              orElse: () => Account(
                id: '',
                name: '',
                balance: 0,
                createdAt: '',
                updatedAt: '',
                type: AccountType.cash,
              ),
            );

            var toAccount = widget.accounts.firstWhere(
              (element) => element.id == tx.toAccountId,
              orElse: () => Account(
                id: '',
                name: '',
                balance: 0,
                createdAt: '',
                updatedAt: '',
                type: AccountType.cash,
              ),
            );
            var index = sortedTransactions.indexOf(tx);
            return Column(
              children: [
                if (index == 0 ||
                    DateFormat.yMd(context.locale.toLanguageTag()).format(tx.date) !=
                        DateFormat.yMd(context.locale.toLanguageTag()).format(sortedTransactions[index - 1].date)) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: Row(
                      children: [
                        Text(
                          DateFormat.yMd(context.locale.toLanguageTag()).format(tx.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 10),
                ],
                SlidableTransactionCard(
                  account: account,
                  toAccount: toAccount,
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
                ),
              ],
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
          accounts: widget.accounts,
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
