import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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

  const SingleProjectCard({
    Key? key,
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
      print('📅 Raw deadline value: $deadline');

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
            subtitle: Text("Created by: $founder"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              "Deadline: $formattedDeadline – $daysLeftText",
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
                ]
              ],
            ),
          ),
          ButtonBar(
            children: <Widget>[
              TextButton(
                child: Text('Vote'.toUpperCase()),
                onPressed: onVote,
              ),
              TextButton(
                child: Text('Invest'.toUpperCase()),
                onPressed: onInvest,
              ),
              TextButton(
                child: Text('Read'.toUpperCase()),
                onPressed: _launchCID,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
