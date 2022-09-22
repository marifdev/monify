import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/account.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    Key? key,
    required this.transaction,
    this.account,
  }) : super(key: key);

  final TransactionModel transaction;
  final Account? account;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      findInOrOut(transaction),
                      style: TextStyle(
                          color: transactionTypeColorMap[transaction.type], fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      transaction.amount.toString(),
                      style: TextStyle(
                          color: transactionTypeColorMap[transaction.type], fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                Text(DateFormat('HH:mm').format(transaction.date)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String findInOrOut(TransactionModel transaction) {
    if (transaction.type == TransactionType.income) {
      return '+';
    } else if (transaction.type == TransactionType.expense) {
      return '-';
    } else {
      //find account from transaction.toAccountId
      if (account!.id == transaction.toAccountId) {
        return '+';
      } else {
        return '-';
      }
    }
  }
}
