import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:monify/constants.dart';
import 'package:monify/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monify/pages/home/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../../ad_helper.dart';
import '../../generated/locale_keys.g.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../transactions/transactions_view.dart';
import 'home_model.dart';
import 'widgets/balance_card.dart';
import 'widgets/bottom_sheet.dart';
import 'widgets/slidable_transaction_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  int transactionCount = 0;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  late final HomeController _controller;
  late final HomeModel _model;

  //init state
  @override
  void initState() {
    super.initState();
    _model = HomeModel();
    _controller = HomeController(_model);
    _controller.init();
    _loadInterstitialAd();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  double calculateBalance() {
    double balance = 0;
    for (var transaction in _model.transactions) {
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
    for (var transaction in _model.transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      }
    }
    return income;
  }

  double calculateOutcome() {
    double outcome = 0;
    for (var element in _model.transactions) {
      if (element.type == TransactionType.expense) {
        outcome += element.amount;
      }
    }
    return outcome;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => _model),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monify'),
          elevation: 0,
        ),
        drawer: AppDrawer(controller: _controller),
        body: Consumer<HomeModel>(
          builder: (context, model, child) {
            return _model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SafeArea(
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
                                  currency: model.user.currency),
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
                                        accounts: model.accounts,
                                        transactions: model.transactions,
                                        sortedTransactions: model.sortedTransactions,
                                        categories: model.categories,
                                        currency: model.user.currency,
                                      ),
                                    ),
                                  ).then((value) => {
                                        _controller.refreshTransactions(),
                                        _controller.refreshCategories(),
                                      });
                                },
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: model.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView(
                                    key: Key(model.transactions.length.toString()),
                                    children: model.sortedTransactions
                                        .map((tx) {
                                          var index = model.sortedTransactions.indexOf(tx);
                                          var category = model.categories.firstWhere(
                                            (element) => element.id == tx.categoryId,
                                            orElse: () => Category(name: LocaleKeys.selectCategory.tr()),
                                          );
                                          var account = model.accounts.firstWhere(
                                            (element) => element.id == tx.accountId,
                                            orElse: () => Account(
                                              id: '',
                                              name: '',
                                              balance: 0,
                                              createdAt: '',
                                              updatedAt: '',
                                            ),
                                          );

                                          var toAccount = model.accounts.firstWhere(
                                            (element) => element.id == tx.toAccountId,
                                            orElse: () => Account(
                                              id: '',
                                              name: '',
                                              balance: 0,
                                              createdAt: '',
                                              updatedAt: '',
                                            ),
                                          );

                                          return Column(
                                            children: [
                                              if (index == 0 ||
                                                  DateFormat.yMd(context.locale.toLanguageTag()).format(tx.date) !=
                                                      DateFormat.yMd(context.locale.toLanguageTag())
                                                          .format(model.sortedTransactions[index - 1].date)) ...[
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
                                                currency: model.user.currency,
                                                toAccount: toAccount,
                                                onDelete: () async {
                                                  model.sortedTransactions.remove(tx);
                                                  await _controller.deleteTransaction(tx);
                                                  _controller.refreshTransactions();
                                                },
                                                onEdit: () {
                                                  showBottomSheet(txToEdit: tx, model: model);
                                                },
                                              ),
                                            ],
                                          );
                                        })
                                        .take(5) // only show 5 transactions
                                        .toList(),
                                  ),
                          ),
                        ),
                        if (_bannerAd != null)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: _bannerAd!.size.width.toDouble(),
                              height: _bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd!),
                            ),
                          ),
                      ],
                    ),
                  );
          },
        ),
        floatingActionButton: Padding(
          padding: _bannerAd == null
              ? const EdgeInsets.only(bottom: 0)
              : EdgeInsets.only(bottom: _bannerAd!.size.height.toDouble()),
          child: FloatingActionButton(
            onPressed: () {
              showBottomSheet(model: _model);
            },
            tooltip: LocaleKeys.addTransaction.tr(),
            child: const Icon(Icons.add),
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
            if (txToEdit == null) {
              await _controller.addTransaction(tx).then((value) => {
                    _controller.refreshTransactions(),
                  });
            } else {
              await _controller.updateTransaction(tx).then((value) => {
                    _controller.refreshTransactions(),
                  });
            }
          },
        );
      },
    ).then((value) => setState(() {
          if (value == true) {
            transactionCount++;
            if (transactionCount == 2 && _interstitialAd == null) {
              _loadInterstitialAd();
            }
            if (transactionCount == 3 && _interstitialAd != null) {
              _interstitialAd!.show();
              transactionCount = 0;
            }
          }
        }));
  }
}
