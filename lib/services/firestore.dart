import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final String uid; // Reference to the user id
  FirestoreService({required this.uid});

  // Reference the user collection
  final CollectionReference collection =
      FirebaseFirestore.instance.collection("Users");

  // Update the user's details
  Future setUserData(Map<String, String?> data) async {
    return await collection.doc(uid).set(data);
  }
}
