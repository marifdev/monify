import 'package:firebase_auth/firebase_auth.dart';
import 'package:monify/pages/contact/contact_model.dart';
import '../../resources/firestore_methods.dart';

class ContactController {
  final ContactModel _model;
  ContactController(this._model);

  // send message
  Future<void> sendMessage(String email, String message) async {
    _model.setIsSending = true;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirestoreMethods().sendMessage(userId, email, message);
    _model.setIsSending = false;
  }

  bool isValidEmail(String value) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
  }
}
