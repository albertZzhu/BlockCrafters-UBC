import 'package:flutter/material.dart';
import '../../widgets/top_nav_bar.dart';

class ProposalListScreen extends StatelessWidget {
  const ProposalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: Center(child: Text('ProposalListScreen Screen')),
    );
  }
}


