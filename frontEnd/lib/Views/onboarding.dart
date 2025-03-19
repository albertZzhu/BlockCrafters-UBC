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
  //TextEditingController _location = TextEditingController();

  //CoachUser? _coachUser;
  UpdateUser? _userProfile;

  _OnboardingPageState();

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 8, vsync: this);
    //_GetUserState();
  }

  /*Future<void> _GetUserState() async {
    _userProfile = UpdateUser(uid: uid);
    _coachUser = await _userProfile!.getCoach();
    sport = _coachUser!.sport;
    specialization = _coachUser!.specialization;
    _WorkExp.text = _coachUser!.WorkExp;
    _AwrdNAchv.text = _coachUser!.AwrdNAchv;
    _degree_HighSchool.text = _coachUser!.degree_HighSchool;
    _degree_College.text = _coachUser!.degree_College;
    _location.text = _coachUser!.location;
    if (mounted) setState(() {});
  }*/

  ActionCodeSettings acs = ActionCodeSettings(
    handleCodeInApp: true,
    url: "package:coach_link/Web/index.html",
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference docUser = FirebaseFirestore.instance.collection(
    'users',
  );

  /*List<String> specializations_List = [
    'Head coach',
    'Offensive coordinator',
    'Quaterback coach',
    'Offensive line coach',
    'Running backs coach',
    'Wide receivers coach',
    'Tight ends coach',
    'Defensive coordinator',
    'Defensive line coach',
    'Linebacker coach',
    'Secondary coach',
    'Special teams coach',
    'Graduate assistant',
    'Strength coach',
    'Recruiting coordinator',
    'Video coordinator',
    'Director of football operation',
    'Equipment manager',
  ];
  String? selectedSpecialization = "Head coach";

  List<String> sports_List = ['Football'];
  String? selectedSport = "Football";*/

  /*void UpdateUserInfo() {
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'WorkExp': _WorkExp.text,
      'AwrdNAchv': _AwrdNAchv.text,
      'degree_HighSchool': _degree_HighSchool.text,
      'degree_College': _degree_College.text,
      'location': _location.text,
    });
  }*/

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

  /*Container _WorkExp_page() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What coaching experience do you have?",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _WorkExp,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Container _AwrdNAchv_page() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Do you have any awards and achievements you would like to list?",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _AwrdNAchv,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Container _degree_page() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What degree did you get? Please enter the name of instituition and duration if applicable.  ",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "High School:",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          //const SizedBox(height: 30),
          TextField(
            controller: _degree_HighSchool,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: "ex:The Ohio State University(2018-2022)",
            ),
            maxLines: null,
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "College:",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          TextField(
            controller: _degree_College,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: "ex:The Ohio State University(2018-2022)",
            ),
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Container _location_page() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "What is your current location?",
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _location,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ],
      ),
    );
  }*/
}
