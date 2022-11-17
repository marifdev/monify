import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:monify/constants.dart';
import 'package:monify/models/account.dart';
import 'package:monify/models/category.dart';
import 'package:monify/pages/base/base_model.dart';

import '../../generated/locale_keys.g.dart';
import '../../models/transaction.dart';
import 'add_transaction_controller.dart';

class AddTransaction extends StatefulWidget {
  final BaseModel model;
  const AddTransaction({Key? key, required this.model}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  String _amountValue = '0';
  bool dateSelected = false;
  bool categorySelected = true;
  bool noteSelected = false;
  bool repeatSelected = false;
  late TransactionModel transaction;
  late Account selectedAccount;
  late Category selectedCategory;
  late final AddTransactionController _controller;

  //initstate
  @override
  void initState() {
    super.initState();
    selectedAccount = widget.model.user.accounts[0];
    selectedCategory = widget.model.user.categories.where((element) => element.name == 'Others').first;
    transaction = TransactionModel(
      id: '',
      title: '',
      amount: 0,
      date: DateTime.now(),
      categoryId: selectedCategory.id,
      accountId: selectedAccount.id,
      type: TransactionType.expense,
    );
    _controller = AddTransactionController(widget.model);
  }

  var noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.addTransaction.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl(
                children: {
                  TransactionType.expense: Text(LocaleKeys.expense.tr()),
                  TransactionType.income: Text(LocaleKeys.income.tr()),
                  TransactionType.transfer: Text(LocaleKeys.transfer.tr()),
                },
                groupValue: transaction.type,
                onValueChanged: (value) {
                  setState(() {
                    transaction.type = value as TransactionType;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                //account selector dropdown
                SizedBox(
                  child: PopupMenuButton(
                    position: PopupMenuPosition.under,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(getIconByAccounType(selectedAccount.type)),
                          const SizedBox(width: 8),
                          Text(selectedAccount.name),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      for (var account in widget.model.user.accounts)
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(getIconByAccounType(account.type)),
                              const SizedBox(width: 8),
                              Text(account.name),
                            ],
                          ),
                          value: account,
                          onTap: () {
                            setState(() {
                              selectedAccount = account;
                              transaction.accountId = account.id;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                //date picker
                SizedBox(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: transaction.date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          transaction.date = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd').format(transaction.date)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            //amount input
            SizedBox(
              width: double.infinity,
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.amount.tr(),
                    ),
                    Text(
                      _amountValue.toString(),
                      style: TextStyle(fontSize: 48),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        dateSelected = true;
                        categorySelected = false;
                        noteSelected = false;
                        repeatSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                      ),
                      child: Center(
                        child: Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_outlined),
                            Text(LocaleKeys.date.tr()),
                            if (dateSelected) Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        dateSelected = false;
                        categorySelected = true;
                        noteSelected = false;
                        repeatSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                      ),
                      child: Center(
                        child: Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.dataset_outlined),
                            Text(LocaleKeys.categories.tr()),
                            if (categorySelected) Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        dateSelected = false;
                        categorySelected = false;
                        noteSelected = true;
                        repeatSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                      ),
                      child: Center(
                        child: Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.note_alt_outlined),
                            Text(LocaleKeys.note.tr()),
                            if (noteSelected) Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        dateSelected = false;
                        categorySelected = false;
                        noteSelected = false;
                        repeatSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                      ),
                      child: Center(
                        child: Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.repeat),
                            Text(LocaleKeys.repeat.tr()),
                            if (repeatSelected) Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            if (dateSelected)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                      child: Text(DateFormat('dd MMM y').format(transaction.date)),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: transaction.date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            transaction.date = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                      child: Text(DateFormat('HH:mm').format(transaction.date)),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(transaction.date),
                        );
                        if (time != null) {
                          setState(() {
                            transaction.date = DateTime(transaction.date.year, transaction.date.month,
                                transaction.date.day, time.hour, time.minute);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            if (categorySelected)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.model.user.categories.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        if (index == 0) ...[
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              // setState(() {
                              //   transaction.categoryId = kCategoryList[index].id;
                              // });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                // color: transaction.categoryId == kCategoryList[index].id
                                //     ? kPrimaryColor
                                //     : Colors.black.withOpacity(0.1),
                                border: Border.all(color: kPrimaryColor),
                                borderRadius: BorderRadius.circular(8),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  LocaleKeys.edit.tr(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              transaction.categoryId = widget.model.user.categories[index].id;
                              selectedCategory = widget.model.user.categories[index];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: transaction.categoryId == widget.model.user.categories[index].id
                                  ? kPrimaryColor
                                  : Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                widget.model.user.categories[index].name,
                                style: TextStyle(
                                  color: transaction.categoryId == widget.model.user.categories[index].id
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    );
                  },
                ),
              ),
            if (noteSelected)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                  color: Colors.black.withOpacity(0.1),
                ),
                child: TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: LocaleKeys.note.tr(),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    transaction.title = value;
                  },
                ),
              ),
            if (repeatSelected)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                      child: Text(LocaleKeys.comingSoon.tr()),
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            //number buttons
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2 / 1,
              ),
              children: [
                for (int i = 1; i <= 9; i++)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                    child: Text(i.toString(), style: const TextStyle(fontSize: 20)),
                    onPressed: () {
                      setState(() {
                        if (_amountValue == '0') {
                          _amountValue = i.toString();
                        } else {
                          _amountValue += i.toString();
                        }
                      });
                    },
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  child: const Text('.', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    setState(() {
                      if (!_amountValue.contains('.')) {
                        // amountController.text += '.';
                        _amountValue += '.';
                      }
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  child: const Text('0', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    setState(() {
                      if (_amountValue != '0') {
                        // amountController.text += '0';
                        _amountValue += '0';
                      }
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  child: const Icon(Icons.backspace_outlined),
                  onPressed: () {
                    setState(() {
                      if (_amountValue.length > 1) {
                        _amountValue = _amountValue.substring(0, _amountValue.length - 1);
                      } else {
                        _amountValue = '0';
                      }
                    });
                  },
                ),
              ],
            ),
            //save button
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                shape: BoxShape.rectangle,
                color: kPrimaryColor,
              ),
              child: InkWell(
                onTap: () async {
                  if (_amountValue != '0') {
                    transaction.amount = double.parse(_amountValue);
                    transaction.title == '' ? transaction.title = selectedCategory.name : transaction.title;
                    await _controller.addTransaction(transaction);
                    Navigator.pop(context, true);
                  }
                },
                child: Center(
                  child: Text(
                    LocaleKeys.save.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  IconData? getIconByAccounType(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.payments_outlined;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
