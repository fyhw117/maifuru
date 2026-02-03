import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';

class ApplicationStatusCard extends StatefulWidget {
  final Donation donation;
  final ValueChanged<OneStopStatus> onStatusChanged;
  final ValueChanged<String>? onNoteChanged;

  const ApplicationStatusCard({
    super.key,
    required this.donation,
    required this.onStatusChanged,
    this.onNoteChanged,
  });

  @override
  State<ApplicationStatusCard> createState() => _ApplicationStatusCardState();
}

class _ApplicationStatusCardState extends State<ApplicationStatusCard> {
  late TextEditingController _noteController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.donation.note);
  }

  @override
  void didUpdateWidget(covariant ApplicationStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller text if the widget is NOT focused.
    // This prevents the cursor/IME state from breaking due to Firestore stream updates
    // triggered by our own edits.
    if (oldWidget.donation.note != widget.donation.note &&
        !_focusNode.hasFocus) {
      _noteController.text = widget.donation.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy/MM/dd');

    Color statusColor;
    String statusText;
    switch (widget.donation.status) {
      case OneStopStatus.completed:
        statusColor = Colors.green;
        statusText = '完了';
        break;
      case OneStopStatus.waiting:
        statusColor = Colors.orange;
        statusText = '書類待ち';
        break;
      case OneStopStatus.notRequired:
        statusColor = Colors.grey;
        statusText = '対象外';
        break;
      case OneStopStatus.pending:
        statusColor = Theme.of(context).colorScheme.error;
        statusText = '未着手';
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.donation.municipality,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.donation.productName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '寄付日: ${dateFormatter.format(widget.donation.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                  widget.donation.status == OneStopStatus.waiting,
                  widget.donation.status == OneStopStatus.pending,
                  widget.donation.status == OneStopStatus.completed,
                  widget.donation.status == OneStopStatus.notRequired,
                ],
                onPressed: (index) {
                  final newStatus = [
                    OneStopStatus.waiting,
                    OneStopStatus.pending,
                    OneStopStatus.completed,
                    OneStopStatus.notRequired,
                  ][index];
                  if (newStatus != widget.donation.status) {
                    widget.onStatusChanged(newStatus);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                constraints: BoxConstraints.expand(
                  width: (constraints.maxWidth - 12) / 4,
                  height: 40,
                ),
                fillColor: Theme.of(context).colorScheme.primaryContainer,
                selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                renderBorder: true,
                borderColor: Theme.of(context).colorScheme.outlineVariant,
                selectedBorderColor: Theme.of(context).colorScheme.primary,
                children: const [
                  FittedBox(fit: BoxFit.scaleDown, child: Text('書類待ち')),
                  FittedBox(fit: BoxFit.scaleDown, child: Text('未着手')),
                  FittedBox(fit: BoxFit.scaleDown, child: Text('完了')),
                  FittedBox(fit: BoxFit.scaleDown, child: Text('対象外')),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              hintText: 'メモを入力...',
              prefixIcon: Icon(Icons.edit_note, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
            maxLines: null,
            onChanged: (value) {
              widget.onNoteChanged?.call(value);
            },
          ),
        ],
      ),
    );
  }
}
