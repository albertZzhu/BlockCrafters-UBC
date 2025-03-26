library wallet_connect_control;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Model/enum.dart';

part 'Web3ModalStates.dart';

class WalletConnectControl extends Cubit<Web3State> {
  /*static final WalletConnectControl _instance =
      WalletConnectControl._internal();*/

  WalletConnectControl() : super(const Web3State());

  /*factory WalletConnectControl(BuildContext context) {
    if (!_instance._isInitialized) {
      _instance.instantiate(context);
    }
    return _instance;
  }*/
  late ReownAppKitModal _appKitModal;
  late ReownAppKitModalSession session;
  bool _isConnected = false;
  bool get isLoggedInViaEmail =>
      _appKitModal.session?.connectedWalletName == 'Email Wallet';
  String chainId = "";

  Future<void> instantiate(BuildContext context) async {
    // AppKit Modal instance
    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: 'ca39991258c8cb8f99a5ff8eae88b6c5',
        metadata: const PairingMetadata(
          name: 'CrowdFund App',
          description:
              'We are CrowdFund, a decentralized crowdfunding platform.',
          url: 'http://localhost:4300',
          icons: ['assets/banner.png'],
          redirect: Redirect(
            native: 'crowdfund://',
            universal: 'https://crowdfund.com/',
            linkMode: true,
          ),
        ),
        includedWalletIds: <String>{
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // metamask
          '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0', // trust
          'e9ff15be73584489ca4a66f64d32c4537711797e30b6660dbcb71ea72a42b1f4', // exodus
          'f2436c67184f158d1beda5df53298ee84abfc367581e4505134b5bcf5f46697d', // crypto.com
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // coinbase
          '9414d5a85c8f4eabc1b5b15ebe0cd399e1a2a9d35643ab0ad22a6e4a32f596f0', // zengo
          '84b43e8ddfcd18e5fcb5d21e7277733f9cccef76f7d92c836d0e481db0c70c04', // blockchain.com
        },
      );
      await _appKitModal.init();
      selectChain();

      fetchHomeScreenActionButton();

      listenToWalletConnection();
      listenToWalletNetworkChange();
      listenToWalletDisconnect();

      emit(InitializeWeb3MSuccess(service: _appKitModal));
    } catch (e) {
      emit(InitializeWeb3MFailed());
    }
  }

  Future<void> selectChain() async {
    await _appKitModal.selectChain(
      ReownAppKitModalNetworkInfo(
        chainId: '11155111',
        name: 'Sepolia',
        currency: 'ETH',
        rpcUrl: 'https://1rpc.io/sepolia',
        explorerUrl: 'https://sepolia.etherscan.io/',
      ),
    );
  }

  Future<void> endSession() async {
    await _appKitModal.disconnect();
  }

  Future<void> listenToWalletConnection() async {
    try {
      _appKitModal.onModalConnect.subscribe((ModalConnect? event) {
        _isConnected = true;
        Fluttertoast.showToast(msg: "Connected to MetaMask");
        fetchHomeScreenActionButton();
      });
    } catch (e) {
      emit(
        const WalletConnectionFailed(
          errorCode: '',
          message: 'Wallet Connection Failed',
        ),
      );
    }
  }

  Future<void> listenToWalletNetworkChange() async {
    try {
      _appKitModal.onModalNetworkChange.subscribe((ModalNetworkChange? event) {
        chainId = event!.chainId;
        Fluttertoast.showToast(msg: "Network changed");
      });
    } catch (e) {
      emit(
        const WalletConnectionFailed(
          errorCode: '',
          message: 'Wallet Network Change Failed',
        ),
      );
    }
  }

  Future<void> listenToWalletDisconnect() async {
    try {
      _appKitModal.onModalDisconnect.subscribe((ModalDisconnect? event) {
        _isConnected = false;
        Fluttertoast.showToast(msg: "Disconnected from MetaMask");

        fetchHomeScreenActionButton();
      });
    } catch (e) {
      emit(
        const WalletConnectionFailed(
          errorCode: '',
          message: 'Wallet Disconnection Failed',
        ),
      );
    }
  }

  Future<void> fetchHomeScreenActionButton() async {
    if (isLoggedInViaEmail) {
      emit(
        const FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.upgradeWallet,
        ),
      );
    } else if (!_isConnected) {
      emit(
        const FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.connectWallet,
        ),
      );
    } else if (_isConnected) {
      /*if (_appKitModal.selectedChain == null) {
        await _appKitModal.init();
        await selectChain();
      }*/
      chainId = await _appKitModal.selectedChain!.chainId;
      final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(
        chainId,
      );
      final uid = _appKitModal.session!.getAddress(namespace)!;
      emit(
        FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.writeToContract,
          uid: uid,
        ),
      );
    }
  }
}
