import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:coach_link/Model/enum.dart';
import 'package:coach_link/Views/loader.dart';

class LoginSelectionPage extends StatefulWidget {
  const LoginSelectionPage({Key? key}) : super(key: key);

  @override
  _LoginSelectionPageState createState() => _LoginSelectionPageState();
}

class _LoginSelectionPageState extends State<LoginSelectionPage> {
  ReownAppKitModal? w3mService;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => context.read<WalletConnectControl>().instantiate(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletConnectControl, Web3State>(
      listenWhen:
          (Web3State previous, Web3State current) =>
              current is InitializeWeb3MSuccess ||
              current is FetchHomeScreenActionButtonSuccess,
      listener: (BuildContext context, Web3State state) {
        if (state is InitializeWeb3MSuccess) {
          setState(() => w3mService = state.service);

          context.read<WalletConnectControl>().fetchHomeScreenActionButton();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login', style: TextStyle(color: Colors.black)),
          leading: IconButton(
            style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(50),
              backgroundColor: MaterialStatePropertyAll(Colors.grey),
            ),
            onPressed: () {
              if (w3mService != null) {
                w3mService!.dispose();
              }
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: Container(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text(
                  'Login with Passphrase',
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: const Text(
                  'Use your recovery phrase to login',
                  style: TextStyle(fontSize: 15),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, '/passphraseLogin');
                },
              ),
              BlocBuilder<WalletConnectControl, Web3State>(
                buildWhen:
                    (Web3State previous, Web3State current) =>
                        current is FetchHomeScreenActionButtonSuccess,
                builder: (BuildContext context, Web3State state) {
                  if (w3mService != null &&
                      state is FetchHomeScreenActionButtonSuccess &&
                      state.action == HomeScreenActionButton.connectWallet) {
                    return AppKitModalConnectButton(
                      context: context,
                      appKit: w3mService!,
                      custom: ListTile(
                        leading: const Icon(Icons.wallet),
                        title: const Text(
                          'Login with Wallet',
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: const Text(
                          'Choose your wallet App to login',
                          style: TextStyle(fontSize: 15),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => w3mService!.openModalView(),
                      ),
                    );
                  } else {
                    return const Loader(height: 36);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
