import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import '../widgets/donation_card.dart';

class DonationListScreen extends StatelessWidget {
  const DonationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DonationRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('寄付履歴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/donations/add');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('記録を追加'),
      ),
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

          if (donations.isEmpty) {
            return const Center(
              child: Text('寄付の記録がありません', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              return DonationCard(donation: donations[index]);
            },
          );
        },
      ),
    );
  }
}
