import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import '../widgets/application_status_card.dart';

class ApplicationScreen extends StatelessWidget {
  const ApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DonationRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('申請管理')),
      body: StreamBuilder<List<Donation>>(
        stream: repository.getDonations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data ?? [];
          // Filter to show only relevant donations if needed, or sort by status
          // For now, let's sort so pending ones are at top
          donations.sort((a, b) {
            if (a.status == b.status) return b.date.compareTo(a.date);
            if (a.status == OneStopStatus.pending) return -1;
            if (b.status == OneStopStatus.pending) return 1;
            return 0; // Keep others in date order
          });

          if (donations.isEmpty) {
            return const Center(
              child: Text(
                '申請が必要な寄付はありません',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final donation = donations[index];
              return ApplicationStatusCard(
                donation: donation,
                onStatusChanged: (newStatus) {
                  repository.updateDonation(
                    donation.copyWith(status: newStatus),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
