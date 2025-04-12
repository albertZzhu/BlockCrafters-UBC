library wallet_connect_control;

import 'package:coach_link/Configs/web3_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coach_link/Model/enum.dart';
import 'package:coach_link/Configs/FunctionName.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

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
  List<String> priceList = [];

  /// * This method is used to initialize the Web3Modal instance.
  /// * It sets up the AppKitModal with the necessary parameters and metadata.
  /// * It also listens to wallet connection, network change, and disconnection events.
  /// * The method emits different states based on the success or failure of the initialization.
  /// * @param context The BuildContext of the widget.
  /// * @return A Future that completes when the initialization is done.
  /// * @throws Exception If there is an error during initialization.
  /// * @throws ReownAppKitModalException If there is an error with the AppKitModal.
  Future<void> instantiate(BuildContext context) async {
    // AppKit Modal instance
    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: 'd1711622cb4cda1dd4fdb3d5aeba9413',
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

  /// * This method is used to select a specific blockchain network.
  /// * It sets the chain ID, name, currency, RPC URL, and explorer URL for the selected network.
  /// * It also emits a state indicating the success of the operation.
  /// * @return A Future that completes when the selection is done.
  /// * @throws Exception If there is an error during selection.
  /// * @throws ReownAppKitModalException If there is an error with the AppKitModal.
  /// * @throws ReownAppKitModalNetworkInfoException If there is an error with the network info.
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

  /// * This method is used to end the session with the wallet.
  /// * It has not been used for now, but it can be used to disconnect from the wallet.
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

  /// * This method is used to listen to network changes in the wallet.
  /// * It subscribes to the network change event and updates the chain ID.
  /// * It also emits a state indicating the success of the operation.
  /// * @return A Future that completes when the listening is done.
  /// * @throws Exception If there is an error during listening.
  /// * @throws ReownAppKitModalException If there is an error with the AppKitModal.
  /// * @throws ReownAppKitModalNetworkInfoException If there is an error with the network info.
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

  /// * This method is used to listen to wallet disconnection events.
  /// * It subscribes to the disconnection event and updates the connection status.
  /// * It also emits a state indicating the success of the operation.
  Future<void> listenToWalletDisconnect() async {
    try {
      _appKitModal.onModalDisconnect.subscribe((ModalDisconnect? event) {
        _isConnected = false;
        Fluttertoast.showToast(msg: "Disconnected from Wallet");
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

  /// * This method is used to fetch the action button for the home screen.
  /// * It checks if the user is logged in via email or connected to a wallet.
  /// * It emits different states based on the connection status.
  /// * @return A Future that completes when the fetching is done.
  Future<void> fetchHomeScreenActionButton() async {
    if (!_isConnected) {
      emit(
        const FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.connectWallet,
        ),
      );
    } else if (_isConnected) {
      chainId = await _appKitModal.selectedChain!.chainId;
      final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(
        chainId,
      );
      final uid = _appKitModal.session!.getAddress(namespace)!;
      emit(
        FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.interactWithContract,
          uid: uid,
        ),
      );
    }
  }

  Future<void> fetchTokenPrices(double amount) async {
    if (priceList.isEmpty) {
      priceList = await getTokenPriceInUSD(amount);
    }
    emit(FetchTokenPriceInUSDSuccess(priceList: priceList));
  }

  /// * This method is used to invest the deployed project contract.
  /// * It takes the project address, token, amount, and function name as parameters.
  /// * It emits different states based on the success or failure of the investment.
  /// * @param projectAddress The address of the project.
  /// * @param token The token to be used for investment.
  /// * @param amount The amount to be invested.
  /// * @param projectName The name of the project to be invested.
  /// * @return A Future that completes when the investment is done.
  Future<void> investProject({
    required String projectAddress,
    required String token,
    required String amount,
    required String projectName,
  }) async {
    try {
      final List<String> accounts =
          _appKitModal.session?.getAccounts() ?? <String>[];

      if (accounts.isNotEmpty) {
        final String sender = accounts.first.split(':').last;

        _appKitModal.launchConnectedWallet();

        await _appKitModal.requestWriteContract(
          topic: _appKitModal.session?.topic ?? '',
          chainId: _appKitModal.selectedChain!.chainId,
          deployedContract: await deployedProjectContract(
            projectAddress,
            projectName,
          ),
          functionName: investFunctionName,
          transaction: Transaction(
            to: EthereumAddress.fromHex(projectAddress),
            from: EthereumAddress.fromHex(sender),
            value: EtherAmount.fromBigInt(
              EtherUnit.wei,
              BigInt.from(pow(10, 18) * double.parse(amount)),
            ),
          ),
        );
        emit(
          InvestmentSuccess(
            transactionHash: 'transactionHash',
            projectAddress: projectAddress,
          ),
        );
      }
    } catch (e) {
      emit(
        InvestmentFailed(
          errorCode: 'e.toString()',
          message: 'Investment Failed',
        ),
      );
    }
  }

  /// * This method is used to submit a new project to the crowdfunding platform.
  /// * It connects to the user's wallet, prepares the contract interaction, and sends
  ///   a transaction to call the `createProject` function on the manager contract.
  /// * It emits different states based on the success or failure of the submission.
  /// * @param name The name of the project.
  /// * @param deadline The funding deadline of the project (as a Unix timestamp).
  /// * @param tokenName The name of the token associated with the project.
  /// * @param detailCid The IPFS CID for the project's detailed description.
  /// * @param imageCid The IPFS CID for the project's image.
  /// * @param socialMediaCid The IPFS CID for the project's social media links.
  /// * @param tokenSymbolCid The IPFS CID for the token symbol.
  /// * @return A Future that completes when the submission process is finished.

  Future<void> submitProject({
    required String name,
    required int deadline,
    required String tokenName,
    required String detailCid,
    required String imageCid,
    required String socialMediaCid,
    required String tokenSymbolCid,
  }) async {
    emit(ProjectSubmissionInProgress());

    try {
      // Get connected wallet
      final List<String> accounts =
          _appKitModal.session?.getAccounts() ?? <String>[];
      if (accounts.isEmpty) {
        emit(ProjectSubmissionFailed(message: 'No connected wallet found.'));
        print('No connected wallet found.');
        return;
      }

      final String sender = accounts.first.split(':').last;
      print('Wallet connected: $sender');

      // Load contract ABI and address
      final String managerContractAddress =
          dotenv.env['MANAGER_CONTRACT_ADDRESS']!;
      print('Using contract address: $managerContractAddress');

      final DeployedContract contract = await deployedManagerContract();
      print('Contract loaded successfully.');

      _appKitModal.launchConnectedWallet();
      print('Wallet launched.');

      // Send the transaction
      print('Sending transaction with parameters:');
      print('Name: $name');
      print('Deadline: $deadline');
      print('Token Name: $tokenName');
      print('Detail CID: $detailCid');
      print('Image CID: $imageCid');
      print('Social Media CID: $socialMediaCid');
      print('Token Symbol CID: $tokenSymbolCid');

      await _appKitModal.requestWriteContract(
        topic: _appKitModal.session?.topic ?? '',
        chainId: _appKitModal.selectedChain!.chainId,
        deployedContract: contract,
        functionName: 'createProject',
        transaction: Transaction(
          to: EthereumAddress.fromHex(managerContractAddress),
          from: EthereumAddress.fromHex(sender),
        ),
        parameters: [
          name,
          BigInt.from(deadline),
          detailCid,
          imageCid,
          socialMediaCid,
          tokenName,
          tokenSymbolCid,
        ],
      );
      print('Transaction sent successfully.');

      emit(ProjectSubmissionSuccess());
    } catch (e) {
      emit(ProjectSubmissionFailed(message: 'Project submission failed: $e'));
      print(
        'Error during project submission: $e',
      ); // Log the error to help with debugging
    }
  }

  Future<List<String>> getMyProjectAddresses() async {
    try {
      final List<String> accounts =
          _appKitModal.session?.getAccounts() ?? <String>[];
      if (accounts.isEmpty) throw Exception('No wallet connected');
      final String userAddress = accounts.first.split(':').last;

      final contract = await deployedManagerContract();

      final List<dynamic> result = await _appKitModal.requestReadContract(
        topic: _appKitModal.session?.topic ?? '',
        chainId: _appKitModal.selectedChain!.chainId,
        deployedContract: contract,
        functionName: 'getFounderProjects',
        parameters: [EthereumAddress.fromHex(userAddress)],
      );

      // 🔥 Fix: handle nested list correctly
      final List<dynamic> addressList = result.first as List;
      final List<String> addresses =
          addressList.map((e) => e.toString()).toList();

      print("✅ My projects addresses: $addresses");
      return addresses;
    } catch (e) {
      print('Error fetching project addresses: $e');
      return [];
    }
  }
Future<List<String>> getAllActiveProjectAddresses() async {
  try {
    final contract = await deployedManagerContract();

    final List<dynamic> result = await _appKitModal.requestReadContract(
      topic: _appKitModal.session?.topic ?? '',
      chainId: _appKitModal.selectedChain!.chainId,
      deployedContract: contract,
      functionName: 'getAllActiveProjects',
      parameters: [], // no parameters
    );

    // result should be a List<dynamic> of EthereumAddress or Strings
    final List<String> addresses = (result.first as List)
        .map((e) => e.toString())
        .toList();

    print("✅ All Active Projects addresses: $addresses");
    return addresses;
  } catch (e) {
    print('Error fetching active project addresses: $e');
    return [];
  }
}
Future<List<String>> getAllFundingProjectAddresses() async {
  try {
    final contract = await deployedManagerContract();

    final List<dynamic> result = await _appKitModal.requestReadContract(
      topic: _appKitModal.session?.topic ?? '',
      chainId: _appKitModal.selectedChain!.chainId,
      deployedContract: contract,
      functionName: 'getAllFundingProjects',
      parameters: [], // no parameters
    );

    // result should be a List<dynamic> of EthereumAddress or Strings
    final List<String> addresses = (result.first as List)
        .map((e) => e.toString())
        .toList();

    print("✅ All Funding Projects addresses: $addresses");
    return addresses;
  } catch (e) {
    print('Error fetching project addresses: $e');
    return [];
  }
}
Future<Map<String, dynamic>> getProjectInfo(String projectAddress) async {
  try {
    final contract = await deployedProjectContract(projectAddress, "");

    final topic = _appKitModal.session?.topic ?? '';
    final chainId = _appKitModal.selectedChain!.chainId;

    Future<List<dynamic>> call(String fn) =>
        _appKitModal.requestReadContract(
          topic: topic,
          chainId: chainId,
          deployedContract: contract,
          functionName: fn,
        );

    final name = await call('name');
    final fundingBalance = await call('fundingBalance');
    final frozenFund = await call('frozenFund');
    final fundingDone = await call('fundingDone');
    final currentMilestone = await call('currentMilestone');
    final status = await call('status');
    final goal = await call('getProjectFundingGoal');
    final deadline = await call('fundingDeadline');
    final descCID = await call('descCID');
    final photoCID = await call('photoCID');
    final socialCID = await call('socialMediaLinkCID');
    final founder = await call('founder');
    final projectId = await call('projectId');

    return {
      'projectAddress': projectAddress,
      'projectId': projectId.first.toString(),
      'founder': founder.first.toString(),
      'name': name.first.toString(),
      'fundingBalance': fundingBalance.first.toString(),
      'goal': goal.first.toString(),
      'frozenFund': frozenFund.first.toString(),
      'fundingDone': fundingDone.first.toString(),
      'currentMilestone': currentMilestone.first.toString(),
      'status': status.first.toString(),
      'deadline': DateTime.fromMillisecondsSinceEpoch(
        BigInt.parse(deadline.first.toString()).toInt() * 1000,
      ).toString(),
      'descCID': descCID.first.toString(),
      'photoCID': photoCID.first.toString(),
      'socialMediaCID': socialCID.first.toString(),
    };
  } catch (e) {
    print('❌ Error loading project info: $e');
    return {'error': e.toString()};
  }
}

  Future<List<Map<String, dynamic>>> getSelfProposedProject() async {
    List<Map<String, dynamic>> result = [];
    try {
      List<String> projectAddressList = await getMyProjectAddresses();
      if (projectAddressList.isNotEmpty) {
        for (String projectAddress in projectAddressList) {
          Map<String, dynamic> projectInfo = await getProjectInfo(
            projectAddress,
          );
          result.add(projectInfo);
        }
      }
    } catch (e) {
      /// Handle error
    }
    print(result);
    return (result);
  }



    Future<List<Map<String, dynamic>>> getAllFundingProject() async {
    List<Map<String, dynamic>> result = [];
    try {
      List<String> projectAddressList = await getAllFundingProjectAddresses();
      if (projectAddressList.isNotEmpty) {
        for (String projectAddress in projectAddressList) {
          Map<String, dynamic> projectInfo = await getProjectInfo(
            projectAddress,
          );
          result.add(projectInfo);
        }
      }
    } catch (e) {
      /// Handle error
    }
    return (result);
  }

      Future<List<Map<String, dynamic>>> getAllActiveProject() async {
    List<Map<String, dynamic>> result = [];
    try {
      List<String> projectAddressList = await getAllActiveProjectAddresses();
      if (projectAddressList.isNotEmpty) {
        for (String projectAddress in projectAddressList) {
          Map<String, dynamic> projectInfo = await getProjectInfo(
            projectAddress,
          );
          result.add(projectInfo);
        }
      }
    } catch (e) {
      /// Handle error
    }
    return (result);
  }

  Future<List<String>> getTokenPriceInUSD(double amount) async {
    List<String> result = [];
    try {
      final List<String> accounts =
          _appKitModal.session?.getAccounts() ?? <String>[];

      if (accounts.isNotEmpty) {
        final String sender = accounts.first.split(':').last;

        //_appKitModal.launchConnectedWallet();

        final List<dynamic> tempQueryETH = await _appKitModal
            .requestReadContract(
              topic: _appKitModal.session?.topic ?? '',
              chainId: _appKitModal.selectedChain!.chainId,
              deployedContract: await deployedPriceFeedContract(),
              functionName: priceFeedToUSDFunctionName,
              parameters: ["ETH", BigInt.from(amount)],
            );
        result.add(tempQueryETH[0].toString());
        final List<dynamic> tempQueryBTC = await _appKitModal
            .requestReadContract(
              topic: _appKitModal.session?.topic ?? '',
              chainId: _appKitModal.selectedChain!.chainId,
              deployedContract: await deployedPriceFeedContract(),
              functionName: priceFeedToUSDFunctionName,
              parameters: ["BTC", BigInt.from(amount)],
            );
        result.add(tempQueryBTC[0].toString());
      }
    } catch (e) {
      emit(
        InvestmentFailed(
          errorCode: 'e.toString()',
          message: 'Investment Failed',
        ),
      );
    }
    return (result);
  }

  Future<void> addMileStone(
    String projectAddress,
    String name,
    String descCID,
    double goal,
    int deadline,
    int projectStatus,
  ) async {
    try {
      final List<String> accounts =
          _appKitModal.session?.getAccounts() ?? <String>[];

      if (accounts.isNotEmpty) {
        final String sender = accounts.first.split(':').last;

        _appKitModal.launchConnectedWallet();

        DeployedContract contract = await deployedProjectContract(
          projectAddress,
          name,
        );

        await _appKitModal.requestWriteContract(
          topic: _appKitModal.session?.topic ?? '',
          chainId: _appKitModal.selectedChain!.chainId,
          deployedContract: contract,
          functionName: addMilestoneFunctionName,
          transaction: Transaction(
            to: EthereumAddress.fromHex(projectAddress),
            from: EthereumAddress.fromHex(sender),
          ),
          parameters: [
            name,
            descCID,
            BigInt.from(pow(10, 18) * goal),
            BigInt.from(deadline),
          ],
        );

        if (projectStatus == 0) {
          await _appKitModal.requestWriteContract(
            topic: _appKitModal.session?.topic ?? '',
            chainId: _appKitModal.selectedChain!.chainId,
            deployedContract: contract,
            functionName: getStartProjectFunctionName,
            transaction: Transaction(
              to: EthereumAddress.fromHex(projectAddress),
              from: EthereumAddress.fromHex(sender),
            ),
          );
        }
      }
    } catch (e) {}
  }

  Future<void> withdraw(String projectAddress, String projectName) async {
    try {
      final List<String> accounts =
          _appKitModal.session?.getAccounts() ?? <String>[];

      if (accounts.isNotEmpty) {
        final String sender = accounts.first.split(':').last;

        _appKitModal.launchConnectedWallet();

        await _appKitModal.requestWriteContract(
          topic: _appKitModal.session?.topic ?? '',
          chainId: _appKitModal.selectedChain!.chainId,
          deployedContract: await deployedProjectContract(
            projectAddress,
            projectName,
          ),
          functionName: withdrawFunctionName,
          transaction: Transaction(
            to: EthereumAddress.fromHex(projectAddress),
            from: EthereumAddress.fromHex(sender),
          ),
        );
      }
    } catch (e) {}
  }

  Future<List<dynamic>> getMilestoneList(String projectAddress) async {
    List<dynamic> result = [];
    try {
      final List<String> accounts =
          _appKitModal.session?.getAccounts() ?? <String>[];
      if (accounts.isNotEmpty) {
        final contract = await deployedProjectContract(projectAddress, "");

        _appKitModal.launchConnectedWallet();

        result = await _appKitModal.requestReadContract(
          topic: _appKitModal.session?.topic ?? '',
          chainId: _appKitModal.selectedChain!.chainId,
          deployedContract: contract,
          functionName: getMilestoneListFunctionName,
        );
      }
    } catch (e) {
      print('Error fetching milestone list: $e');
      return [];
    }
    return (result);
  }
}
