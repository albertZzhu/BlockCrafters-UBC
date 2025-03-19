import 'dart:async';
import 'package:coach_link/Model/User.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoachesDBHelperFunctions {
  static final _databaseName = "CoachUsers.db";
  static final _databaseVersion = 1;
  static final table = 'USERS';
  static final firstName = 'firstName';
  static final lastName = 'lastName';
  static final email = 'email';
  static final specialization = 'specialization';
  static final location = 'location';
  static final phoneNum = 'phoneNum';
  static final degree = 'degree';
  static final workType = 'workType';

  // make this a singleton class
  CoachesDBHelperFunctions._privateConstructor();
  static final CoachesDBHelperFunctions instance =
      CoachesDBHelperFunctions._privateConstructor();

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    String path = join(await getDatabasesPath(), _databaseName);
    Database temp = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
    //await sync();
    return temp;
  }

  Future<void> sync() async {
    final db = await database;
    db.rawDelete("DELETE FROM $table");
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    querySnapshot.docs.forEach((doc) {
      insertUser(CoachUser(
        uid: doc.id,
        firstName: (doc.data() as dynamic)['firstName'],
        lastName: (doc.data() as dynamic)['lastName'],
        email: (doc.data() as dynamic)['email'],
        specialization: (doc.data() as dynamic)['specialization'],
        location: (doc.data() as dynamic)['location'],
        phoneNum: (doc.data() as dynamic)['phoneNum'],
        degree: (doc.data() as dynamic)['degree'],
        workType: (doc.data() as dynamic)['workType'],
      ));
    });
  }

  Future _onCreate(Database db, int version) async {
    // Run the CREATE TABLE statement on the database.
    await db.execute(
      "CREATE TABLE USERS ("
      "UserID TEXT NOT NULL, "
      "FirstName TEXT NOT NULL, "
      "LastName TEXT NOT NULL, "
      "EmailAddress TEXT NOT NULL, "
      "PhoneNumber TEXT, "
      "Location TEXT, "
      "Achievements TEXT, "
      "Degree INTEGER NOT NULL, "
      "WorkType BLOB DEFAULT 0, "
      "Field TEXT NOT NULL, "
      "Specialty TEXT, "
      "PRIMARY KEY(UserID))",
    );
  }

// Define a function that inserts user into the database
  Future<void> insertUser(CoachUser user) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the user into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same user is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CoachUser>> search(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM users WHERE '
      'FirstName LIKE \'%$keyword%\' OR '
      'LastName LIKE \'%$keyword%\' OR '
      'EmailAddress LIKE \'%$keyword%\' OR '
      'Field LIKE \'%$keyword%\' OR '
      'Location LIKE \'%$keyword%\' OR '
      'PhoneNumber LIKE \'%$keyword%\' OR '
      'Specialty LIKE \'%$keyword%\'',
    );
    return List.generate(maps.length, (i) {
      return CoachUser(
        uid: maps[i]['UserID'],
        email: maps[i]['EmailAddress'],
        firstName: maps[i]['FirstName'],
        lastName: maps[i]['LastName'],
        specialization: maps[i]['Field'],
        location: maps[i]['Location'],
        phoneNum: maps[i]['PhoneNumber'],
        degree: maps[i]['Degree'],
        workType: maps[i]['WorkType'] == 1 ? true : false,
      );
    });
  }

  Future<CoachUser?> getUser(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'UserID = ?',
      whereArgs: [uid],
    );
    if (maps.length > 0) {
      return CoachUser(
        uid: maps.first['UserID'],
        email: maps.first['EmailAddress'],
        firstName: maps.first['FirstName'],
        lastName: maps.first['LastName'],
        specialization: maps.first['Field'],
        location: maps.first['Location'],
        phoneNum: maps.first['PhoneNumber'],
        degree: maps.first['Degree'],
        workType: maps.first['WorkType'] == 1 ? true : false,
      );
    }
    return null;
  }

  Future<void> updateUser(CoachUser user) async {
    // Get a reference to the database.
    final db = await database;
    // Update the given user.
    await db.update(
      'USERS',
      user.toMap(),
      // Ensure that the user has a matching id.
      where: 'UserID = ?',
      // Pass the user's id as a whereArg to prevent SQL injection.
      whereArgs: [user.uid],
    );
  }

  Future<void> deleteUser(String email) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the user from the database.
    await db.delete(
      'USERS',
      // Use a `where` clause to delete a specific user.
      where: 'email = ?',
      // Pass the user's email as a whereArg to prevent SQL injection.
      whereArgs: [email],
    );
  }

  Future<List<CoachUser>> findSimilarUser(CoachUser user) async {
    List<CoachUser> users = await search(user.specialization);
    for (CoachUser c in await search(user.location)) {
      if (!ifInclude(users, c.email)) {
        users.add(c);
      }
    }
    // users.removeWhere((CoachUser) => user.uid == CoachUser.uid);
    return users;
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
