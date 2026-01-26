import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/donation.dart';

class DonationRepository {
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _collection {
    if (_userId == null) {
      throw Exception('User must be logged in to access donations');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('donations');
  }

  Stream<List<Donation>> getDonations() {
    return _collection.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => Donation.fromFirestore(doc)).toList();
    });
  }

  Future<void> addDonation(Donation donation) {
    return _collection.add(donation.toMap());
  }

  Future<void> updateDonation(Donation donation) {
    return _collection.doc(donation.id).update(donation.toMap());
  }

  Future<void> deleteDonation(String id) {
    return _collection.doc(id).delete();
  }
}
