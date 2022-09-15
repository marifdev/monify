import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../utils/shared_pref.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({Key? key}) : super(key: key);
  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  Category _category = Category(
    name: '',
  );

  late List<TransactionModel> transactions;
  late List<Category> categories;
  var userId = FirebaseAuth.instance.currentUser!.uid;
  var isLoading = true;

  //init state
  @override
  void initState() {
    super.initState();
    _getCategories();
    _getTransactions();
  }

  //get categories from firebase
  void _getCategories() async {
    FirestoreMethods().getCategories(userId).then((value) {
      setState(() {
        categories = value
            .map((e) {
              return Category.fromJson(e.data() as Map<String, dynamic>);
            })
            .toList()
            .cast<Category>();
        isLoading = false;
      });
    });
  }

  //get transactions from firebase
  void _getTransactions() {
    // get Transactions from firebase
    FirestoreMethods().getTransactions(userId).then((value) {
      setState(() {
        transactions = value
            .map((e) {
              return TransactionModel.fromJson(e.data() as Map<String, dynamic>);
            })
            .toList()
            .cast<TransactionModel>();
      });
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
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
                      child: Wrap(children: [
                        Form(
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
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                      labelText: 'Category name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      )),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _category.name = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          FirestoreMethods().addCategory(category: _category, uid: userId);
                                          _getCategories();
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index].name),
                  trailing: IconButton(
                    color: kErrorColor,
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        //check if there is any transaction in this category
                        if (transactions != []) {
                          var hasTransaction =
                              transactions.any((element) => element.categoryId == categories[index].id);
                          if (hasTransaction) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete category'),
                                  content: const Text(
                                      'There is a transaction in this category. You can not delete this category'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete category'),
                                  content: const Text('Are you sure you want to delete this category?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        setState(() {
                                          FirestoreMethods().deleteCategory(categories[index].id!, userId);
                                          _getCategories();
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
