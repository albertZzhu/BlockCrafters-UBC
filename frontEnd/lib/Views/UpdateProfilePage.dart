import 'package:coach_link/Model/User.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coach_link/Model/UpdateUser.dart';

class UpdateProfilePage extends StatefulWidget {
  String uid = "";
  UpdateProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState(uid: uid);
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _specialization = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _phoneNum = TextEditingController();
  String uid = "";
  String? _email = "";
  CoachUser? _coachUser;

  _UpdateProfilePageState({required this.uid});

  @override
  void initState() {
    _GetUserState();
    super.initState();
  }

  Future<void> _GetUserState() async {
    _coachUser = await UpdateUser(uid: uid).getCoach();
    _email = _coachUser?.email;
    _firstName.text = _coachUser!.firstName;
    _lastName.text = _coachUser!.lastName;
    _specialization.text = _coachUser!.specialization;
    _location.text = _coachUser!.location;
    _phoneNum.text = _coachUser!.phoneNum;
    if (mounted) setState(() {});
  }

  void newUserAction() async {
    try {
      await UpdateUser(uid: uid).updateProfile(
          _firstName.text, _lastName.text, _email!, _specialization.text,
          location: _location.text, phoneNum: _phoneNum.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Successfully updated account."),
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed update account, please try again."),
      ));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Update Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100),
            const Text(
              'First Name',
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: _firstName,
              ),
            ),
            const Text(
              'Last Name',
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: _lastName,
              ),
            ),
            const Text(
              'Specialization',
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: _specialization,
              ),
            ),
            const Text(
              'Location',
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: _location,
              ),
            ),
            const Text(
              'Phone Number',
              textAlign: TextAlign.left,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: _phoneNum,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  newUserAction();
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}
