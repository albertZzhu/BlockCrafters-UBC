import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';

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
