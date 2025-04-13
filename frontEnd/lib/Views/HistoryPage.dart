import 'package:flutter/material.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Model/enum.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:coach_link/Views/SingleHistoryCard.dart';

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
  bool isLogin = false;

  _HistoryPageState();

  @override
  void initState() {
    context.read<WalletConnectControl>().fetchHomeScreenActionButton();
    super.initState();
  }

  Future<void> _fetchData() async {
    // Fetch data logic here
    await context.read<WalletConnectControl>().fetchHomeScreenActionButton();
    setState(() {}); // Rebuild the widget to reflect the updated data
  }

  Widget bodyState(List<Map<String, Object>> posts, bool isLogin) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SingleHistoryCard(
                      milestones:
                          posts[index]['milestones']
                              as List<Map<String, dynamic>>,
                      projectName: posts[index]['projectName'] as String,
                      imageUrl: posts[index]['imageUrl'] as String,
                      projectAddress: posts[index]['address'] as String,
                      projectStatus: posts[index]['status'] as int,
                      goal: posts[index]['goal'] as double,
                      raised: posts[index]['raised'] as double,
                      withdraw: context.read<WalletConnectControl>().withdraw,
                      startVoting:
                          context.read<WalletConnectControl>().startVoting,
                      addMilestone:
                          context.read<WalletConnectControl>().addMileStone,
                      cancelProject:
                          context.read<WalletConnectControl>().cancelProject,
                      startFunding:
                          context
                              .read<WalletConnectControl>()
                              .startProjectFunding,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, Object>> transferToPosts(List<Map<String, dynamic>> posts) {
    return posts.map((post) {
      return {
        'projectName': post['name'].toString() ?? "",
        'imageUrl': post['photoCID'].toString() ?? "",
        'detailCid': post['descCID'].toString() ?? "",
        'goal': double.tryParse(post['goal'].toString()) ?? 0,
        'raised': double.tryParse(post['fundingBalance'].toString()) ?? 0,
        'deadline': post['deadline'].toString() ?? "",
        'status': int.tryParse(post['status'].toString()) ?? -1,
        'link': post['socialMediaCID'].toString() ?? "",
        'address': post['projectAddress'].toString() ?? "",
        'milestones':
            (post['milestones'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            <Map<String, dynamic>>[],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    context.read<WalletConnectControl>().fetchHomeScreenActionButton();
    return Scaffold(
      body: BlocBuilder<WalletConnectControl, Web3State>(
        builder: (context, state) {
          if (state is FetchHomeScreenActionButtonSuccess &&
              state.action == HomeScreenActionButton.interactWithContract) {
            isLogin = true;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  context.read<WalletConnectControl>().getSelfProposedProject(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  final List<Map<String, dynamic>> projectList = snapshot.data!;
                  return bodyState(transferToPosts(projectList), isLogin);
                } else {
                  return const Center(child: Text("No projects found."));
                }
              },
            );
          } else if (state is FetchHomeScreenActionButtonSuccess &&
              state.action == HomeScreenActionButton.connectWallet) {
            return const Center(
              child: Text(
                "Please connect your wallet to view history projects.",
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
