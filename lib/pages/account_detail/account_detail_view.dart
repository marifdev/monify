import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/account.dart';
import '../../widgets/transaction_card.dart';
import 'account_detail_controller.dart';
import 'account_detail_model.dart';

class AccountDetailView extends StatefulWidget {
  final Account account;
  const AccountDetailView({Key? key, required this.account}) : super(key: key);
  @override
  State<AccountDetailView> createState() => _AccountDetailViewState();
}

class _AccountDetailViewState extends State<AccountDetailView> {
  late final AccountDetailController _controller;
  late final AccountDetailModel _model;

  //init state
  @override
  void initState() {
    super.initState();
    _model = AccountDetailModel();
    _controller = AccountDetailController(_model, widget.account);
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => _model),
      child: Consumer<AccountDetailModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(model.account.name),
            ),
            body: model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ))
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
          );
        },
      ),
    );
  }
}
