import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import '../widgets/summary_card.dart';
import '../widgets/municipality_counter.dart';
import '../services/settings_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final repository = DonationRepository();
    final settingsService = context.watch<SettingsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('ダッシュボード')),
      body: StreamBuilder<List<Donation>>(
        stream: repository.getDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data ?? [];

          // Get unique years from donations, add current year, sort descending
          final years = donations
              .map((d) => d.date?.year ?? DateTime.now().year)
              .toSet();
          years.add(DateTime.now().year);
          final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

          // Ensure selected year is valid
          if (!sortedYears.contains(_selectedYear)) {
            _selectedYear = sortedYears.first;
          }

          final displayDonations = donations
              .where(
                (d) => (d.date?.year ?? DateTime.now().year) == _selectedYear,
              )
              .toList();

          final totalAmount = displayDonations.fold<int>(
            0,
            (sum, donation) => sum + donation.amount,
          );
          final uniqueMunicipalities = displayDonations
              .map((d) => d.municipality)
              .toSet()
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          items: sortedYears.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(
                                '$year年',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedYear = value;
                              });
                            }
                          },
                          icon: const Icon(Icons.arrow_drop_down),
                          dropdownColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SummaryCard(
                  totalAmount: totalAmount,
                  maxAmount: settingsService.maxDonationAmount,
                  year: _selectedYear,
                ),
                const SizedBox(height: 24),
                Text(
                  '自治体カウンター',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                MunicipalityCounter(count: uniqueMunicipalities),
                const SizedBox(height: 24),
                Text(
                  '自治体別内訳',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildMunicipalityList(context, displayDonations),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMunicipalityList(
    BuildContext context,
    List<Donation> donations,
  ) {
    if (donations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('寄付の記録はありません'),
        ),
      );
    }

    // Group by municipality
    final Map<String, List<Donation>> grouped = {};
    for (var donation in donations) {
      if (!grouped.containsKey(donation.municipality)) {
        grouped[donation.municipality] = [];
      }
      grouped[donation.municipality]!.add(donation);
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '¥',
      decimalDigits: 0,
    );

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final municipality = grouped.keys.elementAt(index);
        final municipalityDonations = grouped[municipality]!;
        final totalAmount = municipalityDonations.fold<int>(
          0,
          (sum, d) => sum + d.amount,
        );
        final count = municipalityDonations.length;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  municipality.substring(0, 1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      municipality,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '寄付 $count件',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormatter.format(totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
