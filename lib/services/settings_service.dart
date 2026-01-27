import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  static const String _maxDonationAmountKey = 'max_donation_amount';

  // Default max amount is 80,000 yen
  int _maxDonationAmount = 80000;

  int get maxDonationAmount => _maxDonationAmount;

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _maxDonationAmount = prefs.getInt(_maxDonationAmountKey) ?? 80000;
    notifyListeners();
  }

  Future<void> setMaxDonationAmount(int amount) async {
    _maxDonationAmount = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxDonationAmountKey, amount);
    notifyListeners();
  }
}
