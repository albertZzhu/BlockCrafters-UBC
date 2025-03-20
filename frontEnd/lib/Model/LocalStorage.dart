import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static final Storage _instance = Storage._internal();
  final storage = FlutterSecureStorage();
  factory Storage() {
    return _instance;
  }
  Storage._internal();
  Future<void> save(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  Future<void> clear() async {
    await storage.deleteAll();
  }
}
