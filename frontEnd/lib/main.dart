import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'routes/app_routes.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CFDApp());
}

class CFDApp extends StatelessWidget {
  const CFDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CFD Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
