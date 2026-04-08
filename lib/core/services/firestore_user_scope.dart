import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUserScope {
  FirestoreUserScope._();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static User get currentUser {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }
    return user;
  }

  static String get uid => currentUser.uid;

  static DocumentReference<Map<String, dynamic>> get userDoc =>
      firestore.collection('users').doc(uid);

  static CollectionReference<Map<String, dynamic>> get itemsCollection =>
      userDoc.collection('items');

  static CollectionReference<Map<String, dynamic>> get transactionsCollection =>
      userDoc.collection('transactions');
}