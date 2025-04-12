import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:coach_link/Control/project_submission_service.dart';
import 'package:coach_link/Views/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 



class ProposeProjectScreen extends StatefulWidget {
  final String? restoredUploadStatus;
  final Map<String, String>? restoredCIDs;
  const ProposeProjectScreen({Key? key, this.restoredUploadStatus, this.restoredCIDs}) : super(key: key);
  
  // const ProposeProjectScreen({super.key});

  @override
  State<ProposeProjectScreen> createState() => _ProposeProjectScreenState();
}

class _ProposeProjectScreenState extends State<ProposeProjectScreen> {
  String? uploadStatus;
  Map<String, String> uploadedCIDs = {};

  final nameController = TextEditingController();
  final socialMediaController = TextEditingController();
  final deadlineController = TextEditingController();
  final tokenNameController = TextEditingController();
  // Map<String, String> uploadedCIDs = {};


  int? deadlineTimestamp;
  // String? uploadStatus;

  PlatformFile? imageFile;
  PlatformFile? detailFile;
  PlatformFile? symbolFile;

  @override
  void initState() {
    super.initState();

    // If returning from MetaMask and restored data exists
    if (widget.restoredUploadStatus != null && widget.restoredCIDs != null) {
      uploadStatus = widget.restoredUploadStatus!;
      uploadedCIDs = widget.restoredCIDs!;

      // Delay dialog until after build
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🎉 All Files Uploaded through IPFS"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: uploadedCIDs.entries
                    .map((e) => _cidRow(e.key, e.value))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      });
    }
  }

  Widget _cidRow(String label, String cid) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label CID:", style: const TextStyle(fontWeight: FontWeight.bold)),
        SelectableText(cid),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: cid));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$label CID copied")),
                );
              },
              child: const Text("Copy"),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                final url = "https://ipfs.io/ipfs/$cid";
                openUrl(url);
              },
              child: const Text("View on IPFS"),
            ),
          ],
        ),
      ],
    ),
  );
}


  Future<void> pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        imageFile = result.files.single;
      });
    }
  }

  Future<void> pickDetailFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        detailFile = result.files.single;
      });
    }
  }

  Future<void> pickSymbolFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        symbolFile = result.files.single;
      });
    }
  }

  Future<void> submitProject() async {
    if (nameController.text.trim().isEmpty || tokenNameController.text.trim().isEmpty) {
      setState(() {
        uploadStatus = 'Project name and token name are required!';
      });
      return;
    }

    if (deadlineTimestamp == null) {
      setState(() {
        uploadStatus = 'Please pick a deadline date!';
      });
      return;
    }

    if (imageFile == null || detailFile == null || symbolFile == null) {
      List<String> missing = [];
      if (imageFile == null) missing.add("Project Image");
      if (detailFile == null) missing.add("Detail File");
      if (symbolFile == null) missing.add("Token Symbol");

      setState(() {
        uploadStatus = "Missing: ${missing.join(', ')}.";
      });
      return;
    }


    setState(() {
      uploadStatus = 'Uploading files and submitting...';
    });

    final result = await ProjectSubmissionService.submit(
      name: nameController.text,
      socialMedia: socialMediaController.text,
      deadline: deadlineTimestamp!,
      tokenName: tokenNameController.text,
      imageFile: imageFile!,
      detailFile: detailFile!,
      symbolFile: symbolFile!
    );

    setState(() {
      uploadStatus = result.statusMessage;
    });

    final cids = extractCIDs(result.statusMessage);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('justSubmittedProject', true);
    await prefs.setString('uploadStatus', result.statusMessage);
    await prefs.setString('uploadedCIDs', jsonEncode(cids));

    setState(() {
      uploadedCIDs = cids;
    });


    // Below, logic to submit project to contract
    // If CIDs are valid, submit project to contract via WalletConnectControl
    if (context.mounted && cids.length == 4) {
      try {
        // setState(() {
        //   uploadStatus = 'Submitting project to smart contract...';
        // });

        setState(() {
          uploadStatus = result.statusMessage + '\n\nSubmitting project to smart contract...';
        });

        if (!mounted) return;

        // setState(() {
        //   uploadStatus = 'Submitting project...';
        // });

        try {
          await context.read<WalletConnectControl>().submitProject(
            name: nameController.text,
            deadline: deadlineTimestamp!,
            tokenName: tokenNameController.text,
            detailCid: cids['Detail file']!,
            imageCid: cids['Image']!,
            socialMediaCid: cids['Social Media Link File']!,
            tokenSymbolCid: cids['Token Symbol']!,
          );

          // setState(() {
          //   uploadStatus = 'Project submitted successfully!';
          // });



          setState(() {
            uploadStatus = (uploadStatus ?? '') + '\nProject submitted successfully!';
          });
        } catch (e) {
          setState(() {
            uploadStatus = 'Submission failed: $e';
          });
          print('Error during project submission: $e');  // Log error for debugging
        }
      } catch (e) {
        setState(() {
          uploadStatus = 'Contract submission failed: $e';
        });
      }
    }
    // Above, logic to submit project to contract

    if (context.mounted && cids.length == 4) {
      setState(() {
            uploadStatus = (uploadStatus ?? '') + '\nProject submitted successfully!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propose Project')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                maxLength: 100,
              ),
              TextField(
                controller: socialMediaController,
                decoration: const InputDecoration(
                  labelText: 'Social Media Link',
                ),
              ),
              TextField(
                controller: deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );

                  if (pickedDate != null) {
                    // Set to 23:59:59 of the selected day
                    DateTime deadlineAtEndOfDay = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      23, 59, 59,
                    );

                    // Save actual timestamp in seconds
                    deadlineTimestamp = deadlineAtEndOfDay.millisecondsSinceEpoch ~/ 1000;

                    // Display just the date in the text field
                    deadlineController.text =
                        deadlineAtEndOfDay.toIso8601String().split('T')[0];
                  }
                },
              ),
                TextField(
                controller: tokenNameController,
                decoration: const InputDecoration(labelText: 'Token Name'),
              ),
              const SizedBox(height: 16),
              TextButton(
                child: Text('Upload Project Image'),
                onPressed: pickImageFile,
              ),
              if (imageFile != null)
                Text('Selected image: ${imageFile!.name}'),
              const SizedBox(height: 8),

              // Pick Detail File Button
              TextButton(
                child: Text('Upload Project Detail File'),
                onPressed: pickDetailFile,
              ),
              if (detailFile != null)
                Text('Selected file: ${detailFile!.name}'),
              const SizedBox(height: 16),

              // Pick Token Symbol Button
              TextButton(
                child: Text('Upload Token Symbol Image'),
                onPressed: pickSymbolFile,
              ),
              if (symbolFile != null)
                Text('Selected symbol image: ${symbolFile!.name}'),
              const SizedBox(height: 16),

              // Submit Button
              TextButton(
                child: Text('Submit Project'),
                onPressed: submitProject,
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white, // text color
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ),

            if (uploadStatus != null) ...[
              const SizedBox(height: 16),
              // SelectableText(uploadStatus!),
              const SizedBox(height: 8),
              if (uploadedCIDs.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("🎉 All Files Uploaded through IPFS"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: uploadedCIDs.entries
                                .map((e) => _cidRow(e.key, e.value))
                                .toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("View Project Files Uploaded"),
                ),
            ]


            ],
          ),
        ),
      ),
    );
  }
}

void openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri); // this is from the package
  } else {
    throw 'Could not launch $url';
  }
}

Map<String, String> extractCIDs(String message) {
  final Map<String, String> cids = {};
  final lines = message.split('\n');

  for (var line in lines) {
    final match = RegExp(r'(.*?) uploaded.*CID: (\w{46})').firstMatch(line);
    if (match != null) {
      final label = match.group(1)!;
      final cid = match.group(2)!;
      cids[label] = cid;
    }
  }

  return cids;
}
