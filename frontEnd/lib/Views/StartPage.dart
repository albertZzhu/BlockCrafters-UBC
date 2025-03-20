import 'package:coach_link/Views/newPost.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'LoginPage.dart';
import 'ProfilePage.dart';
import "SearchPage.dart";
import "HomePage.dart";
import 'FavoritePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazzicon/jazzicon.dart';

class StartPage extends StatefulWidget {
  String uid = "";
  bool isLogin = false;
  StartPage({Key? key, bool isLogin = false}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _StartPageState createState() => _StartPageState(isLogin: isLogin);
}

class _StartPageState extends State<StartPage> {
  int _currentIndex = 0;
  List<Widget> _bottomNavPages = [];
  String uid = "";
  String address = "";
  bool isLogin = false;

  _StartPageState({required this.isLogin});
  @override
  void initState() {
    super.initState();
    _bottomNavPages
      ..add(MyHomePage(title: "Now Projects"))
      ..add(HistoryPage())
      ..add(SearchPage())
      ..add(ProfilePage(isLogin: isLogin));
  }

  FloatingActionButton newPostWidget() {
    if (isLogin) {
      return (FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => newPost(uid: uid)),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ));
    } else {
      return (FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        shape: CircleBorder(),
        child:
            isLogin
                ? Icon(Icons.add)
                : Icon(Icons.login_sharp, color: Colors.black54, size: 30),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: _bottomNavPages[_currentIndex],
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height / 10,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey, blurRadius: 5)],
        ),
        child: BottomAppBar(
          color: Colors.white.withOpacity(0.8),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _currentIndex == 0 ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  color: _currentIndex == 1 ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),
              const SizedBox(),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _currentIndex == 2 ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.swap_vert_outlined,
                  color: _currentIndex == 3 ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          shape: const CircularNotchedRectangle(),
        ),
      ),
      floatingActionButton: newPostWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
