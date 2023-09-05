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

}
