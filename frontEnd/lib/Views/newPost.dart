// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
//import 'package:coach_link/Model/UpdateUser.dart';
//import 'package:coach_link/Control/NewPostControl.dart';

class newPost extends StatefulWidget {
  newPost({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<newPost> {
  String uid = " ";
  String _title = "";
  String _content = "";
  //NewPostControl? postControl;

  _NewPostPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{})
            as Map;
    uid = arguments['uid'] ?? "";
    //postControl = NewPostControl(uid);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              onPressed: () {
                //postControl?.newPost(_title, _content);
                Navigator.pop(context);
              },
              child: const Text(
                "Post",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            width: MediaQuery.of(context).size.width - 30,
            left: 15,
            height: 40,
            child: TextField(
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              decoration: InputDecoration(
                isDense: true,
                //border: OutlineInputBorder(),
                hintText: "Title",
              ),
              onChanged: (String value) {
                _title = value;
              },
            ),
          ),
          Positioned(
            top: 120,
            width: MediaQuery.of(context).size.width - 30,
            left: 15,
            child: TextField(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: "Content",
              ),
              onChanged: (String value) {
                _content = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
