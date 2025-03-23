import 'package:flutter/material.dart';
import '../../widgets/top_nav_bar.dart';

class ConnectWalletScreen extends StatelessWidget {
  const ConnectWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: Center(child: Text('ConnectWalletScreen Screen')),
    );
  }
}
