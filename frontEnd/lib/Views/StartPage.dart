import 'package:coach_link/Views/newPost.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "HomePage.dart";
import 'HistoryPage.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter/scheduler.dart';
import 'package:coach_link/Model/enum.dart';
import 'package:coach_link/Views/loader.dart';
import 'package:coach_link/Views/TokenSwapPage.dart';
import 'package:coach_link/Views/GovernancePage.dart';

class StartPage extends StatefulWidget {
  String uid = "";
  bool isLogin = false;
  StartPage({Key? key, bool isLogin = false}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _StartPageState createState() => _StartPageState(isLogin: isLogin);
}

class _StartPageState extends State<StartPage> {
  ReownAppKitModal? w3mService;
  int _currentIndex = 0;
  List<Widget> _bottomNavPages = [];
  String uid = "";
  String address = "";
  bool isLogin = false;
  bool firstTimeHitLogin = true;
  static bool _isInitialized = false;

  _StartPageState({required this.isLogin});
  @override
  void initState() {
    super.initState();
    _bottomNavPages
      ..add(MyHomePage(title: "Now Projects"))
      ..add(HistoryPage())
      ..add(Governancepage())
      ..add(TokenSwapPage());
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        //Important!!! Avoid calling instantiate() after the connection is already established
        _isInitialized = true;
        context.read<WalletConnectControl>().instantiate(context);
      }
    });
  }

  FloatingActionButton addNewProjectWidget() {
    return (FloatingActionButton(
      onPressed: () {
        if (isLogin) {
          Navigator.pushNamed(context, '/proposeProject');
        } else {
          Fluttertoast.showToast(
            msg: "Please login to create a new project",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      shape: CircleBorder(),
      child: Icon(Icons.add),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletConnectControl, Web3State>(
      listenWhen:
          (Web3State previous, Web3State current) =>
              current is InitializeWeb3MSuccess ||
              current is FetchHomeScreenActionButtonSuccess,
      listener: (BuildContext context, Web3State state) {
        if (state is InitializeWeb3MSuccess) {
          setState(() => w3mService = state.service);
          context.read<WalletConnectControl>().fetchHomeScreenActionButton();
        } else if (state is FetchHomeScreenActionButtonSuccess) {
          if (state.action == HomeScreenActionButton.connectWallet) {
            setState(() {
              if (isLogin) {
                //context.read<WalletConnectControl>().endSession();
                //_isInitialized = false;
                isLogin = false;
              } else {
                isLogin = false;
              }
            });
          } else if (state.action ==
              HomeScreenActionButton.interactWithContract) {
            Navigator.popUntil(context, (route) => route.isFirst);
            setState(() {
              isLogin = true;
              uid = state.uid!;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.8),
          leadingWidth: MediaQuery.of(context).size.width / 2,
          leading: BlocBuilder<WalletConnectControl, Web3State>(
            buildWhen:
                (Web3State previous, Web3State current) =>
                    current is FetchHomeScreenActionButtonSuccess,
            builder: (BuildContext context, Web3State state) {
              if (state is FetchHomeScreenActionButtonSuccess &&
                  state.action == HomeScreenActionButton.connectWallet) {
                return (GestureDetector(
                  onTap: () {
                    w3mService!.openModalView();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        minRadius: AppBar().preferredSize.height,
                        maxRadius: AppBar().preferredSize.height,
                        child: Icon(Icons.question_mark),
                      ),
                      Text(
                        "Login",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ],
                  ),
                ));
              } else if (state is FetchHomeScreenActionButtonSuccess &&
                  state.action == HomeScreenActionButton.interactWithContract) {
                isLogin = true;
                final uid = state.uid?.toString() ?? "";
                return (GestureDetector(
                  onTap: () {
                    w3mService!.openModalView();
                    /*setState(() {
                      isLogin = w3mService!.isConnected;
                    });*/
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        minRadius: AppBar().preferredSize.height,
                        maxRadius: AppBar().preferredSize.height,
                        child: Jazzicon.getIconWidget(
                          Jazzicon.getJazziconData(
                            AppBar().preferredSize.height,
                            address: uid,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Address",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            uid.substring(0, 4) +
                                "..." +
                                uid.substring(uid.length - 4),
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
              } else {
                return Loader(height: AppBar().preferredSize.height);
              }
            },
          ),
          actions: [
            Image.asset(
              'assets/images/CrowdFund_Logo.png',
              height: AppBar().preferredSize.height * 0.6,
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: _bottomNavPages[_currentIndex],
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height / 10,
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.grey, blurRadius: 5),
            ],
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
                    Icons.how_to_vote_outlined,
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
        floatingActionButton: addNewProjectWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
