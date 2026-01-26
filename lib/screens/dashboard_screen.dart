import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import '../widgets/summary_card.dart';
import '../widgets/municipality_counter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DonationRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ダッシュボード'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: StreamBuilder<List<Donation>>(
        stream: repository.getDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data ?? [];
          final totalAmount = donations.fold<int>(
            0,
            (sum, donation) => sum + donation.amount,
          );
          final uniqueMunicipalities = donations
              .map((d) => d.municipality)
              .toSet()
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryCard(totalAmount: totalAmount),
                const SizedBox(height: 24),
                Text(
                  '自治体カウンター',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                MunicipalityCounter(count: uniqueMunicipalities),
              ],
            ),
          );
        },
      ),
    );
  }
}
