import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:coach_link/Control/WalletConnectControl.dart';

import 'ipfs_service.dart';

class ProjectSubmissionResult {
  final String statusMessage;
  final String? txHash;

  ProjectSubmissionResult({required this.statusMessage, this.txHash});
}

class ProjectSubmissionService {
  static Future<PlatformFile> createDescriptionTxtFile(
    String name,
    String descriptionText,
  ) async {
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
    required String socialMedia,
    required int deadline,
    required String tokenName,
    required PlatformFile imageFile,
    required PlatformFile detailFile,
    required PlatformFile symbolFile,
  }) async {
    final statusMessages = <String>[];
    String? imageCid, detailCid, socialMediaCid, tokenSymbolCid;

    statusMessages.add('Starting file uploads to IPFS...');

    // Upload image
    try {
      imageCid = await IpfsService.uploadToPinata(
        name: name,
        description: 'Project image',
        file: imageFile,
      );
      statusMessages.add(imageCid != null
          ? 'Image uploaded. CID: $imageCid'
          : 'Image upload failed (null CID).');
    } catch (e) {
      statusMessages.add('Image upload error: $e');
    }

    // Upload token symbol
    try {
      tokenSymbolCid = await IpfsService.uploadToPinata(
        name: name,
        description: 'Token Symbol',
        file: symbolFile,
      );

      statusMessages.add(tokenSymbolCid != null
          ? 'Token Symbol uploaded. CID: $tokenSymbolCid'
          : 'Token Symbol upload failed (null CID).');

    } catch (e) {
      statusMessages.add('Token Symbol upload error: $e');
    }

    // Upload detail file
    try {
      detailCid = await IpfsService.uploadToPinata(
        name: name,
        description: 'Project detail file',
        file: detailFile,
      );
      statusMessages.add(detailCid != null
          ? 'Detail file uploaded. CID: $detailCid'
          : 'Detail file upload failed (null CID).');
    } catch (e) {
      statusMessages.add('Detail file upload error: $e');
    }

    // Upload social media link as a text file
    try {
      final socialMediaFile = await createDescriptionTxtFile(name, socialMedia);
      socialMediaCid = await IpfsService.uploadToPinata(
        name: name,
        description: 'Project social media link text',
        file: socialMediaFile,
      );
      statusMessages.add(socialMediaCid != null
          ? 'Social Media Link File uploaded. CID: $socialMediaCid'
          : 'Social Media Link File failed (null CID).');
    } catch (e) {
      statusMessages.add('Social Media Link File upload error: $e');
    }

    // If any failed, stop here
    if ([
      imageCid,
      detailCid,
      socialMediaCid,
      tokenSymbolCid,
    ].any((cid) => cid == null)) {
      statusMessages.add('Stopped: Not all files uploaded successfully.');
      return ProjectSubmissionResult(statusMessage: statusMessages.join('\n'));
    }

    // Submit to contract
    statusMessages.add('\n Submitting project to contract...');

    // originally, submit to contract here
    // moved to propose_project_screen.dart

    return ProjectSubmissionResult(statusMessage: statusMessages.join('\n'));
  }

  static Future<String> submitMilestoneDescription({
    required String name,
    required PlatformFile description,
  }) async {
    String descriptionCid = "";

    // Upload description file
    try {
      descriptionCid =
          (await IpfsService.uploadToPinata(
            name: name,
            description: 'Milestone description',
            file: description,
          )) ??
          '';
    } catch (e) {
      descriptionCid = "Error uploading description: $e";
    }
    return descriptionCid;
  }
}
