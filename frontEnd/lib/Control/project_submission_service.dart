import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import 'ipfs_service.dart';

class ProjectSubmissionResult {
  final String statusMessage;
  final String? txHash;

  ProjectSubmissionResult({required this.statusMessage, this.txHash});
}

class ProjectSubmissionService {
  static Future<PlatformFile> createDescriptionTxtFile(String name, String descriptionText) async {
    final bytes = utf8.encode(descriptionText);
    return PlatformFile(
      name: '${name}_description.txt',
      size: bytes.length,
      bytes: Uint8List.fromList(bytes),
      path: null,
    );
  }

  static Future<ProjectSubmissionResult> submit({
    required String name,
    required String goal,
    required String deadline,
    required String descriptionText,
    required PlatformFile imageFile,
    required PlatformFile detailFile,
  }) async {
    final statusMessages = <String>[];
    String? imageCid, detailCid, descriptionCid;

    statusMessages.add('📤 Starting file uploads to IPFS...');

    // Upload image
    try {
      imageCid = await IpfsService.uploadToPinata(
        name: name,
        description: 'Project image',
        file: imageFile,
      );
      statusMessages.add(imageCid != null
          ? '✅ Image uploaded. CID: $imageCid'
          : '❌ Image upload failed (null CID).');
    } catch (e) {
      statusMessages.add('❌ Image upload error: $e');
    }

    // Upload detail file
    try {
      detailCid = await IpfsService.uploadToPinata(
        name: name,
        description: 'Project detail file',
        file: detailFile,
      );
      statusMessages.add(detailCid != null
          ? '✅ Detail file uploaded. CID: $detailCid'
          : '❌ Detail file upload failed (null CID).');
    } catch (e) {
      statusMessages.add('❌ Detail file upload error: $e');
    }

    // Upload description text
    try {
      final descriptionFile = await createDescriptionTxtFile(name, descriptionText);
      descriptionCid = await IpfsService.uploadToPinata(
        name: name,
        description: 'Project description text',
        file: descriptionFile,
      );
      statusMessages.add(descriptionCid != null
          ? '✅ Description uploaded. CID: $descriptionCid'
          : '❌ Description upload failed (null CID).');
    } catch (e) {
      statusMessages.add('❌ Description upload error: $e');
    }

    // If any failed, stop here
    if ([imageCid, detailCid, descriptionCid].any((cid) => cid == null)) {
      statusMessages.add('⚠️ Stopped: Not all files uploaded successfully.');
      return ProjectSubmissionResult(statusMessage: statusMessages.join('\n'));
    }

    // Submit to contract
    statusMessages.add('\n🚀 Submitting project to contract...');
    try {
      final client = Web3Client(dotenv.env['INFURA_URL']!, http.Client());
      final credentials = EthPrivateKey.fromHex(dotenv.env['PRIVATE_KEY']!);
      final abi = await rootBundle.loadString(dotenv.env['ABI_PATH']!);
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'ProjectManager'),
        EthereumAddress.fromHex(dotenv.env['CONTRACT_ADDRESS']!),
      );

      final function = contract.function('createProject');

      final goalValue = BigInt.parse(goal);
      final deadlineTimestamp = BigInt.from(
        DateTime.parse(deadline).millisecondsSinceEpoch ~/ 1000,
      );

      final txHash = await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [
            name,
            goalValue,
            deadlineTimestamp,
            descriptionCid!,
            imageCid!,
            detailCid!,
          ],
        ),
        chainId: 31337, // or 11155111 for Sepolia
      );

      statusMessages.add('✅ Project submitted!\n🔗 Tx Hash: $txHash');
      return ProjectSubmissionResult(
        statusMessage: statusMessages.join('\n'),
        txHash: txHash,
      );
    } catch (e) {
      statusMessages.add('❌ Contract submission error: $e');
      return ProjectSubmissionResult(statusMessage: statusMessages.join('\n'));
    }
  }
}
