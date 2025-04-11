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
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


Widget ipfsCidPreview(BuildContext context, String label, String cid) {
  final ipfsUrl = 'https://ipfs.io/ipfs/$cid';
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label CID:', style: const TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(cid),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: cid));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label CID copied')),
                  );
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
    // loadMyProjects();
    _myProjectsFuture = context.read<WalletConnectControl>().getMyProjectAddresses();
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
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
                return Text("Preview: ${snapshot.data}", maxLines: 3, overflow: TextOverflow.ellipsis);
              }
            },
          ),
      ],
    ),
  );
}



Widget bodyState(List<Map<String, Object>> posts, bool isLogin) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          FutureBuilder<List<String>>(
            future: context.read<WalletConnectControl>().getMyProjectAddresses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Loading your projects..."),
                );
              }

              final addresses = snapshot.data!;
              if (addresses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("You haven't created any projects."),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: addresses.map((addr) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: context.read<WalletConnectControl>().getProjectInfo(addr),
                    builder: (context, infoSnap) {
                      if (!infoSnap.hasData) {
                        return Text("📦 $addr\nLoading...");
                      }

                      final info = infoSnap.data!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText("📦 Project Address: $addr"),
                            SelectableText("📛 Name: ${info['name']}"),
                            SelectableText("📅 Deadline: ${info['deadline']}"),
                            SelectableText("📝 Desc CID: ${info['descCID']}"),
                            SelectableText("🖼️ Photo CID: ${info['photoCID']}"),
                            SelectableText("🔗 Social CID: ${info['socialMediaCID']}"),
                            const Divider(),
                          ],


                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
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
                      );
                    } else {
                      Fluttertoast.showToast(msg: "Please login to invest");
                    }
                  },
                  onVote: () => print('Vote clicked for ${posts[index]['projectName']}'),
                );
              },
            ),
          ),
        ],
      ),
    ),
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

