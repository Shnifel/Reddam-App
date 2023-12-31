import 'dart:io';
import 'package:cce_project/services/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FirestoreService {
  final String uid; // Reference to the user id
  FirestoreService({required this.uid});

  // Reference the user collection
  final CollectionReference collection =
      FirebaseFirestore.instance.collection("Users");

  // Reference to hours log colletion
  final CollectionReference hoursCollection =
      FirebaseFirestore.instance.collection("Logs");

  static CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection("Events");

  /// Provide a map of data and create a new user with the given uid and data
  ///
  /// [data] All user related data
  Future setUserData(Map<String, Object?> data) async {
    return await collection.doc(uid).set(data);
  }

  /// Obtain a user's data based on a provided id
  ///
  /// [id] - User's firebase id
  Future<Map<String, dynamic>> getData(String? id) async {
    final snapshot = await collection.doc(id).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  // Get user's name
  Future<String?> getUserData() async {
    try {
      final snapshot = await collection.doc(uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      String name = data["firstName"] + ' ' + data["lastName"];
      return name;
    } catch (e) {
      return 'Error fetching user';
    }
  }

  /// Log hours for a user. Creates a new document in the 'Logs' collection
  ///
  /// [uid] - User id of person whose receiving hours
  /// [hoursType] - Active or passive hours
  /// [activity] - If active will be Collection or Time, if passive will be specific activity
  /// [amount] - Hours/ Amount of community service
  /// [receiptNo] - Receipt number that should match that of uploaded image
  /// [evidenceUrls] - A list of url's to photos for evidence
  /// [activeType] - If active the specific activity
  /// [optionalUrls] - A list of url's to other photos for gallery
  Future<void> logHours(String uid, String? hoursType, String? activity,
      double amount, String? receiptNo, List<String> evidenceUrls,
      {String? activeType, List<String> optionalUrls = const []}) async {
    // Arguments supplied to firestore collection
    Map<String, Object?> args = {
      'uid': uid, // User id
      'hours_type': hoursType, // Active or Passive
      'activity': activity, // Specific Active or Passive Activity
      'active_type': activeType, // Activity for active
      'amount': amount, // Number of Hours
      'receipt_no': receiptNo, // Receipt No
      'evidenceUrls':
          evidenceUrls, // List of urls where uploaded photos for evidence are stored
      'optionalUrls':
          optionalUrls, // List of urls for any other additional photos
      'validated': false, // Set validated state to be false
      'date': Timestamp.fromDate(DateTime.now())
    };

    try {
      // Log the corresponding hours claim to firestore
      DocumentReference docRef = await hoursCollection.add(args);
    } catch (e) {
      print(e);
    }
  }

  // Uploading image utility
  Future<String?> uploadFile(File? photo, {bool isGallery = false}) async {
    if (photo == null) return null; // Verify non-null File provided
    final fileName = basename(photo.path); // Extract uploaded file name
    final destination = isGallery
        ? 'gallery/$fileName'
        : 'evidence/$fileName'; // Set destination path
    final ref = FirebaseStorage.instance
        .ref(destination); // Create reference to firebase storage
    await ref.putFile(photo); // Upload file
    return await ref.getDownloadURL(); // Obtain download url
  }

  Future<Map<String, Object?>> aggregateHours(
      {Map<String, Object?> filters = const {}}) async {
    Query<Object?> query = hoursCollection;
    query = query.where('uid', isEqualTo: uid);
    query = query.where('accepted', isEqualTo: true);

    filters.forEach((key, value) => query = query.where(key, isEqualTo: value));

    QuerySnapshot querySnapshot = await query.get();

    Map<String, double> hours = {'Active': 0, 'Passive': 0};

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      hours[data['hours_type']] = hours[data['hours_type']]! + data['amount'];
    });

    return hours;
  }

  Future<List<Map<String, dynamic>>> getStudentLogs(
      {Map<String, Object?> filters = const {}}) async {
    Query query = hoursCollection;
    query = query.where('uid', isEqualTo: uid);

    filters.forEach((key, value) => query = query.where(key, isEqualTo: value));

    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> logs = [];

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      logs.add(data);
    });

    logs.sort((a, b) {
      DateTime d1 = (a['date'] as Timestamp).toDate();
      DateTime d2 = (b['date'] as Timestamp).toDate();

      return d2.compareTo(d1);
    });

    return logs;
  }

  Future<List> getAllLogs() async {
    var db = FirebaseFirestore.instance;

    DateTime now = DateTime.now(); // The current date
    DateTime start = DateTime(
        now.year, 1, 1); // Start date is the 1st of Jan of the current year
    DateTime end = DateTime(
        now.year, 12, 31); // End date is the 31st of Dec of the current year

    Map<String, double> hours = {
      'Active': 0,
      'Passive': 0
    }; // This will store the total hours for the year

    List allData = [];

    await db
        .collection("Logs")
        // Only consider dates in the current year
        .where("date", isGreaterThanOrEqualTo: start)
        .where("date", isLessThanOrEqualTo: end)
        .get()
        .then(
      (querySnapshot) async {
        QuerySnapshot users = await getUserInfo();
        for (var docSnapshot in querySnapshot.docs) {
          Map<String, dynamic> data = docSnapshot.data();
          // Get the user with the specified uid
          Map<String, dynamic>? user = users.docs
              .firstWhere((element) => element.id == data["uid"])
              .data() as Map<String, dynamic>?;
          // Add the grade, class, and house to each log
          data["grade"] = user!["grade"];
          data["class"] = user["class"];
          data["house"] = user["house"];
          data["house"] = user["house"];
          data["firstName"] = user["firstName"];
          data["lastName"] = user["lastName"];
          allData.add(data);
          // hours[data['hours_type']] =
          //     hours[data['hours_type']]! + data['amount'];
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    return allData;
  }

  Future<QuerySnapshot> getUserInfo() async {
    var db = FirebaseFirestore.instance;

    QuerySnapshot userData = await db.collection("Users").get();

    return userData;
  }

  static Future<List<Map<String, dynamic>>> getEvents() async {
    QuerySnapshot querySnapshot = await eventsCollection.get();

    List<Map<String, dynamic>> logs = [];
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      logs.add(data);
    });
    return logs;
  }

  static Future<List<String>> getGalleryImages() async {
    List<String> downloadUrls = [];

    Reference reference = FirebaseStorage.instance.ref('gallery/');

    try {
      ListResult result = await reference.listAll();

      for (Reference item in result.items) {
        String downloadUrl = await item.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    } catch (e) {
      print("Error fetching download URLs: $e");
    }

    return downloadUrls;
  }
}
