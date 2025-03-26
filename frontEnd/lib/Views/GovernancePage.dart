import 'package:flutter/material.dart';
import 'package:coach_link/Model/SampleProjectData.dart';
import 'package:coach_link/Model/Proposal.dart';

class Governancepage extends StatefulWidget {
  const Governancepage({super.key});

  @override
  State<Governancepage> createState() => _GovernancePageState();
}

class _GovernancePageState extends State<Governancepage> {
  final List<Proposal> sampleProposals =
      proposals.map((map) => Proposal.fromMap(map)).toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [Expanded(child: buildGonverenceList(sampleProposals))],
        ),
      ),
    );
  }

  Widget buildGonverenceList(List<Proposal> proposals) {
    return ListView.builder(
      itemCount: proposals.length,
      itemBuilder: (context, index) {
        final proposal = proposals[index];
        return buildGovernanceCard(proposal);
      },
    );
  }

  Widget buildGovernanceCard(Proposal proposal) {
    return Card(
      child: ListTile(
        onTap: () {},
        title: Text(proposal.title),
        subtitle: Text(
          proposal.description.length > 50
              ? '${proposal.description.substring(0, 50)}...'
              : proposal.description,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${proposal.views} views',
              style: TextStyle(color: Colors.lightBlue, fontSize: 14),
            ),
            Text('${proposal.proposalDate.toLocal()}'.split(' ')[0]),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
