import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_link/Views/StartPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coach_link/Model/UpdateUser.dart';
import 'package:coach_link/Model/User.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String _pwd = "";
  String _publicKey = "";
  String uid = "";
  UpdateUser? _userProfile;

  _OnboardingPageState();

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 8, vsync: this);
    //_GetUserState();
  }

  ActionCodeSettings acs = ActionCodeSettings(
    handleCodeInApp: true,
    url: "package:coach_link/Web/index.html",
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference docUser = FirebaseFirestore.instance.collection(
    'users',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create new account')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                _password_page(),
                _public_key_page(),
                /*_WorkExp_page(),
                _AwrdNAchv_page(),
                _degree_page(),
                _location_page(),*/
                _createFinishedPage(),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[TabPageSelector(controller: tabController)],
            ),
          ),
        ],
      ),
    );
  }

  Container _createInitialPage() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: const Center(
        child: Text(
          "Please answer a few questions about yourself so that we can improve your chances of being seen in the search.\n\nSwipe to the right to begin. ->",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Container _createFinishedPage() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "You have finished the registration process!\nPlease click the button below to continue to the app.",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 35),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => StartPage()),
                (route) => route == null,
              );
              //UpdateUserInfo();
            },
            child: const Text('Go to App'),
          ),
        ],
      ),
    );
  }

  Container _password_page() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100),
            const Text('New Password', textAlign: TextAlign.left),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Password',
                  hintText: 'Password is required to be at least 12 characters',
                ),
                //controller: userNameController,
                onChanged: (password) {
                  this._pwd = password;
                  //TODO: Implement the password checking logic
                },
              ),
            ),
            const Text('Confirm your password', textAlign: TextAlign.left),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Password Again',
                  hintText: 'Password has to match',
                ),
                //controller: userNameController,
                onChanged: (confirm) {
                  //TODO: Implement the password matching logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _public_key_page() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100),
            const Text('Wallet Public Key', textAlign: TextAlign.left),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Public Key',
                ),
                //controller: userNameController,
                onChanged: (publicKey) {
                  this._publicKey = publicKey;
                  //TODO: Implement the password checking logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
