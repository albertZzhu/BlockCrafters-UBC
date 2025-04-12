import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:coach_link/Views/AddMilestonePage.dart';

class SingleHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> milestones;
  final String projectAddress;
  final String projectName;
  final String imageUrl;
  final int projectStatus;
  final double goal;
  final double raised;

  final Function(String projectAddress, String projectName) withdraw;
  final Function(
    String projectAddress,
    String name,
    String descriptionCid,
    double goal,
    int deadline,
    int projectStatus,
  )
  addMilestone;

  const SingleHistoryCard({
    Key? key,
    required this.milestones,
    required this.projectAddress,
    required this.projectName,
    required this.imageUrl,
    required this.projectStatus,
    required this.goal,
    required this.raised,
    required this.withdraw,
    required this.addMilestone,
  }) : super(key: key);

  double get progress => (raised / goal).clamp(0.0, 1.0);

  projectStatusTranslation(int status) {
    switch (status) {
      case 0:
        return "Inactive";
      case 1:
        return "Funding";
      case 2:
        return "Active";
      case 3:
        return "Failed";
      case 4:
        return "Completed";
      default:
        return "Unknown";
    }
  }

  Future<void> _launchCID() async {
    final url = 'https://gateway.pinata.cloud/ipfs/$projectAddress';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  List<Widget> dynamicBody(BuildContext context) {
    List<Widget> widgets = [];
    if (projectStatus != 0) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      );
    }
    widgets.add(
      ButtonTheme(
        child: ButtonBar(
          children: <Widget>[
            TextButton(
              child: Text('Add Milestone'),
              style: TextButton.styleFrom(
                foregroundColor:
                    projectStatus >= 0 && projectStatus <= 2
                        ? Colors.blue
                        : Colors.grey,
              ),
              onPressed:
                  projectStatus >= 0 && projectStatus <= 2
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AddMilestonePage(
                                  projectAddress: this.projectAddress,
                                  projectName: this.projectName,
                                  projectStatus: this.projectStatus,
                                  addMilestone: this.addMilestone,
                                ),
                          ),
                        );
                      }
                      : () {
                        Fluttertoast.showToast(
                          msg:
                              "You cannot add milestone when project is $projectStatus",
                        );
                      },
            ),
            TextButton(
              child: Text('Withdraw'),
              style: TextButton.styleFrom(
                foregroundColor:
                    projectStatus == 2 || projectStatus == 4
                        ? Colors.blue
                        : Colors.grey,
              ),
              onPressed:
                  projectStatus == 2 || projectStatus == 4
                      ? () {
                        withdraw(this.projectAddress, this.projectName);
                      }
                      : () {
                        Fluttertoast.showToast(
                          msg:
                              "You can only withdraw when project is completed",
                        );
                      },
            ),
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                _launchCID();
              },
            ),
          ],
        ),
      ),
    );
    return (widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(child: Text(projectName.substring(0, 1))),
            title: Text(projectName),
            subtitle: Text(
              "Status: " + projectStatusTranslation(projectStatus),
            ),
          ),
          ...dynamicBody(context),
        ],
      ),
    );
  }
}
