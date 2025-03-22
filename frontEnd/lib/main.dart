import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_link/Views/LoginSelectionPage.dart';
import 'package:coach_link/Views/newPost.dart';

import 'Views/LoginPage.dart';
import 'package:flutter/material.dart';
import 'Views/StartPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_link/Control/CoachesDBHelperFunctions_sqlite.dart';
import 'Control/WalletConnectControl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CoachesDBHelperFunctions.instance.database;
  await CoachesDBHelperFunctions.instance.sync();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<WalletConnectControl>(
          create: (context) => WalletConnectControl(),
        ),
      ],
      child: MaterialApp(
        title: 'CrowdFund App',
        initialRoute: '/',
        routes: {
          '/': (context) => StartPage(),
          '/login': (context) => const LoginSelectionPage(),
          '/passphraseLogin': (context) => const LoginPage(),
          '/newPost': (context) => newPost(),
        },
        //home: const LoginSelectionPage(),
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }
}
