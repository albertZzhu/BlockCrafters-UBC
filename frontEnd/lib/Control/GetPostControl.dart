import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_link/Model/Post.dart';
import 'package:coach_link/Model/User.dart';
import 'package:coach_link/Model/UpdateUser.dart';
import 'package:coach_link/Control/CoachesDBHelperFunctions_sqlite.dart';

class GetPost {
  //final String uid;
  final CollectionReference _postCollection = FirebaseFirestore.instance
      .collection('posts');

  GetPost();

  Future<List<Post>> getPosts() async {
    //QuerySnapshot querySnapshot = await _postCollection.get();
    List<Post> posts = [];
    /*CoachUser? user = await UpdateUser(uid: uid).getCoach();
    List<CoachUser> coaches =
        await CoachesDBHelperFunctions.instance.findSimilarUser(user);
    for (CoachUser coach in coaches) {
      querySnapshot.docs.forEach((doc) {
        if (coach.uid == (doc.data() as dynamic)['uid'] &&
            ifNotInclude(posts, doc.id)) {
          // CoachUser? temp =
          //     await UpdateUser(uid: (doc.data() as dynamic)['uid']).getCoach();
          Post post = Post(
            id: doc.id,
            title: (doc.data() as dynamic)['title'],
            body: (doc.data() as dynamic)['content'],
            uid: (doc.data() as dynamic)['uid'],
            userName: (doc.data() as dynamic)['userName'],
          );
          posts.add(post);
        }
      });
    }*/
    return posts;
  }

  static bool ifNotInclude(List<Post> posts, String postId) {
    for (Post p in posts) {
      if (p.id == postId) {
        return false;
      }
    }
    return true;
  }
}
