import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../../services/project_submission_service.dart'; 
import '../../widgets/custom_button.dart'; 


class ProposeProjectScreen extends StatefulWidget {
  const ProposeProjectScreen({super.key});

  @override
  State<ProposeProjectScreen> createState() => _ProposeProjectScreenState();
}

class _ProposeProjectScreenState extends State<ProposeProjectScreen> {
  final nameController = TextEditingController();
  final goalController = TextEditingController();
  final deadlineController = TextEditingController();
  final descController = TextEditingController();
  String? uploadStatus;

  PlatformFile? imageFile;
  PlatformFile? detailFile;

  Future<void> pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        imageFile = result.files.single;
      });
    }
  }

  Future<void> pickDetailFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        detailFile = result.files.single;
      });
    }
  }

  Future<void> submitProject() async {
    if (imageFile == null || detailFile == null) {
      setState(() {
        uploadStatus = '❗ Please select both image and project detail file.';
      });
      return;
    }

    setState(() {
      uploadStatus = '📤 Uploading files and submitting...';
    });

    final result = await ProjectSubmissionService.submit(
      name: nameController.text,
      goal: goalController.text,
      deadline: deadlineController.text,
      descriptionText: descController.text,
      imageFile: imageFile!,
      detailFile: detailFile!,
    );

    setState(() {
      uploadStatus = result.statusMessage;
    });
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
            ),
            TextField(
              controller: goalController,
              decoration: const InputDecoration(labelText: 'Goal (in tokens)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(labelText: 'Deadline (YYYY-MM-DD)'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),

            // Pick Image Button
            CustomButton(
              label: 'Pick Project Image',
              onPressed: pickImageFile,
              styleType: ButtonStyleType.skyblue,
            ),
            if (imageFile != null)
              Text('📷 Selected image: ${imageFile!.name}'),
            const SizedBox(height: 8),

            // Pick Detail File Button
            CustomButton(
              label: 'Upload Business Plan/Slides/Video',
              onPressed: pickDetailFile,
              styleType: ButtonStyleType.skyblue,
            ),
            if (detailFile != null)
              Text('📄 Selected file: ${detailFile!.name}'),
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


