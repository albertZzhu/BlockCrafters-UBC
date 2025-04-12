import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:coach_link/Control/project_submission_service.dart';

class AddMilestonePage extends StatefulWidget {
  final String projectAddress;
  final String projectName;
  final int projectStatus;
  final Function(
    String projectAddress,
    String name,
    String descriptionCid,
    double goal,
    int deadline,
    int projectStatus,
  )
  addMilestone;

  const AddMilestonePage({
    Key? key,
    required this.projectAddress,
    required this.projectName,
    required this.addMilestone,
    required this.projectStatus,
  }) : super(key: key);

  @override
  State<AddMilestonePage> createState() => _AddMilestonePageState();
}

class _AddMilestonePageState extends State<AddMilestonePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  String? _descriptionCid;
  bool _isLoading = false;
  int? _deadlineTimestamp;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Milestone')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(labelText: 'Goal'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _deadlineController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Deadline'),
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
                    23,
                    59,
                    59,
                  );

                  // Save actual timestamp in seconds
                  _deadlineTimestamp =
                      deadlineAtEndOfDay.millisecondsSinceEpoch ~/ 1000;

                  // Display just the date in the text field
                  _deadlineController.text =
                      deadlineAtEndOfDay.toIso8601String().split('T')[0];
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Upload Description File'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        PlatformFile? filePath = result.files.single;
        String cid = await ProjectSubmissionService.submitMilestoneDescription(
          name: _nameController.text,
          description: filePath,
        );
        setState(() {
          _descriptionCid = cid;
        });
      }
    } on PlatformException catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _goalController.text.isEmpty ||
        _deadlineController.text.isEmpty ||
        _descriptionCid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      double goal = double.parse(_goalController.text);

      widget.addMilestone(
        widget.projectAddress,
        _nameController.text,
        _descriptionCid!,
        goal,
        _deadlineTimestamp!,
        widget.projectStatus, // Assuming projectStatus is 0 for new milestones
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
