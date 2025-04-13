import 'package:coach_link/Views/newPost.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'Views/StartPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:coach_link/Control/CoachesDBHelperFunctions_sqlite.dart';
import 'Control/WalletConnectControl.dart';
import 'package:coach_link/Routers.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
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
        routes: appRoutes,
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }
}
