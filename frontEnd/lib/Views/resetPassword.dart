import 'package:flutter/material.dart';
import 'package:coach_link/Model/PasswordReset.dart';

class ResetPwdPage extends StatefulWidget {
  const ResetPwdPage({Key? key}) : super(key: key);

  @override
  _ResetPwdPageState createState() => _ResetPwdPageState();
}

class _ResetPwdPageState extends State<ResetPwdPage> {
  String _email = "";

  void _resetPwdAction() {
    PasswordReset.resetPassword(_email).then((value) {
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Reset Link has been sent to your email"),
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Reset password failed"),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText:
                        'Please Enter Email Associated With Your Account',
                    hintText: 'Enter valid email id as abc@gmail.com'),
                //controller: userNameController,
                onChanged: (email) {
                  this._email = email;
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  _resetPwdAction();
                },
                child: const Text(
                  'Reset Password Via Email',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}
