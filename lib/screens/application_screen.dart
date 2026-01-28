import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import '../widgets/application_status_card.dart';

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  int _selectedYear = DateTime.now().year;

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

          final allDonations = snapshot.data ?? [];

          if (allDonations.isEmpty) {
            return const Center(
              child: Text('寄付の記録がありません', style: TextStyle(color: Colors.grey)),
            );
          }

          // Get unique years and sort descending
          final years = allDonations.map((d) => d.date.year).toSet();
          years.add(
            DateTime.now().year,
          ); // Ensure current year is always available
          final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

          // Ensure selected year is valid
          if (!sortedYears.contains(_selectedYear)) {
            _selectedYear = sortedYears.first;
          }

          // Filter by selected year
          final displayDonations = allDonations
              .where((d) => d.date.year == _selectedYear)
              .toList();

          // Sort: Pending first, then by date descending
          displayDonations.sort((a, b) {
            if (a.status == b.status) return b.date.compareTo(a.date);
            if (a.status == OneStopStatus.pending) return -1;
            if (b.status == OneStopStatus.pending) return 1;
            return b.date.compareTo(a.date);
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
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
                                '$year年分',
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
              ),
              Expanded(
                child: displayDonations.isEmpty
                    ? Center(
                        child: Text(
                          '$_selectedYear年の寄付記録はありません',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: displayDonations.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final donation = displayDonations[index];
                          return ApplicationStatusCard(
                            donation: donation,
                            onStatusChanged: (newStatus) {
                              repository.updateDonation(
                                donation.copyWith(status: newStatus),
                              );
                            },
                            onNoteChanged: (newNote) {
                              // Debounce could be added here for optimization if needed
                              repository.updateDonation(
                                donation.copyWith(note: newNote),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
