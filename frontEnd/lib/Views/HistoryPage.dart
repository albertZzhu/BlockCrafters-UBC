import 'package:flutter/material.dart';
import 'package:coach_link/Model/User.dart';

class HistoryPage extends StatefulWidget {
  //String uid = "";
  HistoryPage({Key? key}) : super(key: key);
  @override
  _HistoryPageState createState() =>
      // ignore: no_logic_in_create_state
      _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  //String uid = "";
  List<String> coachUids = [];
  List<CoachUser> coachList = [];

  _HistoryPageState();

  Future<void> _getCoachList() async {
    //coachUids = await UpdateUser(uid: uid).getFriends();
    for (String uid in coachUids) {
      //CoachUser? user = await CoachesDBHelperFunctions.instance.getUser(uid);
      //coachList.add(user!);
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _getCoachList();
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
              child: Image.asset('assets/banner.jpeg', fit: BoxFit.cover),
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
                  child: Text('DisConnect'.toUpperCase()),
                  onPressed: () {
                    //UpdateUser(uid: uid).removeFriend(user.uid);
                  },
                ),
                TextButton(
                  child: Text('Message'.toUpperCase()),
                  onPressed: () {},
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
      body = const Center(child: Text("No Transaction Found"));
    } else {
      body = Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [for (CoachUser user in coachList) _singlePostBody(user)],
        ),
      );
    }
    return Scaffold(
      body: body,
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
