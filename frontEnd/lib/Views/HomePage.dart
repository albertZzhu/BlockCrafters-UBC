import 'package:coach_link/Views/PostDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:coach_link/Model/Post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:coach_link/Model/SampleProjectData.dart';
import 'package:coach_link/Views/SingleProjectCard.dart';
import 'package:coach_link/Views/InvestModal.dart';
import 'package:coach_link/Views/propose_project_screen.dart';
import 'package:coach_link/Model/enum.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // for jsonEncode


Widget ipfsCidPreview(BuildContext context, String label, String cid) {
  final ipfsUrl = 'https://ipfs.io/ipfs/$cid';
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label CID:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SelectableText(cid),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: cid));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$label CID copied')));
                },
                child: const Text("Copy"),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(ipfsUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: const Text("View on IPFS"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

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

  List<Map<String, dynamic>> myProjects = [];

  late Future<List<String>> _myProjectsFuture;

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
  
  @override
  void initState() {
    super.initState();
    _myProjectsFuture = context.read<WalletConnectControl>().getMyProjectAddresses();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIfRedirectNeeded();
    });
  }

  Future<void> checkIfRedirectNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldRedirect = prefs.getBool('justSubmittedProject') ?? false;

    if (shouldRedirect) {
      await prefs.remove('justSubmittedProject');

      final status = prefs.getString('uploadStatus') ?? '';
      final uploadedCidsJson = prefs.getString('uploadedCIDs') ?? '{}';
      final cids = Map<String, String>.from(jsonDecode(uploadedCidsJson));

      // Push to ProposeProjectScreen and pass data
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProposeProjectScreen(
            restoredUploadStatus: status,
            restoredCIDs: cids,
          ),
        ),
      );
    }
  }



  Future<String> fetchTextFromIpfs(String cid) async {
    try {
      final uri = Uri.parse("https://ipfs.io/ipfs/$cid");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception("Failed to load from IPFS");
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Widget buildCidRow(String label, String cid, {bool isImage = false}) {
    final url = "https://ipfs.io/ipfs/$cid";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label CID: $cid"),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: cid));
                  Fluttertoast.showToast(msg: "$label CID copied!");
                },
                child: const Text("Copy CID"),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: const Text("Open on IPFS"),
              ),
            ],
          ),
          if (isImage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.network(url, height: 150, fit: BoxFit.cover),
            ),
          if (!isImage)
            FutureBuilder<String>(
              future: fetchTextFromIpfs(cid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading preview...");
                } else if (snapshot.hasError) {
                  return Text("Failed to load: ${snapshot.error}");
                } else {
                  return Text(
                    "Preview: ${snapshot.data}",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  );
                }
              },
            ),
        ],
      ),
    );
  }
  Widget bodyState(
    List<Map<String, Object>> fundingPosts,
    List<Map<String, Object>> activePosts,
    bool isLogin,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "🔹 Funding Projects",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (fundingPosts.isEmpty)
                    const Text("No funding projects found."),
                  ...fundingPosts.map((post) => SingleProjectCard(
                      projectAddress: post['projectAddress']?.toString() ?? "",
                      projectName: post['projectName']?.toString() ?? "Untitled",
                      imageUrl: post['imageUrl']?.toString() ?? "",
                      detailCid: post['detailCid']?.toString() ?? "",
                      goal: post['goal'] is num ? (post['goal'] as num).toDouble() : 0.0,
                      raised: post['raised'] is num ? (post['raised'] as num).toDouble() : 0.0,
                      deadline: post['deadline']?.toString() ?? "",
                      status: post['status']?.toString() ?? "",
                      founder: post['founder']?.toString() ?? "Unknown",
                      tokenAddress: post['tokenAddress']?.toString() ?? "",

                        // projectName: post['projectName'] as String,
                        // imageUrl: post['imageUrl'] as String,
                        // detailCid: post['detailCid'] as String,
                        // goal: post['goal'] as double,
                        // raised: post['raised'] as double,
                        // deadline: post['deadline'] as String,
                        // status: post['status'] as String,
                        // founder: post['founder'] as String,
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
                                      projectAddress: post['address'] as String,
                                      token: token,
                                      amount: amount,
                                      projectName: projectName,
                                    );
                              },
                              post['projectName'] as String,
                              post['imageUrl'] as String,
                              post['address'] as String,
                            );
                          } else {
                            Fluttertoast.showToast(msg: "Please login to invest");
                          }
                        },
                        onVote: () => print('Vote clicked for ${post['projectName']}'),
                      )),
                  const SizedBox(height: 24),
                  const Text(
                    "🔸 Active Projects",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (activePosts.isEmpty)
                    const Text("No active projects found."),
                  ...activePosts.map((post) => SingleProjectCard(
                      projectAddress: post['projectAddress']?.toString() ?? "",
                      projectName: post['projectName']?.toString() ?? "Untitled",
                      imageUrl: post['imageUrl']?.toString() ?? "",
                      detailCid: post['detailCid']?.toString() ?? "",
                      goal: post['goal'] is num ? (post['goal'] as num).toDouble() : 0.0,
                      raised: post['raised'] is num ? (post['raised'] as num).toDouble() : 0.0,
                      deadline: post['deadline']?.toString() ?? "",
                      status: post['status']?.toString() ?? "",
                      founder: post['founder']?.toString() ?? "Unknown",
                      tokenAddress: post['tokenAddress']?.toString() ?? "",

                        // projectName: post['projectName'] as String,
                        // imageUrl: post['imageUrl'] as String,
                        // detailCid: post['detailCid'] as String,
                        // goal: post['goal'] as double,
                        // raised: post['raised'] as double,
                        // deadline: post['deadline'] as String,
                        // status: post['status'] as String,
                        // founder: post['founder'] as String,
                        onInvest: () {}, // Disabled for active projects
                        // onVote: () => print('Vote clicked for ${post['projectName']}'),
                        // onVote: () => handleVoteClick(context, post),
                        onVote: () async {
                          if (isLogin) {
                            print("🧭 Vote button clicked");

                            final decision = await showVoteConfirmationDialog(
                              context,
                              post['projectName']?.toString() ?? 'this project',
                            );

                            print("👤 User decision: $decision");

                            if (decision != null) {
                              await context.read<WalletConnectControl>().voteOnProject(
                                projectAddress: post['address'].toString(),
                                decision: decision,
                              );
                            }
                          } else {
                            print("🚫 User not logged in");
                            Fluttertoast.showToast(msg: "Please login to vote");
                          }
                        },



                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


Future<bool?> showVoteConfirmationDialog(BuildContext context, String projectName) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Vote on $projectName'),
      content: const Text('Do you want to approve or reject the milestone?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Reject'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Approve'),
        ),
      ],
    ),
  );
}




  // List<Map<String, Object>> transferToPosts(List<Map<String, dynamic>> posts) {
    

  //   return posts.map((post) {
  //     final fundingBalance = post['fundingBalance'];
  //     final getGoal = post['goal'];

  //     final double raised = (fundingBalance is String)
  //         ? double.tryParse(fundingBalance) ?? 0.0
  //         : (fundingBalance as num?)?.toDouble() ?? 0.0;

  //     final double goal = (getGoal is String)
  //         ? double.tryParse(fundingBalance) ?? 0.0
  //         : (fundingBalance as num?)?.toDouble() ?? 0.0;

  //     return {
  //       'projectName': post['name'].toString() ?? "",
  //       'imageUrl': 'https://ipfs.io/ipfs/${post['photoCID'] ?? ''}',
  //       'detailCid': post['descCID'].toString() ?? "",
  //       'status': post['status'].toString() ?? "",
  //       'link': post['socialMediaCID'].toString() ?? "",
  //       'address': post['projectAddress'].toString() ?? "",
  //       'goal': goal,
  //       'raised': raised,
  //       'founder': post['founder'].toString() ?? "",
  //     };
  //   }).toList();
  // }
  // Future<List<Map<String, Object>>> transferToPosts(List<Map<String, dynamic>> posts) async {
  // // List<Map<String, Object>> transferToPosts(List<Map<String, dynamic>> posts) {
  //   print("🔍 Raw post data:");
  //   posts.forEach((p) => print(p));
  //   return posts.map((post) {
  //     final fundingBalance = post['fundingBalance'];
  //     final getGoal = post['goal'];

  //     final double raised = (fundingBalance is String)
  //         ? double.tryParse(fundingBalance) ?? 0.0
  //         : (fundingBalance as num?)?.toDouble() ?? 0.0;

  //     final double goal = (getGoal is String)
  //         ? double.tryParse(getGoal) ?? 0.0
  //         : (getGoal as num?)?.toDouble() ?? 0.0;

  //     final tokenAddress = await context.read<WalletConnectControl>().getTokenAddressFromManager(
  //       post['projectAddress'].toString(),
  //     );
  //     return {
  //       'projectAddress':  post['projectAddress']?.toString() ?? "",
  //       'projectName': post['name']?.toString() ?? "Untitled",
  //       'imageUrl': 'https://ipfs.io/ipfs/${post['photoCID'] ?? ''}',
  //       'detailCid': post['descCID']?.toString() ?? "",
  //       'status': post['status']?.toString() ?? "",
  //       'link': post['socialMediaCID']?.toString() ?? "",
  //       'address': post['projectAddress']?.toString() ?? "",
  //       'goal': goal,
  //       'raised': raised,
  //       'founder': post['founder']?.toString() ?? "Unknown",
  //       'deadline': post['deadline']?.toString() ?? "Unknown",
  //       'tokenAddress': tokenAddress,
  //     };
  //   }).toList();
  // }

  Future<List<Map<String, Object>>> transferToPosts(List<Map<String, dynamic>> posts) async {
    List<Map<String, Object>> result = [];

    for (final post in posts) {
      final fundingBalance = post['fundingBalance'];
      final getGoal = post['goal'];

      final double raised = (fundingBalance is String)
          ? double.tryParse(fundingBalance) ?? 0.0
          : (fundingBalance as num?)?.toDouble() ?? 0.0;

      final double goal = (getGoal is String)
          ? double.tryParse(getGoal) ?? 0.0
          : (getGoal as num?)?.toDouble() ?? 0.0;

      final tokenAddress = await context.read<WalletConnectControl>().getTokenAddressFromManager(
        post['projectAddress'].toString(),
      );

      result.add({
        'projectAddress': post['projectAddress']?.toString() ?? "",
        'projectName': post['name']?.toString() ?? "Untitled",
        'imageUrl': 'https://ipfs.io/ipfs/${post['photoCID'] ?? ''}',
        'detailCid': post['descCID']?.toString() ?? "",
        'status': post['status']?.toString() ?? "",
        'link': post['socialMediaCID']?.toString() ?? "",
        'address': post['projectAddress']?.toString() ?? "",
        'goal': goal,
        'raised': raised,
        'founder': post['founder']?.toString() ?? "Unknown",
        'deadline': post['deadline']?.toString() ?? "Unknown",
        'tokenAddress': tokenAddress,
      });
    }

    return result;
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

            return FutureBuilder<List<List<Map<String, Object>>>>(
              future: Future.wait([
                context.read<WalletConnectControl>().getAllFundingProject().then(transferToPosts),
                context.read<WalletConnectControl>().getAllActiveProject().then(transferToPosts),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  final List<Map<String, Object>> fundingPosts = snapshot.data![0];
                  final List<Map<String, Object>> activePosts = snapshot.data![1];

                  return bodyState(fundingPosts, activePosts, isLogin);
                } else {
                  return const Center(child: Text("No projects found."));
                }
              },
            );
          } else if (state is FetchHomeScreenActionButtonSuccess &&
              state.action == HomeScreenActionButton.connectWallet) {
            return const Center(
              child: Text("Please connect your wallet to view projects."),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  
  
  
  // @override
  // Widget build(BuildContext context) {
  //   context.read<WalletConnectControl>().fetchHomeScreenActionButton();
  //   return Scaffold(
  //     body: BlocBuilder<WalletConnectControl, Web3State>(
  //       builder: (context, state) {
  //         if (state is FetchHomeScreenActionButtonSuccess &&
  //             state.action == HomeScreenActionButton.interactWithContract) {
  //           isLogin = true;
  //           // return FutureBuilder<List<Map<String, dynamic>>>(
  //           return FutureBuilder<List<List<Map<String, dynamic>>>>(
  //             future: Future.wait([
  //               context.read<WalletConnectControl>().getAllFundingProject(),
  //               context.read<WalletConnectControl>().getAllActiveProject(),
  //             ]),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return const Center(child: CircularProgressIndicator());
  //               } else if (snapshot.hasData) {
  //                 final List<Map<String, dynamic>> fundingProjects = snapshot.data![0];
  //                 final List<Map<String, dynamic>> activeProjects = snapshot.data![1];

  //                 final fundingPosts = transferToPosts(fundingProjects);
  //                 final activePosts = transferToPosts(activeProjects);


  //                 return bodyState(fundingPosts, activePosts, isLogin);
  //               } else {
  //                 return const Center(child: Text("No projects found."));
  //               }
  //             },
  //           );
  //         } else if (state is FetchHomeScreenActionButtonSuccess &&
  //             state.action == HomeScreenActionButton.connectWallet) {
  //           return const Center(
  //             child: Text("Please connect your wallet to view projects."),
  //           );
  //         } else {
  //           return const Center(child: CircularProgressIndicator());
  //         }
  //       },
  //     ),
  //   );
  // }
}