import 'package:cloud_firestore/cloud_firestore.dart';

enum OneStopStatus {
  notPurchased, // 未購入
  waiting, // 書類待ち
  pending, // 未申請
  completed, // 完了
  notRequired, // 対象外
}

class Donation {
  final String id;
  final String municipality;
  final String productName;
  final String? productUrl;
  final String? applicationUrl;
  final int amount;
  final DateTime? date;
  final String? note;
  final OneStopStatus status;

  Donation({
    required this.id,
    required this.municipality,
    required this.productName,
    this.productUrl,
    this.applicationUrl,
    required this.amount,
    this.date,
    this.note,
    this.status = OneStopStatus.pending,
  });

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Donation(
      id: doc.id,
      municipality: data['municipality'] ?? '',
      productName: data['productName'] ?? '',
      productUrl: data['productUrl'],
      applicationUrl: data['applicationUrl'],
      amount: data['amount'] ?? 0,
      date: (data['date'] as Timestamp?)?.toDate(),
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
      'productUrl': productUrl,
      'applicationUrl': applicationUrl,
      'amount': amount,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'note': note,
      'status': status.name,
    };
  }

  Donation copyWith({
    String? id,
    String? municipality,
    String? productName,
    String? productUrl,
    String? applicationUrl,
    int? amount,
    DateTime? date,
    String? note,
    OneStopStatus? status,
  }) {
    return Donation(
      id: id ?? this.id,
      municipality: municipality ?? this.municipality,
      productName: productName ?? this.productName,
      productUrl: productUrl ?? this.productUrl,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }
}
