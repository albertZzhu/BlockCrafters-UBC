import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom_button.dart'; 
import '../../config/app_colors.dart';

class ProjectCard extends StatelessWidget {
  final String projectName;
  final String imageUrl; // IPFS image URL
  final String detailCid; // IPFS file for "Learn More"
  final double goal;
  final double raised;
  final String deadline; // formatted date
  final String status;
  final VoidCallback onInvest;
  final VoidCallback onVote;

  const ProjectCard({
    super.key,
    required this.projectName,
    required this.imageUrl,
    required this.detailCid,
    required this.goal,
    required this.raised,
    required this.deadline,
    required this.status,
    required this.onInvest,
    required this.onVote,
  });

  double get progress => (raised / goal).clamp(0.0, 1.0);

  Future<void> _launchCID() async {
    final url = 'https://gateway.pinata.cloud/ipfs/$detailCid';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color.fromARGB(179, 245, 251, 253), 
      child: Container(
        
        height: 220,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left section: image + info
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _launchCID,
                    child: const Text('📄 Learn More'),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right section: progress, stats, buttons
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Goal: $goal  |  Raised: $raised', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color.fromARGB(255, 247, 244, 244),
                    
                    color: AppColors.lightBlue,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
                  Text('Deadline: $deadline', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Status: $status', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Invest',
                          onPressed: onInvest,
                          styleType: ButtonStyleType.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'Vote',
                          onPressed: onVote,
                          styleType: ButtonStyleType.skyblue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
