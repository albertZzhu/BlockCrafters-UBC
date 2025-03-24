import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleProjectCard extends StatelessWidget {
  final String projectName;
  final String imageUrl; // IPFS image URL
  final String detailCid; // IPFS file for "Learn More"
  final double goal;
  final double raised;
  final String deadline; // formatted date
  final String status;
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
    required this.onInvest,
    required this.onVote,
  }) : super(key: key);

  double get progress => (raised / goal).clamp(0.0, 1.0);

  Future<void> _launchCID() async {
    final url = 'https://gateway.pinata.cloud/ipfs/$detailCid';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    /*return Card(
      child: Column(
        children: [
          Image.network(imageUrl),
          Text(projectName),
          Text("Goal: \$${goal.toStringAsFixed(2)}"),
          Text("Raised: \$${raised.toStringAsFixed(2)}"),
          Text("Deadline: $deadline"),
          LinearProgressIndicator(value: progress),
          Text("Status: $status"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: onInvest, child: Text("Invest")),
              ElevatedButton(onPressed: onVote, child: Text("Vote")),
            ],
          ),
        ],
      ),
    );*/
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
            subtitle: Text(status),
          ),
          /*Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              projectName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(),
            ),
          ),*/
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
          ButtonTheme(
            child: ButtonBar(
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
                  onPressed: () {
                    _launchCID();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
