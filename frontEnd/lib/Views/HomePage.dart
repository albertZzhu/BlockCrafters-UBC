import 'package:coach_link/Views/PostDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:coach_link/Model/Post.dart';

import 'package:coach_link/Model/SampleProjectData.dart';
import 'package:coach_link/Views/SingleProjectCard.dart';

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
  _MyHomePageState();

  /*Future<List<Post>> _refreshPosts() async {
    // return Future.delayed(const Duration(seconds: 5), () {
    //   return GetPost(uid: uid).getPosts();
    // });
    return GetPost().getPosts();
  }*/

  @override
  void initState() {
    super.initState();
  }

  // FutureBuilder<List<Post>> buildFutureBuilder() {
  //   return new FutureBuilder<List<Post>>(builder: (context, AsyncSnapshot<List<Post>>){}
  //   );

  // }

  Widget bodyState(List<Map<String, Object>> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        return SingleProjectCard(
          projectName: posts[index]['projectName'] as String,
          imageUrl: posts[index]['imageUrl'] as String,
          detailCid: posts[index]['detailCid'] as String,
          goal: posts[index]['goal'] as double,
          raised: posts[index]['raised'] as double,
          deadline: posts[index]['deadline'] as String,
          status: posts[index]['status'] as String,
          onInvest:
              () => print('Invest clicked for ${posts[index]['projectName']}'),
          onVote:
              () => print('Vote clicked for ${posts[index]['projectName']}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:
            true /*Add loading determine logic here*/
                ? bodyState(projects)
                : const Center(child: CircularProgressIndicator()),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
