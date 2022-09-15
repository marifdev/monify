import 'package:monify/models/currency.dart';
import 'package:flutter/material.dart';

import 'models/category.dart';

// colors that are used in the app
const kPrimaryColor = Color(0xFF209653);
const kSecondaryColor = Color(0xFFF1B97A);
const kTextColor = Color(0xFF2D2D2D);
const kTextLightColor = Color(0xFF959595);
const kBlueColor = Color(0xFF00B0F0);
const kBackgroundColor = Color(0xFFF2F2F2);
const kErrorColor = Color(0xFFB00020);

// category list that is used in the app
List<Category> kCategoryList = [
  Category(
    name: 'Food',
  ),
  Category(
    name: 'Transport',
  ),
  Category(
    name: 'Shopping',
  ),
  Category(
    name: 'Entertainment',
  ),
  Category(
    name: 'Rent',
  ),
  Category(
    name: 'Salary',
  ),
  Category(
    name: 'Gift',
  ),
  Category(
    name: 'Car',
  ),
  Category(
    name: 'Bills',
  ),
  Category(
    name: 'Investment',
  ),
  Category(
    name: 'Others',
  ),
];

List<Currency> kCurrencyList = [
  Currency(code: 'USD', symbol: '\$'),
  Currency(code: 'EUR', symbol: '€'),
  Currency(code: 'GBP', symbol: '£'),
  Currency(code: 'JPY', symbol: '¥'),
  Currency(code: 'AUD', symbol: '\$'),
  Currency(code: 'CAD', symbol: '\$'),
  Currency(code: 'CHF', symbol: 'Fr'),
  Currency(code: 'CNY', symbol: '¥'),
  Currency(code: 'INR', symbol: '₹'),
  Currency(code: 'KRW', symbol: '₩'),
  Currency(code: 'NZD', symbol: '\$'),
  Currency(code: 'RUB', symbol: '₽'),
  Currency(code: 'TRY', symbol: '₺'),
  Currency(code: 'MXN', symbol: '\$'),
];
