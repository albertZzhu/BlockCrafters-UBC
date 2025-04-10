import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';

class IpfsService {
  static final String _jwt = '';
  
  static Future<String?> uploadToPinata({
    required String name,
    required String description,
    required PlatformFile file,
  }) async {
    print('Starting upload to Pinata...');

    final uri = Uri.parse("https://api.pinata.cloud/pinning/pinFileToIPFS");

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = _jwt;

    final fileBytes = file.bytes ??
        await File(file.path!).readAsBytes();

    final contentType = MediaType('application', 'octet-stream');
    if (fileBytes == null) {
      print('Failed to read file bytes');
      return null;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
        contentType: contentType,
      ),
    );

    request.fields['pinataMetadata'] = jsonEncode({
      'name': name,
      'keyvalues': {'description': description},
    });

    try {
      final response = await request.send();
      print('Request sent. Awaiting response...');

      final body = await response.stream.bytesToString();
      print('Response received! Status: ${response.statusCode}');
      print('Body: $body');

      if (response.statusCode == 200) {
        final cid = jsonDecode(body)['IpfsHash'];
        print('✅ Success! CID: $cid');
        return cid;
      } else {
        print('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }
}
