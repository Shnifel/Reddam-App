import 'dart:io';
import 'package:cce_project/services/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  // Update the user's details
  Future setUserData(Map<String, Object?> data) async {
    return await collection.doc(uid).set(data);
  }

  // Extract data based on a document id
  Future<Map<String, dynamic>> getData(String? id) async {
    final snapshot = await collection.doc(id).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  // Get the user name
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

  // Log user's hours claim
  Future<void> logHours(String uid, String? hoursType, String? activity,
      double amount, String? receiptNo, List<String> evidenceUrls,
      {String? activeType, List<String> optionalUrls = const []}) async {
    // Arguments supplied to firestore collection
    Map<String, Object?> args = {
      'uid': uid, // User id
      'hours_type': hoursType, // Active or Passive
      'activity': activity, // Specific Active or Passive Activity
      'active_type': activeType, // Activity
      'amount': amount, // Number of Hours
      'receipt_no': receiptNo, // Receipt No
      'evidenceUrls':
          evidenceUrls, // List of urls where uploaded photos for evidence are stored
      'optionalUrls':
          optionalUrls, // List of urls for any other additional photos
      'validated': false, // Set validated state to be false
    };

    try {
      // Log the corresponding hours claim to firestore
      await hoursCollection.add(args);

      String? userName = await getUserData();
      String body = "$userName has completed $amount hours of $activity";

      // Send a notification to the admin of this upload
      NotificationServices().sendNotification(uid, "New hours logged", body);
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
}
