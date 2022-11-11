import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:monify/models/transaction.dart';
import 'package:monify/pages/add_transaction/add_transaction_controller.dart';

import '../../generated/locale_keys.g.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../base/base_model.dart';

class AddTransactionView extends StatefulWidget {
  final BaseModel model;
  const AddTransactionView({Key? key, required this.model}) : super(key: key);

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  TransactionModel _transaction = TransactionModel(
    id: '',
    title: '',
    amount: 0,
    date: DateTime.now(),
    categoryId: '',
    accountId: '',
    type: TransactionType.income,
  );
  final FocusNode amountFocusNode = FocusNode();
  var _formKey = GlobalKey<FormState>();

  late final AddTransactionController _controller;

  void initState() {
    super.initState();
    _controller = AddTransactionController(widget.model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(LocaleKeys.addTransaction.tr()),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoSlidingSegmentedControl(
                  children: {
                    TransactionType.income: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(LocaleKeys.income.tr()),
                    ),
                    TransactionType.expense: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(LocaleKeys.expense.tr()),
                    ),
                    TransactionType.transfer: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(LocaleKeys.transfer.tr()),
                    ),
                  },
                  groupValue: _transaction.type,
                  onValueChanged: (value) {
                    setState(() {
                      _transaction.type = value as TransactionType;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_transaction.date)),
                        keyboardType: TextInputType.none,
                        textInputAction: TextInputAction.next,
                        toolbarOptions: const ToolbarOptions(),
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _selectDate(context);
                        },
                        decoration: InputDecoration(
                            labelText: LocaleKeys.date.tr(),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            )),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.enterDate.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(LocaleKeys.comingSoon.tr()),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.repeat),
                            Text(LocaleKeys.repeat.tr()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                showAccountDropdown(),
                const SizedBox(
                  height: 20,
                ),
                if (_transaction.type != TransactionType.transfer) ...[
                  showCategoryDropdown(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
                if (_transaction.type == TransactionType.transfer) ...[
                  showToAccountDropdown(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
                TextFormField(
                  focusNode: amountFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]+(\.[0-9]*)?(\,[0-9]*)?')),
                  // ],
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) => newValue.copyWith(
                        text: newValue.text.replaceAll(',', '.'),
                      ),
                    ),
                  ],
                  toolbarOptions: const ToolbarOptions(),
                  decoration: InputDecoration(
                      labelText: LocaleKeys.amount.tr(),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.enterValidAmount.tr();
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _transaction.amount = double.parse(value);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  initialValue: _transaction.title,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      labelText: LocaleKeys.title.tr(),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.enterTitle.tr();
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _transaction.title = value;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _controller.addTransaction(_transaction);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(LocaleKeys.save.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField<Category> showCategoryDropdown() {
    return DropdownButtonFormField(
      hint: Text(LocaleKeys.selectCategory.tr()),
      isExpanded: true,
      // value: _transaction.toAccountId != null
      //     ? widget.model.user!.categories!.firstWhere((element) => element.id == _transaction.categoryId)
      //     : null,
      items: widget.model.user!.categories!.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: ((value) {
        setState(() {
          Category valueAsCategory = value as Category;
          _transaction.categoryId = valueAsCategory.id;
        });
      }),
      validator: (value) {
        if (value == null) {
          return LocaleKeys.selectCategoryWarning.tr();
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<Account> showToAccountDropdown() {
    return DropdownButtonFormField(
      hint: Text(LocaleKeys.selectAccount.tr()),
      // value: _transaction.toAccountId != null
      //     ? widget.model.user!.accounts!.firstWhere((element) => element.id == _transaction.toAccountId)
      //     : null,
      isExpanded: true,
      items: widget.model.user!.accounts!.map((account) {
        return DropdownMenuItem(
          value: account,
          child: Text(account.name),
        );
      }).toList(),
      onChanged: ((value) {
        setState(() {
          Account valueAsAccount = value as Account;
          _transaction.toAccountId = valueAsAccount.id;
        });
      }),
      validator: (value) {
        if (value == null) {
          return LocaleKeys.selectAccountWarning.tr();
        } else if (value.id == _transaction.accountId) {
          return LocaleKeys.selectDifferentAccount.tr();
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<Account> showAccountDropdown() {
    return DropdownButtonFormField(
      hint: Text(LocaleKeys.selectAccount.tr()),
      // value: _transaction.accountId != null
      //     ? widget.accounts.firstWhere((element) => element.id == _transaction.accountId)
      //     : null,
      isExpanded: true,
      items: widget.model.user!.accounts!.map((account) {
        return DropdownMenuItem(
          value: account,
          child: Text(account.name),
        );
      }).toList(),
      onChanged: ((value) {
        setState(() {
          Account valueAsAccount = value as Account;
          _transaction.accountId = valueAsAccount.id;
        });
      }),
      validator: (value) {
        if (value == null) {
          return LocaleKeys.selectAccountWarning.tr();
        } else if (value.id == _transaction.toAccountId) {
          return LocaleKeys.selectDifferentAccount.tr();
        }
        return null;
      },
    );
  }

  void _selectDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    ).then((DateTime? date) {
      if (date != null) {
        setState(() {
          _transaction.date = DateTime(
              date.year, date.month, date.day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
        });
      }
    });
  }
}
