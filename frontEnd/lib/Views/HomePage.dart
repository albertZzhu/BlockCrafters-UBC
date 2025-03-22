import 'package:coach_link/Model/User.dart';
import 'package:coach_link/Views/PostDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coach_link/Control/GetPostControl.dart';
import 'package:coach_link/Model/Post.dart';
import 'package:coach_link/Model/UpdateUser.dart';

class MyHomePage extends StatefulWidget {
  //String uid = "";
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Future? future;
  //String uid = "";
  _MyHomePageState();

  Future<List<Post>> _refreshPosts() async {
    // return Future.delayed(const Duration(seconds: 5), () {
    //   return GetPost(uid: uid).getPosts();
    // });
    return GetPost().getPosts();
  }

  @override
  void initState() {
    super.initState();
  }

  // FutureBuilder<List<Post>> buildFutureBuilder() {
  //   return new FutureBuilder<List<Post>>(builder: (context, AsyncSnapshot<List<Post>>){}
  //   );

  // }

  Widget _singlePostBody(Post post) {
    return Card(
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
              child: Image.asset('assets/19602.jpg', fit: BoxFit.cover),
            ),
          ),
          ListTile(
            leading: CircleAvatar(child: Text(post.userName.substring(0, 1))),
            title: Text(post.title),
            subtitle: Text(post.userName),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(),
            ),
          ),
          ButtonTheme(
            child: ButtonBar(
              children: <Widget>[
                TextButton(child: Text('Like'.toUpperCase()), onPressed: () {}),
                TextButton(
                  child: Text('Read'.toUpperCase()),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (BuildContext context) => PostDetailPage(
                              title: post.title,
                              description: post.body,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyState(List<Post> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        return _singlePostBody(posts[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Post>>(
          future: _refreshPosts(),
          builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return bodyState(snapshot.data!);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
