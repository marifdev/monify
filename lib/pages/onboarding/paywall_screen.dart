import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monify/constants.dart';
import 'package:monify/pages/auth/login_view.dart';
import 'package:monify/pages/base/base_controller.dart';
import 'package:monify/resources/firestore_methods.dart';
import 'package:monify/utils/shared_methods.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../base/base_model.dart';

class PaywallScreen extends StatefulWidget {
  final BaseModel model;
  const PaywallScreen({Key? key, required this.model}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isPurchasing = false;

  late final BaseController _baseController;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                'Get access to all features and ad-free experience',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: kPrimaryColor,
                    ),
                textAlign: TextAlign.left,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check, color: kPrimaryColor),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlimited Accounts',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add as many accounts as you want',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(color: Colors.black.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check, color: kPrimaryColor),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlimited Categories',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add as many categories as you want',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(color: Colors.black.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check, color: kPrimaryColor),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Ads',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enjoy a clean and ad-free experience',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(color: Colors.black.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  setState(() {
                    _isPurchasing = true;
                  });
                  try {
                    await Purchases.purchaseProduct('monify_monthly_subscription');
                    await FirestoreMethods().updateUserSubscriptionStatus(FirebaseAuth.instance.currentUser!.uid, true);
                    _baseController = BaseController(widget.model);
                    await _baseController.init();
                    Navigator.of(context).pop();
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      _isPurchasing = false;
                    });
                  }
                },
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Get Monify Premium free for 7 days',
                          style: Theme.of(context).textTheme.button?.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'After 7 days, you will be charged \$4.99 per month',
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isPurchasing)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
