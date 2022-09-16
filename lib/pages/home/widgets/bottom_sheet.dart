import 'package:monify/constants.dart';
import 'package:monify/models/category.dart';
import 'package:monify/models/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../resources/firestore_methods.dart';

class BottomSheetContainer extends StatefulWidget {
  const BottomSheetContainer({
    Key? key,
    required this.transactions,
    required this.categories,
    this.tx,
    required this.onSave,
  }) : super(key: key);

  final List<TransactionModel> transactions;
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
        isIncome: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        width: MediaQuery.of(context).size.width - 10,
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
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
                          _transaction.categoryId != null
                              ? DropdownButtonFormField(
                                  hint: const Text('Select Category'),
                                  value:
                                      widget.categories.firstWhere((element) => element.id == _transaction.categoryId),
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
                                )
                              : DropdownButtonFormField(
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
                                ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_transaction.date)),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Income',
                                style: TextStyle(
                                  color: kTextLightColor,
                                  fontSize: 16,
                                ),
                              ),
                              Switch(
                                  value: _transaction.isIncome,
                                  onChanged: (value) {
                                    setState(() {
                                      _transaction.isIncome = value;
                                    });
                                  }),
                            ],
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
      ),
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
