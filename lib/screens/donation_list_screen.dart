import 'package:flutter/material.dart';
import '../widgets/donation_card.dart';

class DonationListScreen extends StatelessWidget {
  const DonationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          // TODO: Add donation view
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('記録を追加'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const DonationCard();
        },
      ),
    );
  }
}
