import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation.dart';

class DonationRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'donations',
  );

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
