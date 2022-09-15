import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monify/constants.dart';
import 'package:monify/pages/auth/login_view.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:launch_review/launch_review.dart';

import '../../ad_helper.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../models/user.dart';
import '../categories/categories_view.dart';
import '../settings/settings_view.dart';
import '../transactions/transactions_view.dart';
import 'widgets/balance_card.dart';
import 'widgets/bottom_sheet.dart';
import 'widgets/transaction_card.dart';

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
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
              );
            },
          );

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

  final userId = FirebaseAuth.instance.currentUser!.uid;

  List<TransactionModel> transactions = [];

  List<TransactionModel> sortedTransactions = [];

  List<Category> savedCategories = [];
  var isLoading = false;
  UserModel? user;

  //init state
  @override
  void initState() {
    super.initState();
    _getTransactions();
    _getCategories();
    _getUser();
    _loadInterstitialAd();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
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

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _getUser() async {
    setState(() {
      isLoading = true;
    });
    final _user = await FirestoreMethods().getUser(userId);
    setState(() {
      user = _user;
      isLoading = false;
    });
  }

  double calculateBalance() {
    double balance = 0;
    for (var transaction in transactions) {
      if (transaction.isIncome) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  double calculateIncome() {
    double income = 0;
    for (var transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      }
    }
    return income;
  }

  double calculateOutcome() {
    double outcome = 0;
    for (var element in transactions) {
      if (!element.isIncome) {
        outcome += element.amount;
      }
    }
    return outcome;
  }

  @override
  Widget build(BuildContext context) {
    sortedTransactions = transactions.toList()..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monify'),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: kPrimaryColor,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 50,
                ),
                Text(
                  'Monify',
                  style: TextStyle(color: Colors.white, fontSize: 50),
                ),
              ],
            ),
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: const Text(
                    'Categories',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsView(),
                      ),
                    ).then((value) => _getUser());
                  },
                ),
                ListTile(
                  title: const Text(
                    'Rate us',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    LaunchReview.launch();
                  },
                ),
                ListTile(
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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
                          currency: user!.currency),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        child: const Text('See All'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionsView(
                                transactions: transactions,
                                sortedTransactions: sortedTransactions,
                                savedCategories: savedCategories,
                                currency: user!.currency,
                              ),
                            ),
                          ).then((value) => setState(() {
                                _getTransactions();
                                _getCategories();
                              }));
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView(
                            key: Key(transactions.length.toString()),
                            children: sortedTransactions
                                .map((tx) {
                                  var category = savedCategories.firstWhere(
                                    (element) => element.id == tx.categoryId,
                                    orElse: () => Category(name: 'Select a category'),
                                  );

                                  return TransactionCard(
                                    transaction: tx,
                                    category: category,
                                    currency: user!.currency,
                                    onDelete: () {
                                      setState(() {
                                        transactions.remove(tx);
                                        FirestoreMethods().deleteTransaction(tx.id, userId);
                                      });
                                    },
                                    onEdit: () {
                                      _showBottomSheet(txToEdit: tx);
                                    },
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
                    child: Container(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Padding(
        padding: _bannerAd == null
            ? const EdgeInsets.only(bottom: 0)
            : EdgeInsets.only(bottom: _bannerAd!.size.height.toDouble()),
        child: FloatingActionButton(
          onPressed: () {
            _showBottomSheet();
          },
          tooltip: 'Add Transaction',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _getTransactions() {
    setState(() {
      isLoading = true;
    });
    // get Transactions from firebase
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('transactions')
        .get()
        .then((value) {
      setState(() {
        this.transactions = value.docs
            .map((e) {
              return TransactionModel.fromJson(e.data());
            })
            .toList()
            .cast<TransactionModel>();
        isLoading = false;
      });
    });
  }

  void _getCategories() {
    setState(() {
      isLoading = true;
    });
    // get Categories from firebase
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('categories')
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        for (var category in kCategoryList) {
          var docRef = await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('categories')
              .add(category.toJson());
          category.id = docRef.id;
          docRef.set(category.toJson());
        }
      }
      setState(() {
        this.savedCategories = value.docs
            .map((e) {
              return Category.fromJson(e.data());
            })
            .toList()
            .cast<Category>();
        isLoading = false;
      });
    });
  }

  void _showBottomSheet({TransactionModel? txToEdit}) {
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
          transactions: transactions,
          tx: txToEdit,
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
            _getTransactions();
            _getCategories();
          }
        }));
  }
}
