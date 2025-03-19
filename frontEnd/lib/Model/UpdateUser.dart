import 'package:cloud_firestore/cloud_firestore.dart';
import 'User.dart';
import 'package:coach_link/Control/CoachesDBHelperFunctions_sqlite.dart';

class UpdateUser {
  final String uid;

  UpdateUser({required this.uid});

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Future newProfile(String firstName, String lastName, String email,
      {String location = "Ohio, Columbus",
      String phoneNum = "",
      int degree = 0,
      String degree_HighSchool = "",
      String degree_College = "",
      bool workType = true,
      String specialization = ""}) async {
    await CoachesDBHelperFunctions.instance.insertUser(CoachUser(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        location: location,
        phoneNum: phoneNum,
        degree: degree,
        workType: workType,
        specialization: specialization));
    return await _userCollection.doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'specialization': specialization,
      'location': location,
      'phoneNum': phoneNum,
      'degree': degree,
      'degree_HighSchool': degree_HighSchool,
      'degree_College': degree_College,
      'workType': workType,
      'friends': [],
    });
  }

  Future updateProfile(
      String firstName, String lastName, String email, String specialization,
      {String location = "Ohio, Columbus",
      String phoneNum = "",
      int degree = 0,
      bool workType = true}) async {
    await CoachesDBHelperFunctions.instance.updateUser(CoachUser(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        location: location,
        phoneNum: phoneNum,
        degree: degree,
        workType: workType,
        specialization: specialization));
    return await _userCollection.doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'specialization': specialization,
      'location': location,
      'phoneNum': phoneNum,
      'degree': degree,
      'workType': workType,
    });
  }

  Future<CoachUser> getCoach({String uid = ""}) async {
    if (uid == "") {
      uid = this.uid;
    }
    return _userCollection.doc(uid).get().then((snapshot) {
      return CoachUser(
        uid: uid,
        firstName: (snapshot.data() as dynamic)['firstName'],
        lastName: (snapshot.data() as dynamic)['lastName'],
        email: (snapshot.data() as dynamic)['email'],
        specialization: (snapshot.data() as dynamic)['specialization'],
        location: (snapshot.data() as dynamic)['location'],
        phoneNum: (snapshot.data() as dynamic)['phoneNum'],
        degree: (snapshot.data() as dynamic)['degree'],
        degree_HighSchool: (snapshot.data() as dynamic)['degree_HighSchool'],
        degree_College: (snapshot.data() as dynamic)['degree_College'],
        workType: (snapshot.data() as dynamic)['workType'],
        WorkExp: (snapshot.data() as dynamic)['WorkExp'],
        sport: (snapshot.data() as dynamic)['sport'],
        AwrdNAchv: (snapshot.data() as dynamic)['AwrdNAchv'],
      );
    });
  }

  Future<List<String>> getFriends() async {
    return _userCollection.doc(uid).get().then((snapshot) {
      List<String> friends = [];
      (snapshot.data() as dynamic)['friends'].forEach((friend) {
        friends.add(friend);
      });
      return friends;
    });
  }

  void addFriend(String friendUid) async {
    if (await isFriend(friendUid)) {
      return;
    }
    return _userCollection.doc(uid).update({
      'friends': FieldValue.arrayUnion([friendUid]),
    });
  }

  void removeFriend(String friendUid) async {
    if (!await isFriend(friendUid)) {
      return;
    }
    return _userCollection.doc(uid).update({
      'friends': FieldValue.arrayRemove([friendUid]),
    });
  }

  Future<bool> isFriend(String friendUid) {
    return _userCollection.doc(uid).get().then((snapshot) {
      return (snapshot.data() as dynamic)['friends'].contains(friendUid);
    });
  }
}
