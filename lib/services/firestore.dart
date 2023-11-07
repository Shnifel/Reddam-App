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
  static CollectionReference hoursCollection =
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

      String? userName = await getUserData();
      String body = "$userName has completed $amount hours of $activity";

      // Send a notification to the admin of this upload
      NotificationServices.sendNotification(uid, "New hours logged", body,
          id: docRef.id, notificationType: "HOURS");
    } catch (e) {
      print(e);
    }
  }

  // Uploading image utility
  Future<String?> uploadFile(File? photo) async {
    if (photo == null) return null; // Verify non-null File provided
    final fileName = basename(photo.path); // Extract uploaded file name
    final destination = 'files/$fileName'; // Set destination path
    final ref = FirebaseStorage.instance
        .ref(destination)
        .child('file/'); // Create reference to firebase storage
    await ref.putFile(photo); // Upload file
    return await ref.getDownloadURL(); // Obtain download url
  }

  Future<Map<String, Object?>> aggregateHours(
      {Map<String, Object?> filters = const {}}) async {
    Query<Object?> query = hoursCollection;
    query.where('uid', isEqualTo: uid);

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
    query.where('uid', isEqualTo: uid);

    filters.forEach((key, value) => query = query.where(key, isEqualTo: value));

    query = query.limit(10);

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

  static Future<void> addEvent(
      String description, Timestamp date, bool recurring, int frequency

      ) async { try{
        Map<String,dynamic> data={"description":description,"date":date,"recurring":recurring,"frequency":frequency};
        await eventsCollection.add(data);
      } catch(e){
        print(e);
        }
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


  static Future<void> deleteEvent(Timestamp date) async {try {
    DateTime dateOnly=date.toDate();
    QuerySnapshot querySnapshot = await eventsCollection
        .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      await eventsCollection.doc(doc.id).delete();
    } else {
      print('No events found with the specified date.');
      print("the date " +dateOnly.toString());
    }
  }catch(e){
    print(e);
  }
  }

}
