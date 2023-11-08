import 'dart:io';
import 'package:cce_project/services/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class TeacherFirestoreService {
  // Reference the user collection
  final CollectionReference collection =
      FirebaseFirestore.instance.collection("Users");

  // Reference to hours log colletion
  final CollectionReference hoursCollection =
      FirebaseFirestore.instance.collection("Logs");

  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection("Events");

  /// Obtain a user's data based on a provided id
  ///
  /// [id] - User's firebase id
  Future<Map<String, dynamic>> getData(String? id) async {
    final snapshot = await collection.doc(id).get();
    return snapshot.data() as Map<String, dynamic>;
  }

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

  Future<Map<String, Map<String, dynamic>>> aggregateHours(
      {Map<String, Object?> filters = const {},
      List<String> users = const [],
      bool splitTimeCollection = false,
      bool formatAsString = false}) async {
    Query<Object?> query = hoursCollection;

    filters.forEach((key, value) => query = query.where(key, isEqualTo: value));
    query = query.where('uid', whereIn: users);

    QuerySnapshot querySnapshot = await query.get();

    Map<String, Map<String, dynamic>> aggregatedHours = {};

    for (var user in users) {
      Map<String, double> hours;
      if (splitTimeCollection) {
        hours = {'Active Time': 0, 'Active Collection': 0, 'Passive': 0};
      } else {
        hours = {'Active': 0, 'Passive': 0};
      }

      aggregatedHours[user] = hours;
    }

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String uid = data['uid'];
      String hours_type = data['hours_type'];
      if (hours_type == "Active" && splitTimeCollection) {
        // ignore: prefer_interpolation_to_compose_strings
        hours_type += " " + data['activity'];
      }
      aggregatedHours[uid]![hours_type] =
          aggregatedHours[uid]![hours_type]! + data['amount'];
    });

    for (var user in users) {
      if (splitTimeCollection) {
        aggregatedHours[user]!['Total'] =
            aggregatedHours[user]!['Active Time']! +
                aggregatedHours[user]!['Active Collection']! +
                aggregatedHours[user]!['Passive']!;
      } else {
        aggregatedHours[user]!['Total'] = aggregatedHours[user]!['Active']! +
            aggregatedHours[user]!['Passive']!;
      }

      if (formatAsString) {
        Map<String, dynamic> stringFormatted = {};
        for (var key in aggregatedHours[user]!.keys) {
          stringFormatted[key] =
              (aggregatedHours[user]![key] as double).toString();
        }
        aggregatedHours[user] = stringFormatted;
      }
    }

    return aggregatedHours;
  }

  // Retrieve student data based on certain filters
  Future<List<Map<String, dynamic>>> getStudents(
      {Map<String, Object?> filters = const {}}) async {
    Query query = collection;

    filters.forEach((key, value) => query = query.where(key, isEqualTo: value));

    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> logs = [];

    // Aggregate all data
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      logs.add(data);
    });

    // Sort student names in alphabetical order
    logs.sort((a, b) {
      return (a['lastName'] as String).compareTo(b['lastName']);
    });
    return logs;
  }

  // Retrieve all student logs based on some filters
  Future<List<Map<String, dynamic>>> getStudentLogs(
      {Map<String, Object?> filters = const {}}) async {
    Query query = hoursCollection;

    filters.forEach((key, value) => query = query.where(key, isEqualTo: value));

    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> logs = [];

    Map<String, Map<String, dynamic>> userData = {};

    // Ascertain that all async fetching of data is completed
    List<Future<void>> futures = [];

    // Aggregate all data
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      String uid = data['uid'];

      // Retrieve user info only once
      if (userData['uid'] == null) {
        futures.add(collection.doc(uid).get().then((snapshot) {
          userData[uid] = snapshot.data() as Map<String, dynamic>;
          data = {...data, ...userData[uid]!};
          logs.add(data);
        }));
      } else {
        data = {...data, ...userData[uid]!};
        logs.add(data);
      }
    });

    await Future.wait(futures);

    // Sort student names in order of date
    logs.sort((a, b) {
      DateTime d1 = (a['date'] as Timestamp).toDate();
      DateTime d2 = (b['date'] as Timestamp).toDate();

      return d2.compareTo(d1);
    });

    print(logs);
    return logs;
  }

  // Approve/reject hours for students
  Future<void> validateHours(String hoursID, String uid, bool accepted,
      {bool sendNotification = false, String? rejectionMessage = null}) async {
    await hoursCollection.doc(hoursID).update({
      "validated": true,
      "accepted": accepted,
      "rejection_message": rejectionMessage
    });

    if (sendNotification) {
      NotificationServices.sendNotification(
          uid, "Hours approval status updated", "",
          id: hoursID, notificationType: "HOURS");
    }
  }

  // Log hours in a batch for a list of students
  Future<void> logHoursBatch(List<Map<String, dynamic>> dataList,
      String? hoursType, String? activity, double amount,
      {String? activeType}) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var data in dataList) {
      // Generate a new document reference
      if (data['amount'] != null && data['amount'] != 0) {
        var newDocRef = hoursCollection.doc();
        data['docId'] = newDocRef;
        print(newDocRef);
        Map<String, dynamic> studentLog = {
          'uid': data['id'], // User id
          'hours_type': hoursType, // Active or Passive
          'activity': activity, // Specific Active or Passive Activity
          'active_type': activeType, // Activity for active
          'amount': data['amount'], // Number of Hours
          'receipt_no': null, // Receipt No
          'evidenceUrls':
              [], // List of urls where uploaded photos for evidence are stored
          'optionalUrls': [], // List of urls for any other additional photos
          'validated': true, // Set validated state to be false
          'date': Timestamp.fromDate(DateTime.now()),
          'accepted': true
        };

        // Set the data for the new document
        batch.set(newDocRef, studentLog);
      }

      if (data['excess'] != null && data['excess'] != 0) {
        var excessDocRef = hoursCollection.doc();
        print(excessDocRef);
        data['docId'] = excessDocRef;

        Map<String, dynamic> excessLog = {
          'uid': data['id'], // User id
          'hours_type': 'Passive', // Active or Passive
          'activity': activeType, // Specific Active or Passive Activity
          'active_type': null, // Activity for active
          'amount': data['excess'], // Number of Hours
          'receipt_no': null, // Receipt No
          'evidenceUrls':
              [], // List of urls where uploaded photos for evidence are stored
          'optionalUrls': [], // List of urls for any other additional photos
          'validated': true, // Set validated state to be false
          'date': Timestamp.fromDate(DateTime.now()),
          'accepted': true
        };

        batch.set(excessDocRef, excessLog);
      }
    }
    // Commit the batch
    await batch.commit();

    for (var user in dataList) {
      if (user['docId'] != null) {
        NotificationServices.sendNotification(
            user['id'], "New hours allocated to you", "",
            id: user['docId'], notificationType: "HOURS");
      }
    }
  }

  Future<void> addEvent(
      String description, Timestamp date, bool recurring, int dayOfWeek) async {
    try {
      Map<String, dynamic> data = {
        "description": description,
        "date": date,
        "recurring": recurring,
        "day": dayOfWeek
      };
      await eventsCollection.add(data);
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    QuerySnapshot querySnapshot = await eventsCollection.get();

    List<Map<String, dynamic>> logs = [];
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      logs.add(data);
    });
    return logs;
  }

  Future<void> deleteEvent(String eventID) async {
    try {
      await eventsCollection.doc(eventID).delete();
    } catch (e) {
      print(e);
    }
  }

  // Get all unverified teachers
  Future<List> getUnverifiedTeachers() async {
    var db = FirebaseFirestore.instance;

    List allData = [];

    await db
        .collection("Users")
        // Only consider dates in the current year
        .where("isVerified", isEqualTo: false)
        .where("checked", isEqualTo: false)
        .get()
        .then(
      (querySnapshot) async {
        for (var docSnapshot in querySnapshot.docs) {
          Map<String, dynamic> data = docSnapshot.data();
          data['id'] = docSnapshot.id;
          allData.add(data);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    return allData;
  }

  // Approve/reject verification of teacher
  Future<void> verifyTeacher(String teacherID, bool b) async {
    await collection.doc(teacherID).update({
      "isVerified": b,
      "checked": true,
    });
  }
}
