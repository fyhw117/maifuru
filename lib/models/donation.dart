import 'package:cloud_firestore/cloud_firestore.dart';

enum OneStopStatus {
  waiting, // 書類待ち
  pending, // 未着手
  completed, // 完了
  notRequired, // 対象外
}

class Donation {
  final String id;
  final String municipality;
  final String productName;
  final int amount;
  final DateTime date;
  final String? note;
  final OneStopStatus status;

  Donation({
    required this.id,
    required this.municipality,
    required this.productName,
    required this.amount,
    required this.date,
    this.note,
    this.status = OneStopStatus.pending,
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
      status: OneStopStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => OneStopStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'municipality': municipality,
      'productName': productName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'status': status.name,
    };
  }

  Donation copyWith({
    String? id,
    String? municipality,
    String? productName,
    int? amount,
    DateTime? date,
    String? note,
    OneStopStatus? status,
  }) {
    return Donation(
      id: id ?? this.id,
      municipality: municipality ?? this.municipality,
      productName: productName ?? this.productName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }
}
