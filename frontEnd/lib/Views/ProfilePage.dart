import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:coach_link/Model/UpdateUser.dart';
import 'package:coach_link/Model/User.dart';
import 'package:coach_link/Views/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  String uid = "";
  bool isLogin = false;
  ProfilePage({Key? key, required this.isLogin}) : super(key: key);

  @override
  _ProfilePageState createState() =>
      _ProfilePageState(uid: uid, isLogin: isLogin);
}

class _ProfilePageState extends State<ProfilePage> {
  String uid = " ";
  bool isLogin;
  CoachUser? _coachUser;
  //UpdateUser? _userProfile;

  _ProfilePageState({required this.uid, required this.isLogin});

  @override
  void initState() {
    super.initState();
    //_GetUserState();
  }

  Future<void> _GetUserState() async {
    //_userProfile = UpdateUser(uid: uid);
    //_coachUser = await _userProfile?.getCoach();
    if (mounted) setState(() {});
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  //signout function
  signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  List<Widget> _getTopWidgets() {
    List<Widget> out = [];
    if (isLogin) {
      out.addAll([
        Positioned(
          top: 40,
          left: 10,
          child: TextButton(
            onPressed: () {
              /*Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder:
                      (BuildContext context) => UpdateProfilePage(uid: uid),
                ),
              );*/
            },
            child: const Text(
              "Update Profile",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 10,
          child: TextButton(
            onPressed: () {
              signOut();
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ]);
    } else {
      //TODO: Add signin logic here
      out.add(
        Positioned(
          top: 40,
          right: 10,
          child: TextButton(
            onPressed: () {},
            child: Text(
              "Sign In",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).colorScheme.surface.computeLuminance() >
                            0.5
                        ? Colors.black
                        : Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return (out);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [_getBannerWithAvatar(context) /*_getPersonalProfile()*/],
        ),
        ..._getTopWidgets(),
      ],
    );
  }

  Widget _getBannerWithAvatar(BuildContext context) {
    const double bannerHeight = 230;
    const double imageHeight = 180;
    const double avatarRadius = 45;
    const double avatarBorderSize = 4;
    return SliverToBoxAdapter(
      child: Container(
        height: bannerHeight,
        color: Colors.white70,
        alignment: Alignment.topLeft,
        child: Stack(
          children: [
            Container(height: bannerHeight),
            Positioned(
              top: 0,
              //height: 350,
              width: 800,
              left: -220,
              bottom: 40,
              child: Image.asset(
                "assets/19602.jpg",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 20,
              top: imageHeight - avatarRadius - avatarBorderSize,
              child: CircleAvatar(
                radius: 50,
                child: Text("Not Implemented for now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPersonalProfile() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        color: Colors.white70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _coachUser?.firstName ??
                      "" + " " + (_coachUser?.lastName ?? ""),
                  style: TextStyle(fontSize: 30.0),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Email: ",
              style: TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 13, 13, 13),
              ),
            ),
            Text(
              (_coachUser?.email ?? ""),
              style: TextStyle(fontSize: 15.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 6),
            Text(
              "Address: ",
              style: TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 13, 13, 13),
              ),
            ),
            Text(
              (_coachUser?.location ?? ""),
              style: TextStyle(fontSize: 15.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 6),
            Text(
              "Specialization: ",
              style: TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 13, 13, 13),
              ),
            ),
            Text(
              (_coachUser?.specialization ?? ""),
              style: TextStyle(fontSize: 15.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 6),
            Text(
              "Awards & Achievement: ",
              style: TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 13, 13, 13),
              ),
            ),
            Text(
              (_coachUser?.AwrdNAchv ?? ""),
              style: TextStyle(fontSize: 15.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 6),
            Text(
              "Coaching Experience: ",
              style: TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 13, 13, 13),
              ),
            ),
            Text(
              (_coachUser?.WorkExp ?? ""),
              style: TextStyle(fontSize: 15.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 6),
            Text(
              "Degree: ",
              style: TextStyle(
                fontSize: 20.0,
                color: Color.fromARGB(255, 13, 13, 13),
              ),
            ),
            Text(
              "   - High School:\n      " +
                  (_coachUser?.degree_HighSchool ?? "") +
                  "\n   - College: \n      " +
                  (_coachUser?.degree_College ?? ""),
              style: TextStyle(fontSize: 15.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            // Text(
            //   personalProfile.description,
            //   style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
            // ),
          ],
        ),
      ),
    );
  }
}
