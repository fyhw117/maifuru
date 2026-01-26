import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
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
            onTap: () {},
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
}
