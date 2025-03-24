import 'package:flutter/material.dart';
//import 'package:coach_link/Control/SearchMethod.dart';
import 'package:coach_link/Model/User.dart';
//import 'package:coach_link/Model/UpdateUser.dart';

class SearchLandingPage extends StatefulWidget {
  String keyword = "";
  String uid = "";
  SearchLandingPage({Key? key, required this.keyword, required this.uid})
    : super(key: key);
  @override
  _SearchLandingPageState createState() =>
      _SearchLandingPageState(keyword: keyword, uid: uid);
}

class _SearchLandingPageState extends State<SearchLandingPage> {
  String keyword = "";
  String uid = "";
  List<CoachUser> coachList = [];
  //UpdateUser? updateUser;

  _SearchLandingPageState({required this.keyword, required this.uid});

  Future<void> _getCoachList() async {
    //coachList = await SearchMethod.searchCoach(keyword);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _getCoachList();
    //updateUser = UpdateUser(uid: uid);
    super.initState();
  }

  Widget _singlePostBody(CoachUser user) {
    return Card(
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
              child: Image.asset('assets/banner.png', fit: BoxFit.cover),
            ),
          ),
          ListTile(
            leading: CircleAvatar(child: Text(user.firstName)),
            title: Text(user.firstName + " " + user.lastName),
            subtitle: Text(
              "email: " +
                  user.email +
                  "\n" +
                  "Specialization: " +
                  user.specialization,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              "Personal info",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ButtonTheme(
            child: ButtonBar(
              children: <Widget>[
                TextButton(
                  child: const Text("CONNECT"),
                  onPressed: () {
                    //updateUser!.addFriend(user.uid);
                  },
                ),
                TextButton(
                  child: Text('UNCONNECT'),
                  onPressed: () {
                    //updateUser!.removeFriend(user.uid);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (coachList.length == 0) {
      body = const Center(child: Text("No results found"));
    } else {
      body = Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [for (CoachUser user in coachList) _singlePostBody(user)],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Results for: " + keyword),
      ),
      body: body,
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
