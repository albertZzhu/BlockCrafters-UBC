import 'package:flutter/material.dart';
import 'package:coach_link/Model/Proposal.dart';

class Governancedetailpage extends StatefulWidget {
  final Proposal proposal;
  const Governancedetailpage({Key? key, required this.proposal})
    : super(key: key);

  @override
  State<Governancedetailpage> createState() => _GovernanceDetailPageState();
}

class _GovernanceDetailPageState extends State<Governancedetailpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Governance Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proposal Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Detailed description of the proposal goes here. This section can include all relevant information about the proposal, including its implications and any necessary background information.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle voting logic here
              },
              child: Text('Vote'),
            ),
          ],
        ),
      ),
    );
  }
}
