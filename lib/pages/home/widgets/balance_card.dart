import 'package:monify/models/currency.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    Key? key,
    required this.balance,
    required this.income,
    required this.outcome,
    required this.currency,
  }) : super(key: key);

  final double balance;
  final double income;
  final double outcome;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      color: kBackgroundColor,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const Text(
                'Balance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              Text(
                '${currency.symbol} ${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: kBlueColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Income',
                        style: TextStyle(
                          fontSize: 15,
                          color: kTextColor,
                        ),
                      ),
                      Text(
                        '${currency.symbol} ${income.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Outcome',
                        style: TextStyle(
                          fontSize: 15,
                          color: kTextColor,
                        ),
                      ),
                      Text(
                        '${currency.symbol} ${outcome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kErrorColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
