import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _incomeController = TextEditingController();
  String? _selectedFamilyStructure;

  SettingsService? _settingsService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newSettings = context.read<SettingsService>();
    if (_settingsService != newSettings) {
      _settingsService?.removeListener(_updateFromSettings);
      _settingsService = newSettings;
      _settingsService?.addListener(_updateFromSettings);
      _updateFromSettings();
    }
  }

  @override
  void dispose() {
    _settingsService?.removeListener(_updateFromSettings);
    _incomeController.dispose();
    super.dispose();
  }

  void _updateFromSettings() {
    if (_settingsService == null) return;
    final income = _settingsService!.income;
    final familyStructure = _settingsService!.familyStructure;

    // Only update text controller if the value has changed significantly
    // to avoid messing with cursor position if the user is typing,
    // though this method is called primarily on load or external change.
    if (income != null) {
      final currentText = _incomeController.text;
      final currentIncome = int.tryParse(currentText);
      if (currentIncome != income) {
        _incomeController.text = income.toString();
      }
    }

    if (familyStructure != null &&
        _selectedFamilyStructure != familyStructure) {
      setState(() {
        _selectedFamilyStructure = familyStructure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定'), centerTitle: false),
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
            leading: const Icon(Icons.logout),
            title: Text(
              FirebaseAuth.instance.currentUser?.isAnonymous == true
                  ? 'ゲスト利用を終了'
                  : 'ログアウト',
            ),
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user?.isAnonymous == true) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ゲスト利用を終了しますか？'),
                    content: const Text(
                      'ゲスト利用を終了すると、現在保存されているデータはすべて削除され、復元することはできません。\n\n本当に終了してもよろしいですか？',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('キャンセル'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('終了する'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
              }
              await AuthService().signOut();
            },
          ),
          if (FirebaseAuth.instance.currentUser?.isAnonymous != true)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('アカウント削除', style: TextStyle(color: Colors.red)),
              onTap: () => _showDeleteAccountDialog(context),
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
              controller: _incomeController,
              decoration: const InputDecoration(
                labelText: '年収 (万円)',
                border: OutlineInputBorder(),
                suffixText: '万円',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final income = int.tryParse(value);
                if (income != null) {
                  context.read<SettingsService>().setIncome(income);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedFamilyStructure,
              decoration: const InputDecoration(
                labelText: '家族構成',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'single', child: Text('独身・共働き')),
                DropdownMenuItem(value: 'married', child: Text('夫婦 (配偶者控除あり)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFamilyStructure = value;
                });
                if (value != null) {
                  context.read<SettingsService>().setFamilyStructure(value);
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _runSimulation(context),
              child: const Text('計算する'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showCalculationInfoDialog(context),
              child: const Text(
                '計算の根拠・方法',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalculationInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('計算の根拠について'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '本シミュレーターの算出額は、総務省が公開している「全額控除されるふるさと納税額（年間上限）の目安」を基準としています。',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                '【計算方法】',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '総務省の目安表にある年収ごとの上限額を参照し、表にない年収の場合は、前後の値を用いて按分（補間）計算を行っています。',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ご注意',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '実際の控除上限額は、お住まいの地域、医療費控除や住宅ローン控除の有無、その他の控除状況により異なります。\n正確な金額については、お住まいの自治体や税理士にご確認ください。',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _runSimulation(BuildContext context) {
    final incomeStr = _incomeController.text;
    final income = int.tryParse(incomeStr);

    if (income == null || income <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('正しい年収を入力してください')));
      return;
    }

    final settings = context.read<SettingsService>();
    final result = settings.calculateEstimatedMaxDonation(
      income,
      _selectedFamilyStructure ?? 'single',
    );

    final formattedResult = NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '¥',
      decimalDigits: 0,
    ).format(result);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('シミュレーション結果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('あなたの寄付上限額の目安は'),
            const SizedBox(height: 8),
            Text(
              formattedResult,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'です。\n※あくまで目安です。正確な金額は税理士やお住まいの自治体にご確認ください。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsService>().setMaxDonationAmount(result);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('上限額を $formattedResult に設定しました')),
              );
            },
            child: const Text('設定に反映する'),
          ),
        ],
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

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('アカウント削除'),
          content: const Text(
            'アカウントを削除すると、すべてのデータが完全に消去され、復元することはできません。\n\n本当によろしいですか？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                try {
                  await context.read<AuthService>().deleteAccount();
                  // Navigation to Login Screen is handled by auth state changes in main.dart
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('エラーが発生しました: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );
  }
}
