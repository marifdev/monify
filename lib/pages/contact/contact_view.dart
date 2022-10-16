import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:monify/pages/contact/contact_controller.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'contact_model.dart';

class ContactView extends StatefulWidget {
  ContactView({Key? key}) : super(key: key);

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final ContactController _controller;
  late final ContactModel _model;

  @override
  void initState() {
    super.initState();
    _model = ContactModel();
    _controller = ContactController(_model);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: ((context) => _model),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text(LocaleKeys.contactUs).tr(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText: LocaleKeys.email.tr(),
                            border: const OutlineInputBorder(
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
                        maxLines: 10,
                        controller: _messageController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            labelText: LocaleKeys.message.tr(),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            )),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.messageRequired.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _controller.sendMessage(_emailController.text, _messageController.text);
                            _emailController.clear();
                            _messageController.clear();
                            //show success dialog
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(LocaleKeys.success).tr(),
                                    content: const Text(LocaleKeys.messageSent).tr(),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(LocaleKeys.ok).tr(),
                                      )
                                    ],
                                  );
                                });
                          }
                        },
                        child: Consumer<ContactModel>(
                          builder: (context, model, child) {
                            return model.isSending
                                ? Transform.scale(
                                    scale: 0.5,
                                    child: const CircularProgressIndicator(
                                      color: kSecondaryColor,
                                    ))
                                : Text(LocaleKeys.submit.tr());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
