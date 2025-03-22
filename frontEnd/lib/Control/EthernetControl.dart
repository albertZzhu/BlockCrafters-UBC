import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:bip39_mnemonic/bip39_mnemonic.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:coach_link/Model/LocalStorage.dart';
//import 'package:ethereum/ethereum.dart' as ethereum;
//import 'package:ethereum/ethereum_server_client.dart';

class Ethernetcontrol extends ChangeNotifier {
  final Web3Client _client = Web3Client(
    'https://mainnet.infura.io/v3/e8b3da9156fd4b4f8f8cdac7e085e1e0',
    Client(),
  );

  Future<BigInt> getBalance(EthereumAddress _address) async {
    try {
      final balance = await _client.getBalance(_address);
      return balance.getInEther;
    } catch (e) {
      throw Exception("Failed to get balance: $e");
    }
  }

  EthereumAddress getKeysFromMnemonic(String phrase) {
    try {
      String result = hex.encode(
        bip39.Mnemonic.fromWords(words: phrase.split(" ")).seed,
      );
      // Use the mnemonic to derive the private key
      final credentials = EthPrivateKey.fromHex(result);
      EthereumAddress _address = credentials.address;
      Storage storage = Storage();
      storage.save("address", _address.toString());
      storage.save("privateKey", result);
      return _address;
    } catch (e) {
      throw Exception("Invalid mnemonic phrase");
    }
  }

  EthereumAddress getKeypairFromPriv(EthPrivateKey privKey) {
    try {
      EthereumAddress _address = privKey.address;
      Storage storage = Storage();
      storage.save("address", _address.toString());
      storage.save("privateKey", privKey.privateKey.toString());
      return _address;
    } catch (e) {
      throw Exception("Invalid private key");
    }
  }
}
