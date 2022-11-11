import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monify/constants.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:monify/pages/accounts/accounts_view.dart';
import 'package:monify/pages/home/home_view.dart';
import 'package:monify/pages/settings/settings_view.dart';
import 'package:provider/provider.dart';

import '../../ad_helper.dart';
import '../add_transaction/add_transaction_view.dart';
import '../contact/contact_view.dart';
import '../home/widgets/app_drawer.dart';
import '../statistics/statistics_view.dart';
import 'base_controller.dart';
import 'base_model.dart';

class BaseView extends StatefulWidget {
  const BaseView({Key? key}) : super(key: key);

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  BannerAd? _bannerAd;
  int _pageIndex = 0;
  int addedTransaction = 0;

  InterstitialAd? _interstitialAd;

  late final BaseController _controller;
  late final BaseModel _model;

  @override
  void initState() {
    super.initState();
    _model = BaseModel();
    _controller = BaseController(_model);
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

  getPage(int index, BaseModel model) {
    switch (index) {
      case 2:
        return AccountsView(model: model);
      case 0:
        return MyHomePage(model: model);
      case 1:
        return StatisticsView(model: model);
      case 3:
        return SettingsView(model: model);
      default:
        return MyHomePage(model: model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => _model),
      child: Scaffold(
          body: Column(
            children: [
              Consumer<BaseModel>(
                builder: (context, model, child) {
                  return Container(
                    height: _bannerAd != null
                        ? MediaQuery.of(context).size.height - 140
                        : MediaQuery.of(context).size.height - 100,
                    child: model.user != null ? getPage(_pageIndex, model) : null,
                  );
                },
              ),
              if (_bannerAd != null)
                SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
          bottomNavigationBar: getFooter(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionView(model: _model)))
                  .then((value) => {
                        setState(
                          () {
                            addedTransaction++;
                            if (addedTransaction == 2 && _interstitialAd == null) {
                              _loadInterstitialAd();
                            }
                            if (addedTransaction == 3 && _interstitialAd != null) {
                              _interstitialAd!.show();
                              addedTransaction = 0;
                            }
                          },
                        )
                      });
            },
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked),
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [
      Icons.calendar_today,
      Icons.pie_chart,
      Icons.account_balance,
      Icons.settings,
    ];

    return AnimatedBottomNavigationBar(
      activeColor: kPrimaryColor,
      splashColor: kPrimaryColor,
      inactiveColor: Colors.black.withOpacity(0.5),
      icons: iconItems,
      activeIndex: _pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(index);
      },
      //other params
    );
  }

  selectedTab(index) {
    setState(() {
      _pageIndex = index;
    });
  }
}
