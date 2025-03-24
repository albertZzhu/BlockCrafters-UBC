import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';

class IpfsService {
  static final String _jwt =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJkYmZhNWY4NC1iYjI5LTRmY2MtOTM5OS01ZTcyN2JhM2E3YTQiLCJlbWFpbCI6InpoYW5neGl5dTEwMEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGluX3BvbGljeSI6eyJyZWdpb25zIjpbeyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJGUkExIn0seyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJOWUMxIn1dLCJ2ZXJzaW9uIjoxfSwibWZhX2VuYWJsZWQiOmZhbHNlLCJzdGF0dXMiOiJBQ1RJVkUifSwiYXV0aGVudGljYXRpb25UeXBlIjoic2NvcGVkS2V5Iiwic2NvcGVkS2V5S2V5IjoiNDUyNTQxYTM2MzkwOTZjZGZkMjkiLCJzY29wZWRLZXlTZWNyZXQiOiIxZDM5NjhhMTk4YTM1MGZjOWM0ZTUwZDYyMjZmOWYzMTUxZjlmNTg1ZmE0NTgyMGZkMDYwOWE3NDAwZTM3MzJjIiwiZXhwIjoxNzc0MTU3NzA2fQ.kw0k4mSSmpDeMFJfPieY_rWRBnFb_Q39g56DhY-XUF4';

  static Future<String?> uploadToPinata({
    required String name,
    required String description,
    required PlatformFile file,
  }) async {
    print('🟡 Starting upload to Pinata...');

    final uri = Uri.parse("https://api.pinata.cloud/pinning/pinFileToIPFS");

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = _jwt;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
        contentType: MediaType(
          'image',
          'jpeg',
        ), // or detect from file extension
      ),
    );

    request.fields['pinataMetadata'] = jsonEncode({
      'name': name,
      'keyvalues': {'description': description},
    });

    try {
      final response = await request.send();
      print('📤 Request sent. Awaiting response...');

      final body = await response.stream.bytesToString();
      print('📥 Response received! Status: ${response.statusCode}');
      print('📄 Body: $body');

      if (response.statusCode == 200) {
        final cid = jsonDecode(body)['IpfsHash'];
        print('✅ Success! CID: $cid');
        return cid;
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      return null;
    }
  }
}
