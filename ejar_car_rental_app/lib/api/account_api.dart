import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/account.dart';

class AccountAPI {
  final _firestore = FirebaseFirestore.instance;

  Future<Account?> getAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('accounts').doc(user.uid).get();

    if (doc.exists) {
      return Account.fromMap(doc.id, doc.data()!);
    } else {
      return null;
    }
  }

  /// Creates or updates account data (optional method)
  Future<void> saveAccount(Account account) async {
    await _firestore.collection('accounts').doc(account.id).set(account.toMap());
  }
}
