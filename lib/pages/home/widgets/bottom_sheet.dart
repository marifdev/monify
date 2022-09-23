import 'package:monify/constants.dart';
import 'package:monify/models/category.dart';
import 'package:monify/models/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../models/account.dart';
import '../../../resources/firestore_methods.dart';

class BottomSheetContainer extends StatefulWidget {
  const BottomSheetContainer({
    Key? key,
    required this.transactions,
    required this.accounts,
    required this.categories,
    this.tx,
    required this.onSave,
  }) : super(key: key);

  final List<TransactionModel> transactions;
  final List<Account> accounts;
  final List<Category> categories;
  final TransactionModel? tx;
  final Future<void> Function(dynamic tx) onSave;

  @override
  State<BottomSheetContainer> createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  late TransactionModel _transaction;
  final FocusNode amountFocusNode = FocusNode();
  final firestoreMethods = FirestoreMethods();
  var userId = FirebaseAuth.instance.currentUser!.uid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoading = false;
  TransactionType transactionType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.tx != null) {
      _transaction = widget.tx!;
    } else {
      _transaction = TransactionModel(
        id: '0',
        title: '',
        amount: 0,
        date: DateTime.now(),
        categoryId: null,
        type: transactionType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: DefaultTabController(
        length: 3,
        initialIndex: _transaction.type.index,
        child: Container(
          decoration: const BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.25,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                    ),
                    child: Container(
                      height: 5.0,
                      decoration: const BoxDecoration(
                        color: kTextLightColor,
                        borderRadius: BorderRadius.all(Radius.circular(2.5)),
                      ),
                    ),
                  ),
                ),
                TabBar(
                  labelColor: kTextColor,
                  unselectedLabelColor: kTextColor.withOpacity(0.3),
                  indicatorColor: kPrimaryColor,
                  onTap: (index) {
                    setState(() {
                      _transaction.type = TransactionType.values[index];
                    });
                  },
                  tabs: const [
                    Tab(
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Income',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Transfer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Wrap(
                  children: [
                    isLoading
                        ? const LinearProgressIndicator()
                        : Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextFormField(
                                    initialValue: _transaction.title,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                        labelText: 'Title',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        )),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a title';
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
                                  TextFormField(
                                    focusNode: amountFocusNode,
                                    initialValue: widget.tx != null ? _transaction.amount.toString() : null,
                                    // keyboardType: const TextInputType.numberWithOptions(signed: true),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]+(\.[0-9]*)?')),
                                    ],
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                        labelText: 'Amount',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        )),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                        return 'Please enter a valid amount';
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
                                  if (_transaction.type != TransactionType.transfer) ...[
                                    _transaction.categoryId != null
                                        ? showCategorySelectedDropdown()
                                        : showCategoryEmptyDropdown(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                  _transaction.accountId != null
                                      ? showAccountSelectedDropdown()
                                      : showAccountEmptyDropdown(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (_transaction.type == TransactionType.transfer) ...[
                                    _transaction.categoryId != null
                                        ? showToAccountSelectedDropdown()
                                        : showToAccountEmptyDropdown(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                  TextFormField(
                                    controller:
                                        TextEditingController(text: DateFormat('yyyy-MM-dd').format(_transaction.date)),
                                    keyboardType: TextInputType.none,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            _selectDate(context);
                                          },
                                          icon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                        labelText: 'Date',
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        )),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a date';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          widget.onSave(_transaction);
                                        }
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField<Category> showCategoryEmptyDropdown() {
    return DropdownButtonFormField(
      hint: const Text('Select Category'),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      isExpanded: true,
      items: widget.categories.map((category) {
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
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<Category> showCategorySelectedDropdown() {
    return DropdownButtonFormField(
      hint: const Text('Select Category'),
      value: widget.categories.firstWhere((element) => element.id == _transaction.categoryId),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      isExpanded: true,
      items: widget.categories.map((category) {
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
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<Account> showAccountEmptyDropdown() {
    return DropdownButtonFormField(
      hint: const Text('Select Account'),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      isExpanded: true,
      items: widget.accounts.map((account) {
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
          return 'Please select an account';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<Account> showToAccountSelectedDropdown() {
    return DropdownButtonFormField(
      hint: const Text('Select Account'),
      value: widget.accounts.firstWhere((element) => element.id == _transaction.toAccountId),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      isExpanded: true,
      items: widget.accounts.map((account) {
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
          return 'Please select an account';
        } else if (value.id == _transaction.accountId) {
          return 'Please select a different account';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<Account> showToAccountEmptyDropdown() {
    return DropdownButtonFormField(
      hint: const Text('To Account'),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      isExpanded: true,
      items: widget.accounts.map((account) {
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
          return 'Please select an account';
        } else if (value.id == _transaction.accountId) {
          return 'Please select a different account';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<Account> showAccountSelectedDropdown() {
    return DropdownButtonFormField(
      hint: const Text('Select Account'),
      value: widget.accounts.firstWhere((element) => element.id == _transaction.accountId),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      isExpanded: true,
      items: widget.accounts.map((account) {
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
          return 'Please select an account';
        } else if (value.id == _transaction.toAccountId) {
          return 'Please select a different account';
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
