import 'package:blockercrafter/config/app_colors.dart';
import 'package:flutter/material.dart';
import '../../widgets/top_nav_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/project_card.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 3 Sample projects
    final projects = [
      {
        'projectName': 'GreenBlock',
        'imageUrl': 'https://via.placeholder.com/150',
        'detailCid': 'QmExampleCID1',
        'goal': 100.0,
        'raised': 55.0,
        'deadline': '2025-04-15',
        'status': 'Active',
      },
      {
        'projectName': 'CryptoGarden',
        'imageUrl': 'https://via.placeholder.com/150',
        'detailCid': 'QmExampleCID2',
        'goal': 200.0,
        'raised': 120.0,
        'deadline': '2025-05-01',
        'status': 'Approved',
      },
      {
        'projectName': 'ChainFund',
        'imageUrl': 'https://via.placeholder.com/150',
        'detailCid': 'QmExampleCID3',
        'goal': 150.0,
        'raised': 150.0,
        'deadline': '2025-04-10',
        'status': 'Completed',
      },
    ];
    return Scaffold(
      appBar: const TopNavBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const SizedBox(height: 20),

          // Project cards
          for (final project in projects)
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: ProjectCard(
                  projectName: project['projectName'] as String,
                  imageUrl: project['imageUrl'] as String,
                  detailCid: project['detailCid'] as String,
                  goal: project['goal'] as double,
                  raised: project['raised'] as double,
                  deadline: project['deadline'] as String,
                  status: project['status'] as String,
                  onInvest:
                      () =>
                          print('Invest clicked for ${project['projectName']}'),
                  onVote:
                      () => print('Vote clicked for ${project['projectName']}'),
                ),
              ),
            ),

          const SizedBox(height: 32),

          // 📣 CTA Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8ECAE6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Got a great idea? 💡 \nStart proposing your project now!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  label: 'Propose New Project',
                  styleType: ButtonStyleType.white,
                  onPressed:
                      () => Navigator.pushNamed(context, '/proposeProject'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
