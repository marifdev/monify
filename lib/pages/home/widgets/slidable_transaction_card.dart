import 'package:monify/models/currency.dart';
import 'package:monify/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui' as ui;

import '../../../constants.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';

class SlidableTransactionCard extends StatefulWidget {
  const SlidableTransactionCard({
    Key? key,
    required this.transaction,
    required this.account,
    this.toAccount,
    required this.onDelete,
    required this.onEdit,
    required this.category,
    required this.currency,
  }) : super(key: key);

  final TransactionModel transaction;
  final Account account;
  final Account? toAccount;
  final Future<void> Function() onDelete;
  final void Function() onEdit;
  final Category category;
  final Currency currency;

  @override
  State<SlidableTransactionCard> createState() => _SlidableTransactionCardState();
}

class _SlidableTransactionCardState extends State<SlidableTransactionCard> {
  @override
  void initState() {
    final TransactionModel transaction = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var transaction = widget.transaction;
    return Card(
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                widget.onEdit();
              },
              backgroundColor: kBlueColor,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) {
                widget.onDelete();
              },
              backgroundColor: kErrorColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          isThreeLine: true,
          leading: getLeading(transaction),
          title: Text(transaction.title),
          trailing: getTrailing(transaction),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transaction.type == TransactionType.transfer) ...[
                Text(
                  '${widget.account.name} to ${widget.toAccount!.name}',
                ),
              ],
              if (transaction.type != TransactionType.transfer) ...[
                Text(widget.category.name),
                const SizedBox(height: 3),
                Text(widget.account.name),
              ],
            ],
          ),
        ),
      ),
    );
  }

  getLeading(TransactionModel transaction) {
    switch (transaction.type) {
      case TransactionType.income:
        return const Icon(
          Icons.trending_down,
          textDirection: ui.TextDirection.rtl,
          color: kPrimaryColor,
        );
      case TransactionType.expense:
        return const Icon(
          Icons.trending_up,
          color: kErrorColor,
        );
      case TransactionType.transfer:
        return const Icon(
          Icons.compare_arrows,
          color: kPrimaryColor,
        );
      default:
    }
  }

  getTrailing(TransactionModel transaction) {
    switch (transaction.type) {
      case TransactionType.income:
        return Text('${widget.currency.symbol} ${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: kPrimaryColor));
      case TransactionType.expense:
        return Text('${widget.currency.symbol} ${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: kErrorColor));
      case TransactionType.transfer:
        return Text('${widget.currency.symbol} ${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: kBlueColor));
      default:
    }
  }
}
