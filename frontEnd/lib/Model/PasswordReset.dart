import 'package:firebase_auth/firebase_auth.dart';

class PasswordReset {
  static Future resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
