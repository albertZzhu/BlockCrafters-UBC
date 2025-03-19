import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:coach_link/Views/LoginPage.dart';

class EmailVerifyPage extends StatefulWidget {
  @override
  _EmailVerifyPageState createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    Future sendVerificationEmail() async {
      try {
        final user = FirebaseAuth.instance.currentUser!;
        await user.sendEmailVerification();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? LoginPage()
      : Scaffold(
          body: Center(
            child: Text(
              'Please verify your email.',
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
        );
}
