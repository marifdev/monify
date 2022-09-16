import 'package:monify/models/currency.dart';
import 'package:monify/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../../constants.dart';
import '../../../models/category.dart';

class TransactionCard extends StatefulWidget {
  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
    required this.category,
    required this.currency,
  }) : super(key: key);

  final TransactionModel transaction;
  final Future<void> Function() onDelete;
  final void Function() onEdit;
  final Category category;
  final Currency currency;

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
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
          leading: transaction.isIncome
              ? const Icon(
                  Icons.trending_down,
                  textDirection: ui.TextDirection.rtl,
                  color: kPrimaryColor,
                )
              : const Icon(
                  Icons.trending_up,
                  color: kErrorColor,
                ),
          title: Text(transaction.title),
          trailing: transaction.isIncome
              ? Text('${widget.currency.symbol} ${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: kPrimaryColor))
              : Text('${widget.currency.symbol} ${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: kErrorColor)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('yyyy-MM-dd').format(transaction.date)),
              Row(
                children: [
                  Text(widget.category.name),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
