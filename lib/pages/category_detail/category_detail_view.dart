import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monify/models/transaction.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/category.dart';
import '../../widgets/transaction_card.dart';
import 'category_detail_controller.dart';
import 'category_detail_model.dart';

class CategoryDetailView extends StatefulWidget {
  final Category category;
  const CategoryDetailView({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  late final CategoryDetailController _controller;
  late final CategoryDetailModel _model;

  //init state
  @override
  void initState() {
    super.initState();
    _model = CategoryDetailModel();
    _controller = CategoryDetailController(_model, widget.category);
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => _model),
      child: Consumer<CategoryDetailModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(model.category.name),
            ),
            body: Center(
              child: model.isLoading
                  ? const CircularProgressIndicator(
                      color: kPrimaryColor,
                    )
                  : ListView.builder(
                      itemCount: model.transactions.length,
                      itemBuilder: (context, index) {
                        var transaction = model.transactions[index];
                        return Column(
                          children: [
                            if (index == 0 ||
                                DateFormat('dd MMMM yyyy').format(transaction.date) !=
                                    DateFormat('dd MMMM yyyy').format(model.transactions[index - 1].date)) ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, top: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      DateFormat('dd MMMM yyyy').format(transaction.date),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: kTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            TransactionCard(transaction: transaction),
                          ],
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
