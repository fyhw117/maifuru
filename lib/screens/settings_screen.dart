import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          _buildSectionHeader(context, '目標設定'),
          _buildMaxAmountSetting(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'シミュレーター'),
          _buildSimulatorCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'アカウント'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('プロフィール設定'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ログアウト', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSimulatorCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.calculate_outlined),
                SizedBox(width: 8),
                Text(
                  '上限額シミュレーター',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '年収 (万円)',
                border: OutlineInputBorder(),
                suffixText: '万円',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '家族構成',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'single', child: Text('独身・共働き')),
                DropdownMenuItem(value: 'married', child: Text('夫婦 (配偶者控除なし)')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () {}, child: const Text('計算する')),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxAmountSetting(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '¥',
      decimalDigits: 0,
    );

    return ListTile(
      leading: const Icon(Icons.savings_outlined),
      title: const Text('今年の寄付上限額'),
      subtitle: Text(
        currencyFormatter.format(settingsService.maxDonationAmount),
      ),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        await _showMaxAmountDialog(context, settingsService);
      },
    );
  }

  Future<void> _showMaxAmountDialog(
    BuildContext context,
    SettingsService settingsService,
  ) async {
    final controller = TextEditingController(
      text: settingsService.maxDonationAmount.toString(),
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('上限額を設定'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '金額',
              suffixText: '円',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () {
                final newValue = int.tryParse(controller.text);
                if (newValue != null && newValue >= 0) {
                  settingsService.setMaxDonationAmount(newValue);
                  Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
