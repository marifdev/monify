import 'package:flutter/material.dart';

class ContactModel extends ChangeNotifier {
  String email = '';
  String message = '';
  bool isSending = false;

  bool get getIsSending => isSending;
  set setIsSending(bool value) {
    isSending = value;
    notifyListeners();
  }
}
