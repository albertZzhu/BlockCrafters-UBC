import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:coach_link/Control/project_submission_service.dart';
import 'package:coach_link/Views/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';


class ProposeProjectScreen extends StatefulWidget {
  const ProposeProjectScreen({super.key});

  @override
  State<ProposeProjectScreen> createState() => _ProposeProjectScreenState();
}

class _ProposeProjectScreenState extends State<ProposeProjectScreen> {
  final nameController = TextEditingController();
  final socialMediaController = TextEditingController();
  final deadlineController = TextEditingController();
  final tokenNameController = TextEditingController();

  int? deadlineTimestamp;
  String? uploadStatus;

  PlatformFile? imageFile;
  PlatformFile? detailFile;
  PlatformFile? symbolFile;

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

    if (context.mounted && cids.length == 4) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("🎉 All Files Uploaded"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: cids.entries.map((e) => _cidRow(e.key, e.value)).toList(),
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

              // Pick Image Button
              CustomButton(
                label: 'Pick Project Image',
                onPressed: pickImageFile,
                styleType: ButtonStyleType.skyblue,
              ),
              if (imageFile != null)
                Text('Selected image: ${imageFile!.name}'),
              const SizedBox(height: 8),

              // Pick Detail File Button
              CustomButton(
                label: 'Upload Business Plan/Slides/Video',
                onPressed: pickDetailFile,
                styleType: ButtonStyleType.skyblue,
              ),
              if (detailFile != null)
                Text('Selected file: ${detailFile!.name}'),
              const SizedBox(height: 16),

              // Pick Token Symbol Button
              CustomButton(
                label: 'Upload Token Symbol Image',
                onPressed: pickSymbolFile,
                styleType: ButtonStyleType.skyblue,
              ),
              if (symbolFile != null)
                Text('Selected symbol image: ${symbolFile!.name}'),
              const SizedBox(height: 16),

              // Submit Button
              CustomButton(
                label: 'Submit Project',
                onPressed: submitProject,
                styleType: ButtonStyleType.orange,
              ),

              if (uploadStatus != null) ...[
                const SizedBox(height: 16),
                SelectableText(uploadStatus!),
              ],
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
    final match = RegExp(r'✅ (.*?) uploaded.*CID: (\w{46})').firstMatch(line);
    if (match != null) {
      final label = match.group(1)!;
      final cid = match.group(2)!;
      cids[label] = cid;
    }
  }

  return cids;
}
