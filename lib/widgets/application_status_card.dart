import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';

class ApplicationStatusCard extends StatelessWidget {
  final Donation donation;
  final ValueChanged<OneStopStatus> onStatusChanged;

  const ApplicationStatusCard({
    super.key,
    required this.donation,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy/MM/dd');

    Color statusColor;
    String statusText;
    switch (donation.status) {
      case OneStopStatus.completed:
        statusColor = Colors.green;
        statusText = '完了';
        break;
      case OneStopStatus.sent:
        statusColor = Colors.blue;
        statusText = '送付済';
        break;
      case OneStopStatus.notRequired:
        statusColor = Colors.grey;
        statusText = '対象外';
        break;
      case OneStopStatus.pending:
        statusColor = Theme.of(context).colorScheme.error;
        statusText = '未完了';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.municipality,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '寄付日: ${dateFormatter.format(donation.date)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return ToggleButtons(
                isSelected: [
                  donation.status == OneStopStatus.pending,
                  donation.status == OneStopStatus.sent,
                  donation.status == OneStopStatus.completed,
                ],
                onPressed: (index) {
                  final newStatus = [
                    OneStopStatus.pending,
                    OneStopStatus.sent,
                    OneStopStatus.completed,
                  ][index];
                  if (newStatus != donation.status) {
                    onStatusChanged(newStatus);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                constraints: BoxConstraints.expand(
                  width: (constraints.maxWidth - 4) / 3,
                  height: 40,
                ),
                fillColor: Theme.of(context).colorScheme.primaryContainer,
                selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                renderBorder: true,
                borderColor: Theme.of(context).colorScheme.outlineVariant,
                selectedBorderColor: Theme.of(context).colorScheme.primary,
                children: const [Text('未着手'), Text('送付済'), Text('完了')],
              );
            },
          ),
        ],
      ),
    );
  }
}
