import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InvestModal extends StatefulWidget {
  final String description;
  final Function(
    String projectAddress,
    String token,
    String amount,
    String projectName,
  )
  onInvest; // Callback for the invest action
  final String projectImageUrl;
  final String projectAddress;

  const InvestModal({
    Key? key,
    required this.onInvest,
    required this.description,
    required this.projectImageUrl,
    required this.projectAddress,
  }) : super(key: key);

  @override
  _InvestModalState createState() => _InvestModalState();
}

class _InvestModalState extends State<InvestModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  int _selectedToken = 0;
  final List<String> _tokenList = ["ETH", "USDT", "BTC"];

  void _handleInvest() async {
    if (_controller.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter an amount to invest");
      return;
    }

    final double amount = double.tryParse(_controller.text) ?? 0;
    if (amount <= 0) {
      Fluttertoast.showToast(msg: "Please enter a valid amount");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Trigger the invest action
    await widget.onInvest(
      widget.projectAddress,
      _tokenList[_selectedToken],
      _controller.text,
      widget.description,
    );

    setState(() {
      _isLoading = false;
    });

    // Close the modal after the action is complete
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text("Invest in Project", style: TextStyle(fontSize: 18)),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(widget.projectImageUrl),
          ),
          Text(
            widget.description,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
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
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (double.tryParse(value) == null) {
                      Fluttertoast.showToast(msg: "Please input numeric value");
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleInvest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                      : const Text("Invest", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
