import 'package:coach_link/Control/WalletConnectControl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TokenSwapPage extends StatefulWidget {
  const TokenSwapPage({Key? key}) : super(key: key);

  @override
  _TokenSwapPage createState() => _TokenSwapPage();
}

class _TokenSwapPage extends State<TokenSwapPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  int _selectedToken = 0;
  List<String> priceList = [];
  double singleAmount = 1;
  final List<String> _tokenList = ["ETH", "BTC"];
  final TextEditingController _inAmountController = TextEditingController();
  final TextEditingController _outAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<WalletConnectControl>().fetchTokenPrices(singleAmount);
  }

  Future<void> _initializeSwap() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    await swapAction(context);

    setState(() {
      _isLoading = false; // Set loading to false when done
    });
  }

  swapAction(BuildContext context) async {
    priceList = await context.read<WalletConnectControl>().getTokenPriceInUSD(
      singleAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletConnectControl, Web3State>(
      builder: (context, state) {
        if (state is FetchTokenPriceInUSDSuccess) {
          priceList = state.priceList;
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
                      "Swap USD to tokens",
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
                            controller: _inAmountController,
                            maxLines: 1,
                            onChanged: (value) {
                              try {
                                setState(() {
                                  _outAmountController.text = (double.parse(
                                            value,
                                          ) *
                                          double.parse(
                                            priceList[_selectedToken],
                                          ))
                                      .toStringAsFixed(2);
                                });
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
                            controller: _outAmountController,
                            maxLines: 1,
                            onChanged: (value) {
                              try {
                                setState(() {
                                  _inAmountController.text = (double.parse(
                                            value,
                                          ) /
                                          double.parse(
                                            priceList[_selectedToken],
                                          ))
                                      .toStringAsFixed(2);
                                });
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
                        Text("USD", style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 5),
                      ],
                    ),
                  ),
                  Container(
                    child: FloatingActionButton.extended(
                      heroTag: 'swap',
                      backgroundColor: Colors.lightBlue,
                      onPressed: () {},
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
        } else {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
