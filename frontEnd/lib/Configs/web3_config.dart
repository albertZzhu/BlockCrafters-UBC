import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:reown_appkit/reown_appkit.dart';

Future<DeployedContract> deployedProjectContract(
  String contractAddress,
  String projectName,
) async {
  const String abiDirectory = 'lib/ContractInterface/CrowdFundProject.abi.json';
  final String contractABI = await rootBundle.loadString(abiDirectory);

  final DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(contractABI, projectName),
    EthereumAddress.fromHex(contractAddress),
  );

  return contract;
}

Future<DeployedContract> deployedManagerContract() async {
  final abiCode = await rootBundle.loadString(
    'lib/ContractInterface/CrowdfundingManager.json',
  );
  final contract = DeployedContract(
    ContractAbi.fromJson(abiCode, 'CrowdfundingManager'),
    EthereumAddress.fromHex(dotenv.env['MANAGER_CONTRACT_ADDRESS']!),
  );
  return contract;
}

Future<DeployedContract> deployedPriceFeedContract() async {
  const String abiDirectory = 'lib/ContractInterface/PriceFeed.abi.json';
  final String contractABI = await rootBundle.loadString(abiDirectory);

  final DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(contractABI, "PriceFeed"),
    EthereumAddress.fromHex(dotenv.env['PRICEFEED_CONTRACT_ADDRESS']!),
  );

  return contract;
}

Future<DeployedContract> deployedVotingContract(String contractAddress) async {
  const abiPath = 'lib/ContractInterface/IProjectVoting.json';
  final abi = await rootBundle.loadString(abiPath);

  final contract = DeployedContract(
    ContractAbi.fromJson(abi, "IProjectVoting"),
    EthereumAddress.fromHex(contractAddress),
  );
  return contract;
}
Future<DeployedContract> getVotingManagerContract(String votingManagerAddress) async {
  final abi = await rootBundle.loadString('lib/ContractInterface/ProjectVotingManager.json');

  return DeployedContract(
    ContractAbi.fromJson(abi, "ProjectVotingManager"),
    EthereumAddress.fromHex(votingManagerAddress),
  );
}


// Future<DeployedContract> deployedVotingManagerContract() async {
//   const abiPath = 'lib/ContractInterface/ProjectVotingManager.json';
//   final abi = await rootBundle.loadString(abiPath);

//   final contract = DeployedContract(
//     ContractAbi.fromJson(abi, "ProjectVotingManager"),
//     EthereumAddress.fromHex(dotenv.env['VOTING_MANAGER_ADDRESS']!),
//   );
//   return contract;
// }




