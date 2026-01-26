import 'package:flutter/material.dart';

class ApplicationStatusCard extends StatelessWidget {
  const ApplicationStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    '北海道 紋別市',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '寄付日: 2024/01/15',
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
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '未完了',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return ToggleButtons(
                isSelected: const [true, false, false],
                onPressed: (index) {},
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
