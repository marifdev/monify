import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:monify/pages/categories/categories_controller.dart';
import 'package:flutter/material.dart';
import 'package:monify/pages/category_detail/category_detail_view.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/category.dart';
import 'categories_model.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({Key? key}) : super(key: key);
  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  Category _category = Category(
    name: '',
  );

  late final CategoriesController _controller;
  late final CategoriesModel _model;

  //init state
  @override
  void initState() {
    super.initState();
    _model = CategoriesModel();
    _controller = CategoriesController(_model);
    _controller.init();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => _model),
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.categories.tr()),
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
                  builder: addCategoryBottomSheet,
                );
              },
            ),
          ],
        ),
        body: Consumer<CategoriesModel>(
          builder: (context, model, child) {
            return model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ))
                : ListView.builder(
                    itemCount: model.categories.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  deleteCategory(model, index, context);
                                },
                                backgroundColor: kErrorColor,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: LocaleKeys.delete.tr(),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CategoryDetailView(category: model.categories[index])));
                            },
                            child: ListTile(
                              title: Text(model.categories[index].name),
                            ),
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  void deleteCategory(CategoriesModel model, int index, BuildContext context) {
    if (model.transactions != []) {
      var hasTransaction = model.transactions.any((element) => element.categoryId == model.categories[index].id);
      if (hasTransaction) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(LocaleKeys.delete.tr()),
              content: Text(LocaleKeys.deleteCategoryError.tr()),
              actions: <Widget>[
                TextButton(
                  child: Text(LocaleKeys.ok.tr()),
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
              title: Text(LocaleKeys.delete.tr()),
              content: Text(LocaleKeys.confirmDelete.tr()),
              actions: [
                TextButton(
                  child: Text(LocaleKeys.cancel.tr()),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(LocaleKeys.delete.tr()),
                  onPressed: () {
                    _controller.deleteCategory(_model.userId, model.categories[index].id!);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Widget addCategoryBottomSheet(BuildContext context) {
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
                          _controller.addCategory(_model.userId, _category);
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
  }
}
