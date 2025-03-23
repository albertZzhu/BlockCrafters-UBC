import 'package:flutter/material.dart';
import '../../widgets/top_nav_bar.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: Center(child: Text('ProjectDetailScreen Screen')),
    );
  }
}
