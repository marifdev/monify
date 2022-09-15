import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier {
  bool isLoading = false;
  bool get getIsLoading => isLoading;
  set setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
