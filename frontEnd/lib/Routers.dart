import 'package:flutter/material.dart';
import 'package:coach_link/Views/StartPage.dart';
import 'package:coach_link/Views/LoginSelectionPage.dart';
import 'package:coach_link/Views/LoginPage.dart';
//import 'package:coach_link/Views/ProjectListScreen.dart';
//import 'package:coach_link/Views/ProposalListScreen.dart';
//import 'package:coach_link/Views/ProposeProjectScreen.dart';
import 'package:coach_link/Views/propose_project_screen.dart';
import 'package:coach_link/Views/newPost.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => StartPage(),
  //'/projects': (context) => ProjectListScreen(),
  //'/community': (context) => ProposalListScreen(),
  '/login': (context) => const LoginSelectionPage(),
  '/passphraseLogin': (context) => const LoginPage(),
  '/newPost': (context) => newPost(),
  '/proposeProject': (context) => ProposeProjectScreen(),
  // '/projectDetail': (context) => ProjectDetailScreen(),
  // '/proposalDetail': (context) => ProposalDetailScreen(),
  // '/dashboard': (context) => UserDashboardScreen(),
};
