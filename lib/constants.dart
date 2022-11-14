import 'package:easy_localization/easy_localization.dart';
import 'package:monify/models/currency.dart';
import 'package:flutter/material.dart';

import 'generated/locale_keys.g.dart';
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
    id: '1',
    name: LocaleKeys.food.tr(),
  ),
  Category(
    id: '2',
    name: LocaleKeys.transportation.tr(),
  ),
  Category(
    id: '3',
    name: LocaleKeys.shopping.tr(),
  ),
  Category(
    id: '4',
    name: LocaleKeys.entertainment.tr(),
  ),
  Category(
    id: '5',
    name: LocaleKeys.rent.tr(),
  ),
  Category(
    id: '6',
    name: LocaleKeys.salary.tr(),
  ),
  Category(
    id: '7',
    name: LocaleKeys.gift.tr(),
  ),
  Category(
    id: '8',
    name: LocaleKeys.car.tr(),
  ),
  Category(
    id: '9',
    name: LocaleKeys.bills.tr(),
  ),
  Category(
    id: '10',
    name: LocaleKeys.investment.tr(),
  ),
  Category(
    id: '11',
    name: LocaleKeys.others.tr(),
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
  Currency(code: 'PLN', symbol: 'zł'),
];
