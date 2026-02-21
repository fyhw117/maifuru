import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donation.dart';

class ApplicationStatusCard extends StatefulWidget {
  final Donation donation;
  final ValueChanged<OneStopStatus> onStatusChanged;
  final ValueChanged<String>? onNoteChanged;
  final ValueChanged<String>? onApplicationUrlChanged;

  const ApplicationStatusCard({
    super.key,
    required this.donation,
    required this.onStatusChanged,
    this.onNoteChanged,
    this.onApplicationUrlChanged,
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
      case OneStopStatus.notPurchased:
        statusColor = Theme.of(context).colorScheme.error;
        statusText = '未購入';
        break;
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
        statusColor = Colors.blue;
        statusText = '未申請';
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
                      widget.donation.date != null
                          ? '購入日: ${dateFormatter.format(widget.donation.date!)}'
                          : '未購入',
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
                  widget.donation.status == OneStopStatus.notPurchased,
                  widget.donation.status == OneStopStatus.pending,
                  widget.donation.status == OneStopStatus.waiting,
                  widget.donation.status == OneStopStatus.completed,
                  widget.donation.status == OneStopStatus.notRequired,
                ],
                onPressed: (index) {
                  final newStatus = [
                    OneStopStatus.notPurchased,
                    OneStopStatus.pending,
                    OneStopStatus.waiting,
                    OneStopStatus.completed,
                    OneStopStatus.notRequired,
                  ][index];
                  if (newStatus != widget.donation.status) {
                    widget.onStatusChanged(newStatus);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                constraints: BoxConstraints.expand(
                  width: (constraints.maxWidth - 16) / 5,
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
                  FittedBox(fit: BoxFit.scaleDown, child: Text('未購入')),
                  FittedBox(fit: BoxFit.scaleDown, child: Text('未申請')),
                  FittedBox(fit: BoxFit.scaleDown, child: Text('書類待ち')),
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
          const SizedBox(height: 8),
          _buildUrlSection(context),
        ],
      ),
    );
  }

  Widget _buildUrlSection(BuildContext context) {
    final url = widget.donation.applicationUrl;
    if (url == null || url.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => _showUrlEditDialog(context),
          icon: const Icon(Icons.link_rounded, size: 16),
          label: const Text('申請用URLを登録', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => _launchUrl(url),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('申請サイトを開く', style: TextStyle(fontSize: 12)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size.fromHeight(36),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showUrlEditDialog(context),
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          tooltip: 'URLを編集',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
      }
    }
  }

  void _showUrlEditDialog(BuildContext context) {
    final controller = TextEditingController(
      text: widget.donation.applicationUrl,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '申請用URL',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'https://...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              isDense: true,
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApplicationUrlChanged?.call(controller.text.trim());
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
