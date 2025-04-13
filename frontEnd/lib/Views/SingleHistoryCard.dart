import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:coach_link/Views/AddMilestonePage.dart';
import 'package:coach_link/Views/InvestModal.dart';

class SingleHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> milestones;
  final String projectAddress;
  final String projectName;
  final String imageUrl;
  final int projectStatus;
  final double goal;
  final double raised;
  final bool isInvested;

  final Function(String projectAddress, String projectName) withdraw;
  final Function(String projectAddress, String projectName) startVoting;
  final Function(
    String projectAddress,
    String name,
    String descriptionCid,
    double goal,
    int deadline,
    int projectStatus,
  )
  addMilestone;
  final Function(String projectAddress, String projectName) cancelProject;
  final Function(String projectAddress, String projectName) startFunding;
  final Function(String projectAddress, String projectName) refund;

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
    required this.startVoting,
    required this.addMilestone,
    required this.cancelProject,
    required this.startFunding,
    required this.isInvested,
    required this.refund,
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

  Widget buildInvestActionButtons(BuildContext context) {
    return (ButtonTheme(
      child: ButtonBar(
        children: [
          //TextButton(onPressed: () {}, child: const Text("Add Invest")),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: projectStatus == 3 ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              if (projectStatus == 3) {
                refund(this.projectAddress, this.projectName);
              } else {
                Fluttertoast.showToast(
                  msg: "You can only get the refund when project is failed",
                );
              }
            },
            child: const Text("Refund"),
          ),
        ],
      ),
    ));
  }

  Widget buildProposerActionButtons(BuildContext context) {
    return (Align(
      alignment: Alignment.centerRight, // Aligns the dropdown to the right
      child: ButtonTheme(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.blue,
              size: 28,
            ), // Styled dropdown icon
            items: [
              DropdownMenuItem(
                value: 'addMilestone',
                child: Text(
                  'Add Milestone',
                  style: TextStyle(
                    color:
                        projectStatus >= 0 && projectStatus <= 2
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'startVoting',
                child: Text(
                  'Start Voting',
                  style: TextStyle(
                    color: projectStatus == 2 ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'withdraw',
                child: Text(
                  'Withdraw',
                  style: TextStyle(
                    color:
                        projectStatus == 2 || projectStatus == 4
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'cancel',
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: projectStatus == 2 ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'startFunding',
                child: Text(
                  'Start Funding',
                  style: TextStyle(
                    color:
                        projectStatus == 0 && milestones.length != 0
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
              ),
            ],
            onChanged: (String? value) {
              if (value == 'addMilestone') {
                if (projectStatus >= 0 && projectStatus <= 2) {
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
                } else {
                  Fluttertoast.showToast(
                    msg:
                        "You cannot add milestone when project is ${projectStatusTranslation(projectStatus)}",
                  );
                }
              } else if (value == 'startVoting') {
                if (projectStatus == 2) {
                  startVoting(this.projectAddress, this.projectName);
                } else {
                  Fluttertoast.showToast(
                    msg:
                        "You can only start voting process when project is active",
                  );
                }
              } else if (value == 'withdraw') {
                if (projectStatus == 2 || projectStatus == 4) {
                  withdraw(this.projectAddress, this.projectName);
                } else {
                  Fluttertoast.showToast(
                    msg: "You can only withdraw when project is completed",
                  );
                }
              } else if (value == 'cancel') {
                if (projectStatus == 2) {
                  cancelProject(this.projectAddress, this.projectName);
                } else {
                  Fluttertoast.showToast(
                    msg: "You can only cancel when project is active",
                  );
                }
              } else if (value == 'startFunding') {
                if (projectStatus == 0 && milestones.length != 0) {
                  startFunding(this.projectAddress, this.projectName);
                } else {
                  if (projectStatus != 0) {
                    Fluttertoast.showToast(
                      msg:
                          "You cannot start funding when project is ${projectStatusTranslation(projectStatus)}",
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "You need to add milestone before starting funding",
                    );
                  }
                }
              }
            },
          ),
        ),
      ),
    ));
  }

  List<Widget> dynamicBody(BuildContext context) {
    List<Widget> widgets = [];
    if (projectStatus != 0 && projectStatus != 3) {
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
      isInvested
          ? buildInvestActionButtons(context)
          : buildProposerActionButtons(context),
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
