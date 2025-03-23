import 'package:flutter/material.dart';
import '../views/home/home_screen.dart';
import '../views/projects/project_list_screen.dart';
import '../views/projects/project_detail_screen.dart';
import '../views/projects/propose_project_screen.dart';
import '../views/community/proposal_list_screen.dart';
import '../views/community/proposal_detail_screen.dart';
import '../views/connect/connect_wallet_screen.dart';
import '../views/connect/user_dashboard_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => HomeScreen(),
  '/projects': (context) => ProjectListScreen(),
  '/community': (context) => ProposalListScreen(),
  '/connect': (context) => ConnectWalletScreen(),
  '/proposeProject': (context) => ProposeProjectScreen(),
  // '/projectDetail': (context) => ProjectDetailScreen(), 
  // '/proposalDetail': (context) => ProposalDetailScreen(), 
  // '/dashboard': (context) => UserDashboardScreen(),
};

