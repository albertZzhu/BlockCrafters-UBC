import 'package:coach_link/Views/PostDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:coach_link/Model/Post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:coach_link/Model/SampleProjectData.dart';
import 'package:coach_link/Views/SingleProjectCard.dart';
import 'package:coach_link/Views/InvestModal.dart';
import 'package:coach_link/Model/enum.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool isInitializing = true;
  bool isLogin = false;
  _MyHomePageState();

  void showInvestModal(
    BuildContext context,
    Function(
      String projectAddress,
      String token,
      String amount,
      String projectName,
    )
    onInvest,
    String description,
    String projectImageUrl,
    String projectAddress,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Wrap(
                  children: [
                    InvestModal(
                      onInvest: onInvest,
                      description: description,
                      projectImageUrl: projectImageUrl,
                      projectAddress: projectAddress,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

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

  Widget bodyState(List<Map<String, Object>> posts, bool isLogin) {
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
          onInvest: () {
            if (isLogin) {
              showInvestModal(
                context,
                (
                  String projectAddress,
                  String token,
                  String amount,
                  String projectName,
                ) {
                  context.read<WalletConnectControl>().investProject(
                    projectAddress: projectAddress,
                    token: token,
                    amount: amount,
                    projectName: projectName,
                  );
                },
                posts[index]['projectName'] as String,
                posts[index]['imageUrl'] as String,
                "",

                ///Fill in with the project address later
              );
            } else {
              Fluttertoast.showToast(msg: "Please login to invest");
            }
          },
          onVote:
              () => print('Vote clicked for ${posts[index]['projectName']}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<WalletConnectControl>().fetchHomeScreenActionButton();
    return Scaffold(
      body: BlocBuilder<WalletConnectControl, Web3State>(
        builder: (context, state) {
          if (state is FetchHomeScreenActionButtonSuccess) {
            if (state.action == HomeScreenActionButton.interactWithContract) {
              isLogin = true;
            }
            return bodyState(projects, isLogin);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
