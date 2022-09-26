import 'package:easy_localization/easy_localization.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:monify/pages/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'auth_model.dart';
import 'signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AuthController _controller;
  late final AuthModel _model;

  @override
  void initState() {
    super.initState();
    _model = AuthModel();
    _controller = AuthController(_model);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => _model),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(LocaleKeys.login.tr()),
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 100, color: kPrimaryColor),
                const Text(
                  'Monify',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText: LocaleKeys.email.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            )),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.emailRequired.tr();
                          } else if (!_controller.isValidEmail(value)) {
                            return LocaleKeys.emailInvalid.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            labelText: LocaleKeys.password.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            )),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.passwordRequired.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _controller.loginUser(
                              context,
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                        child: Consumer<AuthModel>(
                          builder: (context, model, child) {
                            return model.isLoading
                                ? Transform.scale(
                                    scale: 0.5,
                                    child: const CircularProgressIndicator(
                                      color: kSecondaryColor,
                                    ))
                                : Text(LocaleKeys.login.tr());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [
                //     Expanded(
                //       child: Divider(
                //         color: Colors.black,
                //         thickness: 1,
                //         endIndent: 20,
                //       ),
                //     ),
                //     Text('OR'),
                //     Expanded(
                //       child: Divider(
                //         color: Colors.black,
                //         thickness: 1,
                //         indent: 20,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     ElevatedButton(
                //       onPressed: () {},
                //       child: const Text('Login with Google'),
                //     ),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.dontHaveAccount.tr()),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupView()),
                        );
                      },
                      child: Text(LocaleKeys.register.tr()),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
