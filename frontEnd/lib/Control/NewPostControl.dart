import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_link/Model/Post.dart';
import 'package:coach_link/Model/User.dart';
import 'package:uuid/uuid.dart';
import 'package:coach_link/Model/UpdateUser.dart';

class NewPostControl {
  String? uid;
  CoachUser? user;
  var uuid = Uuid();

  NewPostControl(String uid) {
    this.uid = uid;
  }

  final CollectionReference _postCollection =
      FirebaseFirestore.instance.collection('posts');

  Future newPost(String title, String content) async {
    user = await UpdateUser(uid: uid!).getCoach();
    return await _postCollection.doc(uuid.v1()).set({
      'uid': uid,
      'title': title,
      'content': content,
      'userName': user!.firstName + " " + user!.lastName,
    });
  }
}
