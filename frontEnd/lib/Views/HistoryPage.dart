import 'package:flutter/material.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Views/SingleHistoryCard.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
    // Fetch data after initializing the TabController
    context.read<WalletConnectControl>().fetchHomeScreenActionButton();
  }

  Future<void> _fetchData() async {
    await context.read<WalletConnectControl>().fetchHomeScreenActionButton();
    setState(() {}); // Rebuild the widget to reflect the updated data
  }

  Widget investedProjectsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<WalletConnectControl>().getInvestedProjectList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final List<Map<String, dynamic>> projectList = snapshot.data!;
          return bodyState(transferToPosts(projectList), true, true);
        } else {
          return const Center(child: Text("No invested projects found."));
        }
      },
    );
  }

  Widget proposedProjectsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<WalletConnectControl>().getSelfProposedProject(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final List<Map<String, dynamic>> projectList = snapshot.data!;
          return bodyState(transferToPosts(projectList), true, false);
        } else {
          return const Center(child: Text("No proposed projects found."));
        }
      },
    );
  }

  Widget bodyState(
    List<Map<String, Object>> posts,
    bool isLogin,
    bool isInvest,
  ) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return SingleHistoryCard(
            milestones:
                posts[index]['milestones'] as List<Map<String, dynamic>>,
            projectName: posts[index]['projectName'] as String,
            imageUrl: posts[index]['imageUrl'] as String,
            projectAddress: posts[index]['address'] as String,
            projectStatus: posts[index]['status'] as int,
            goal: posts[index]['goal'] as double,
            raised: posts[index]['raised'] as double,
            withdraw: context.read<WalletConnectControl>().withdraw,
            startVoting: context.read<WalletConnectControl>().startVoting,
            addMilestone: context.read<WalletConnectControl>().addMileStone,
            cancelProject: context.read<WalletConnectControl>().cancelProject,
            startFunding:
                context.read<WalletConnectControl>().startProjectFunding,
            isInvested: isInvest,
            refund: context.read<WalletConnectControl>().getRefund,
          );
        },
      ),
    );
  }

  List<Map<String, Object>> transferToPosts(List<Map<String, dynamic>> posts) {
    return posts.map((post) {
      return {
        'projectName': post['name'].toString() ?? "",
        'imageUrl': 'https://ipfs.io/ipfs/${post['photoCID'] ?? ''}',
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: PreferredSize(
          preferredSize: const Size.fromHeight(50), // Height of the TabBar
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: TabBar(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              dividerColor: Colors.transparent,
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.blue, // Background color of the selected tab
                borderRadius: BorderRadius.circular(25), // Rounded corners
              ),
              labelColor: Colors.white, // Text color for selected tab
              unselectedLabelColor:
                  Colors.blue, // Text color for unselected tabs
              tabs: const [Tab(text: "Invested"), Tab(text: "Proposed")],
              indicatorPadding: const EdgeInsets.symmetric(horizontal: -50),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [investedProjectsView(), proposedProjectsView()],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the TabController to free resources
    _tabController.dispose();
    super.dispose();
  }
}
