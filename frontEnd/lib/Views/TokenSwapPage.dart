import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class TokenSwapPage extends StatefulWidget {
  const TokenSwapPage({Key? key}) : super(key: key);

  @override
  _TokenSwapPage createState() => _TokenSwapPage();
}

class _TokenSwapPage extends State<TokenSwapPage> {
  int _inAmount = 0;
  int _outAmount = 0;
  bool _success = false;
  int _selectedToken = 0;
  final List<String> _tokenList = ["ETH", "USDT", "USDC", "DAI", "WBTC"];

  void swapAction() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: AppBar().preferredSize.height),
              child: Icon(
                Icons.swap_vert_outlined,
                size: 30,
                color: Colors.grey,
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 20),
              child: const Text(
                "Swap tokens to CFD",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: "arial",
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                children: [
                  DropdownButton<int>(
                    alignment: AlignmentDirectional.centerEnd,
                    value: _selectedToken,
                    items:
                        _tokenList.asMap().entries.map((entry) {
                          int index = entry.key;
                          String token = entry.value;
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(token),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedToken = newValue!;
                      });
                    },
                    underline: Container(), // Remove default underline
                  ),
                  Expanded(
                    child: TextField(
                      maxLines: 1,
                      onChanged: (value) {
                        try {
                          _inAmount = int.parse(value);
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Invalid input");
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                children: [
                  SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      maxLines: 1,
                      onChanged: (value) {
                        try {
                          _outAmount = int.parse(value);
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Invalid input");
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Text("CFD", style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 5),
                ],
              ),
            ),
            Container(
              child: FloatingActionButton.extended(
                heroTag: 'swap',
                backgroundColor: Colors.lightBlue,
                onPressed: () {
                  swapAction();
                },
                label: const Text(
                  "Swap",
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
