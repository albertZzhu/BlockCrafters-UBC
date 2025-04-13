import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';




class SingleProjectCard extends StatelessWidget {
  final String projectName;
  final String imageUrl;
  final String detailCid;
  final double goal;
  final double raised;
  final String deadline;
  final String status;
  final String founder;
  final VoidCallback onInvest;
  final VoidCallback onVote;
  final String projectAddress;
  final String tokenAddress;

  const SingleProjectCard({
    Key? key,
    required this.projectAddress,
    required this.projectName,
    required this.imageUrl,
    required this.detailCid,
    required this.goal,
    required this.raised,
    required this.deadline,
    required this.status,
    required this.founder,
    required this.onInvest,
    required this.onVote,
    required this.tokenAddress,
  }) : super(key: key);

  double get progress => (goal > 0) ? (raised / goal).clamp(0.0, 1.0) : 0.0;

  Future<void> _launchCID() async {
    final url = 'https://gateway.pinata.cloud/ipfs/$detailCid';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // @override
  // Widget build(BuildContext context) {

  //   final deadlineDateTime = DateTime.parse(deadline);
  //   final formattedDeadline = DateFormat('MMM d, y').format(deadlineDateTime);   

  //   final now = DateTime.now();
  //   final daysLeft = deadlineDateTime.difference(now).inDays;
  //   final String daysLeftText = daysLeft > 0
  //       ? '$daysLeft days left'
  //       : (daysLeft == 0 ? 'Last day!' : 'Deadline passed');  
  @override
  Widget build(BuildContext context) {
    String formattedDeadline;
    String daysLeftText;

    try {
      // print('Raw deadline value: $deadline');

      final deadlineDateTime = DateTime.parse(deadline);
      formattedDeadline = DateFormat('MMM d, y').format(deadlineDateTime);

      final now = DateTime.now();
      final daysLeft = deadlineDateTime.difference(now).inDays;

      daysLeftText = daysLeft > 0
          ? '$daysLeft days left'
          : (daysLeft == 0 ? 'Last day!' : 'Deadline passed');
    } catch (e) {
      print("⚠️ Failed to parse deadline: $deadline, error: $e");
      formattedDeadline = "Invalid";
      daysLeftText = "";
    }


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
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          ListTile(
            leading: CircleAvatar(child: Text(projectName.substring(0, 1))),
            title: Text(projectName),
            subtitle: Text("Created by: $founder", style: TextStyle(fontSize: 8),),
          ),
          // show token info
          if (tokenAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Token address: $tokenAddress",
                      style: const TextStyle(
                        fontSize: 8,
                        fontStyle: FontStyle.normal,
                        // overflow: TextOverflow.ellipsis, 
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 14),
                    tooltip: 'Copy token address',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: tokenAddress));
                      Fluttertoast.showToast(msg: "Token address copied!");
                    },
                  ),
                ],
              ),
            ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              "Deadline: $formattedDeadline – $daysLeftText",
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.normal, color: Colors.orange,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goal == 0)
                  const Text(
                    "No goal is added yet",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                else ...[
                  Text(
                    "Progress: ${(progress * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  // show funding, frozen, goal
                  const SizedBox(height: 8),
                  FutureBuilder<Map<String, dynamic>>(
                    future: context.read<WalletConnectControl>().getProjectInfo(projectAddress),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError) {
                        return const SizedBox.shrink();
                      }

                      final data = snapshot.data!;
                      final double funding =
                          BigInt.parse(data['fundingBalance']).toDouble() / 1e18;
                      final double frozen =
                          BigInt.parse(data['frozenFund']).toDouble() / 1e18;
                      final double goalValue =
                          BigInt.parse(data['goal']).toDouble() / 1e18;

                      return Text(
                        "💰 $funding ETH funded • ❄️ $frozen ETH frozen • 🎯 $goalValue ETH goal",
                        style: const TextStyle(fontSize: 8, fontStyle: FontStyle.normal),
                      );
                    },
                  ),
                ]
              ],
            ),
          ),
          ButtonBar(
            children: <Widget>[
              // Vote (only when Active + Pending)
              if (status == "2")
                FutureBuilder<Map<String, dynamic>>(
                  future: context
                      .read<WalletConnectControl>()
                      .getCurrentVotingStats(projectAddress),
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink(); 
                    }

                    final canVote = data != null &&
                        data['voteResult'] == 0 &&
                        !(data['error']?.toString().contains("No voting has started yet") ?? false);

                    return canVote
                        ? TextButton(
                            child: Text('Vote'.toUpperCase()),
                            onPressed: onVote,
                          )
                        : const SizedBox.shrink();
                  },
                ),

              if (status != "2")
              TextButton(
                child: Text('Invest'.toUpperCase()),
                onPressed: onInvest,
              ),

              TextButton(
                child: Text('Read'),
                onPressed: _launchCID,
              ),

              TextButton(
                child: const Text('Vote Info'),
                onPressed: () async {
                  final data = await context
                      .read<WalletConnectControl>()
                      .getCurrentVotingStats(projectAddress);

                  if (data['error'] != null &&
                      data['error'].toString().contains('No voting has started yet')) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Voting Info"),
                        content: const Text("🕓 No voting has started yet for this project."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                    return;
                  }

                  final BigInt pos = data['positives'];
                  final BigInt neg = data['negatives'];
                  final BigInt threshold = data['threshold'];
                  final int voteResult = data['voteResult'];

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Voting Stats"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("✅ Positive Votes: $pos"),
                          Text("❌ Negative Votes: $neg"),
                          Text("📊 Threshold: $threshold"),
                          Text("📝 Status: ${voteResult == 0 ? 'Pending' : voteResult == 1 ? 'Approved' : 'Rejected'}"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
