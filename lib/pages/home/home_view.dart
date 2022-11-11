import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:monify/constants.dart';
import 'package:monify/pages/base/base_model.dart';
import 'package:monify/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monify/pages/home/widgets/app_drawer.dart';
import 'package:monify/utils/shared_methods.dart';
import 'package:provider/provider.dart';

import '../../ad_helper.dart';
import '../../generated/locale_keys.g.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../add_transaction/add_transaction_view.dart';
import '../contact/contact_view.dart';
import '../transactions/transactions_view.dart';
import 'home_model.dart';
import 'widgets/balance_card.dart';
import 'widgets/bottom_sheet.dart';
import 'widgets/slidable_transaction_card.dart';

class MyHomePage extends StatefulWidget {
  final BaseModel model;
  const MyHomePage({Key? key, BannerAd? bannerAd, required this.model}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int transactionCount = 0;

  //init state
  @override
  void initState() {
    super.initState();
  }

  double calculateBalance() {
    double balance = 0;
    for (var transaction in widget.model.user!.transactions!) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  double calculateIncome() {
    double income = 0;
    for (var transaction in widget.model.user!.transactions!) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      }
    }
    return income;
  }

  double calculateOutcome() {
    double outcome = 0;
    for (var element in widget.model.user!.transactions!) {
      if (element.type == TransactionType.expense) {
        outcome += element.amount;
      }
    }
    return outcome;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => widget.model),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monify'),
          elevation: 0,
          actions: [
            // contact us
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactView()));
              },
              icon: const Icon(Icons.mail_outline),
            ),
          ],
        ),
        // drawer: AppDrawer(controller: _controller, interstitialAd: _interstitialAd),
        // onDrawerChanged: (isOpened) {
        //   if (!isOpened && _interstitialAd != null) {
        //     _loadInterstitialAd();
        //   }
        // },
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    color: kPrimaryColor,
                  ),
                  Positioned(
                    bottom: -75,
                    child: BalanceCard(
                        balance: calculateBalance(),
                        income: calculateIncome(),
                        outcome: calculateOutcome(),
                        currency: widget.model.user!.currency),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.recentTransactions.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      child: Text(
                        LocaleKeys.seeAll.tr(),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionsView(
                              accounts: widget.model.user!.accounts!,
                              transactions: widget.model.user!.transactions!,
                              sortedTransactions: widget.model.user!.transactions!,
                              categories: widget.model.user!.categories!,
                              currency: widget.model.user!.currency,
                            ),
                          ),
                        ).then((value) => {widget.model.setUser(widget.model.user!)});
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView(
                    key: Key(widget.model.user!.transactions!.length.toString()),
                    children: widget.model.user!.transactions!
                        .map((tx) {
                          var index = widget.model.user!.transactions!.indexOf(tx);
                          var category = widget.model.user!.categories!.firstWhere(
                            (element) => element.id == tx.categoryId,
                            orElse: () => Category(name: LocaleKeys.selectCategory.tr()),
                          );
                          var account = widget.model.user!.accounts!.firstWhere(
                            (element) => element.id == tx.accountId,
                            orElse: () => Account(
                              id: '',
                              name: '',
                              balance: 0,
                              createdAt: '',
                              updatedAt: '',
                              type: AccountType.cash,
                            ),
                          );

                          var toAccount = widget.model.user!.accounts!.firstWhere(
                            (element) => element.id == tx.toAccountId,
                            orElse: () => Account(
                              id: '',
                              name: '',
                              balance: 0,
                              createdAt: '',
                              updatedAt: '',
                              type: AccountType.cash,
                            ),
                          );
                          return Column(
                            children: [
                              if (index == 0 ||
                                  DateFormat.yMd(context.locale.toLanguageTag()).format(tx.date) !=
                                      DateFormat.yMd(context.locale.toLanguageTag())
                                          .format(widget.model.user!.transactions![index - 1].date)) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat.yMd(context.locale.toLanguageTag()).format(tx.date),
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
                              SlidableTransactionCard(
                                account: account,
                                transaction: tx,
                                category: category,
                                currency: widget.model.user!.currency,
                                toAccount: toAccount,
                                onDelete: () async {
                                  widget.model.user!.transactions!.remove(tx);
                                  widget.model.setUser(widget.model.user!);
                                  SharedMethods(widget.model).deleteTransaction(tx);
                                },
                                onEdit: () {},
                              ),
                            ],
                          );
                        })
                        .take(10) // only show 10 transactions
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showBottomSheet({TransactionModel? txToEdit, required HomeModel model}) {
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
        return BottomSheetContainer(
          accounts: model.accounts,
          transactions: model.transactions,
          tx: txToEdit,
          categories: model.categories,
          onSave: (tx) async {
            Navigator.pop(context, true);
            // if (txToEdit == null) {
            //   await _controller.addTransaction(tx).then((value) => {
            //         _controller.refreshTransactions(),
            //       });
            // } else {
            //   await _controller.updateTransaction(tx).then((value) => {
            //         _controller.refreshTransactions(),
            //       });
            // }
          },
        );
      },
    ).then((value) => setState(() {
          // if (value == true) {
          //   transactionCount++;
          //   if (transactionCount == 2 && _interstitialAd == null) {
          //     // _loadInterstitialAd();
          //   }
          //   if (transactionCount == 3 && _interstitialAd != null) {
          //     // _interstitialAd!.show();
          //     transactionCount = 0;
          //   }
          // }
        }));
  }
}
