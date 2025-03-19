import 'package:cloud_firestore/cloud_firestore.dart';

import 'StartPage.dart';
import 'package:flutter/material.dart';
import 'newProfile.dart';
import 'onboarding.dart';
import 'resetPassword.dart';
import 'StartPage.dart';
import 'HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:coach_link/Model/UpdateUser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "";
  String _password = "";
  bool _success = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  Future<void> redirect() async {
    final currentuser =
        await UpdateUser(
          uid: FirebaseAuth.instance.currentUser!.uid,
        ).getCoach();

    if (currentuser.sport == "" || currentuser.sport == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnboardingPage()),
        (route) => route == null,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
        (route) => route == null,
      );
    }
  }

  void loginAction() async {
    try {
      final UserCredential credential = (await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      ));
      user = credential.user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Please try again.")),
      );
    }
    if (user == null) {
      setState(() {
        _success = false;
        print("Sign in failed");
      });
    } else {
      setState(() {
        _success = true;
        print("Sign in success");
        print(user!.uid);
        //TODO: need to add check to see if onbaording has been completed. If it has jump to the main page not onboarding.
        redirect();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("User Login")),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                  width: 200,
                  height: 150,
                  child: Image.asset('assets/banner.png'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter valid email id as abc@gmail.com',
                ),
                onChanged: (email) {
                  this._email = email;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                top: 15,
                bottom: 0,
              ),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                ),
                onChanged: (password) {
                  this._password = password;
                },
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  loginAction();
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const ResetPwdPage(),
                  ),
                );
              },
              child: const Text(
                'Forgot Password',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            const SizedBox(height: 100),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const NewUserPage(),
                  ),
                );
              },
              child: const Text(
                'New User? Create Account',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
