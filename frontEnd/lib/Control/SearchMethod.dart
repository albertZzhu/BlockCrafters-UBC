import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_link/Model/User.dart';
import 'package:coach_link/Control/CoachesDBHelperFunctions_sqlite.dart';

class SearchMethod {
  static Future<List<CoachUser>> searchCoach(String keyword) async {
    await CoachesDBHelperFunctions.instance.sync();
    List<CoachUser> coachList =
        await CoachesDBHelperFunctions.instance.search(keyword);

    // QuerySnapshot querySnapshotFirstName = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('firstName', isEqualTo: keyword)
    //     .get();
    // querySnapshotFirstName.docs.forEach((doc) {
    //   coachList.add(CoachUser(
    //     uid: doc.id,
    //     firstName: (doc.data() as dynamic)['firstName'],
    //     lastName: (doc.data() as dynamic)['lastName'],
    //     email: (doc.data() as dynamic)['email'],
    //     specialization: (doc.data() as dynamic)['specialization'],
    //     location: (doc.data() as dynamic)['location'],
    //     phoneNum: (doc.data() as dynamic)['phoneNum'],
    //     degree: (doc.data() as dynamic)['degree'],
    //     workType: (doc.data() as dynamic)['workType'],
    //   ));
    // });
    // QuerySnapshot querySnapshotLastName = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('lastName', isEqualTo: keyword)
    //     .get();
    // querySnapshotLastName.docs.forEach((doc) {
    //   if (!ifInclude(coachList, (doc.data() as dynamic)['email'])) {
    //     coachList.add(CoachUser(
    //       uid: doc.id,
    //       firstName: (doc.data() as dynamic)['firstName'],
    //       lastName: (doc.data() as dynamic)['lastName'],
    //       email: (doc.data() as dynamic)['email'],
    //       specialization: (doc.data() as dynamic)['specialization'],
    //       location: (doc.data() as dynamic)['location'],
    //       phoneNum: (doc.data() as dynamic)['phoneNum'],
    //       degree: (doc.data() as dynamic)['degree'],
    //       workType: (doc.data() as dynamic)['workType'],
    //     ));
    //   }
    // });
    // QuerySnapshot querySnapshotSpec = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('specialization', isEqualTo: keyword)
    //     .get();
    // querySnapshotSpec.docs.forEach((doc) {
    //   if (!ifInclude(coachList, (doc.data() as dynamic)['email'])) {
    //     coachList.add(CoachUser(
    //       uid: doc.id,
    //       firstName: (doc.data() as dynamic)['firstName'],
    //       lastName: (doc.data() as dynamic)['lastName'],
    //       email: (doc.data() as dynamic)['email'],
    //       specialization: (doc.data() as dynamic)['specialization'],
    //       location: (doc.data() as dynamic)['location'],
    //       phoneNum: (doc.data() as dynamic)['phoneNum'],
    //       degree: (doc.data() as dynamic)['degree'],
    //       workType: (doc.data() as dynamic)['workType'],
    //     ));
    //   }
    // });
    // QuerySnapshot querySnapshotLocation = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('location', isEqualTo: keyword)
    //     .get();
    // querySnapshotLocation.docs.forEach((doc) {
    //   if (!ifInclude(coachList, (doc.data() as dynamic)['email'])) {
    //     coachList.add(CoachUser(
    //       uid: doc.id,
    //       firstName: (doc.data() as dynamic)['firstName'],
    //       lastName: (doc.data() as dynamic)['lastName'],
    //       email: (doc.data() as dynamic)['email'],
    //       specialization: (doc.data() as dynamic)['specialization'],
    //       location: (doc.data() as dynamic)['location'],
    //       phoneNum: (doc.data() as dynamic)['phoneNum'],
    //       degree: (doc.data() as dynamic)['degree'],
    //       workType: (doc.data() as dynamic)['workType'],
    //     ));
    //   }
    // });
    return coachList;
  }

  static bool ifInclude(List<CoachUser> coachList, String email) {
    for (CoachUser c in coachList) {
      if (c.email == email) {
        return true;
      }
    }
    return false;
  }
}
