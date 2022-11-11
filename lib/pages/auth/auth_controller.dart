import 'package:monify/pages/auth/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:monify/pages/base/base_view.dart';

import '../../resources/auth_methods.dart';
import '../home/home_view.dart';

class AuthController {
  final AuthModel _model;

  AuthController(this._model);

  void signupUser(BuildContext context, String email, String password) async {
    _model.setIsLoading = true;
    String res = await AuthMethods().signUpUser(email, password);
    if (res == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BaseView(),
        ),
      );
      _model.setIsLoading = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
      _model.setIsLoading = false;
    }
  }

  void loginUser(BuildContext context, String email, String password) async {
    _model.setIsLoading = true;
    String res = await AuthMethods().loginUser(
      email: email,
      password: password,
    );
    if (res == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BaseView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
        ),
      );
      _model.setIsLoading = false;
    }
  }

  bool isValidEmail(String value) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
  }
}
