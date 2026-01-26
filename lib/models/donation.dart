import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id;
  final String municipality;
  final String productName;
  final int amount;
  final DateTime date;
  final String? note;
  // TODO: Add fields for One-stop application status later if needed

  Donation({
    required this.id,
    required this.municipality,
    required this.productName,
    required this.amount,
    required this.date,
    this.note,
  });

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Donation(
      id: doc.id,
      municipality: data['municipality'] ?? '',
      productName: data['productName'] ?? '',
      amount: data['amount'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'municipality': municipality,
      'productName': productName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
