import 'package:fluttertoast/fluttertoast.dart';

import 'StartPage.dart';
import 'package:flutter/material.dart';
import 'package:coach_link/Control/EthernetControl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _passphrase = "";
  bool _success = false;
  final Ethernetcontrol _ethernetControl = Ethernetcontrol();

  Future<void> redirect() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StartPage(isLogin: true)),
      (route) => route == null,
    );
  }

  void loginAction() async {
    try {
      if (_passphrase.isNotEmpty) {
        final address = _ethernetControl.getKeysFromMnemonic(_passphrase);
        final balance = await _ethernetControl.getBalance(address);
        setState(() {
          _success = false;
        });
      } else {
        setState(() {
          _success = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      setState(() {
        _success = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          style: const ButtonStyle(elevation: MaterialStatePropertyAll(10)),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Icon(Icons.copy_outlined, size: 30, color: Colors.grey),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 20),
              child: const Text(
                "Enter your recovery phrase",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: "arial",
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: TextField(
                maxLines: 5,
                onChanged: (value) {
                  _passphrase = value;
                },
                decoration: InputDecoration(
                  hintText: "Recovery Phrase",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            Container(
              child: FloatingActionButton.extended(
                heroTag: 'passphrase',
                backgroundColor: Colors.lightBlue,
                onPressed: () {
                  loginAction();
                },
                label: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: "arial",
                    color: Colors.black54,
                  ),
                ),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
