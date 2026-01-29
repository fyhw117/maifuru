import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  static const String _maxDonationAmountKey = 'max_donation_amount';
  static const String _incomeKey = 'income_amount';
  static const String _familyStructureKey = 'family_structure';

  // Default max amount is 0 yen
  int _maxDonationAmount = 0;
  int? _income;
  String? _familyStructure;
  String? _userId;

  int get maxDonationAmount => _maxDonationAmount;
  int? get income => _income;
  String? get familyStructure => _familyStructure;

  SettingsService() {
    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _userId = user?.uid;
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    // If no user is logged in, reset settings to defaults
    if (_userId == null) {
      _maxDonationAmount = 0;
      _income = null;
      _familyStructure = null;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final prefix = '${_userId}_';

    _maxDonationAmount = prefs.getInt('$prefix$_maxDonationAmountKey') ?? 0;
    _income = prefs.getInt('$prefix$_incomeKey');
    _familyStructure = prefs.getString('$prefix$_familyStructureKey');
    notifyListeners();
  }

  Future<void> setMaxDonationAmount(int amount) async {
    _maxDonationAmount = amount;
    if (_userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_userId}_$_maxDonationAmountKey', amount);
    }
    notifyListeners();
  }

  Future<void> setIncome(int value) async {
    _income = value;
    if (_userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_userId}_$_incomeKey', value);
    }
    notifyListeners();
  }

  Future<void> setFamilyStructure(String value) async {
    _familyStructure = value;
    if (_userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_userId}_$_familyStructureKey', value);
    }
    notifyListeners();
  }

  /// Calculates the estimated max donation amount based on annual income (in 10,000 Yen)
  /// and family structure.
  /// Returns the amount in Yen.
  int calculateEstimatedMaxDonation(
    int annualIncomeManYen,
    String? familyType,
  ) {
    if (annualIncomeManYen < 300) {
      // Minimum calculation or simplistic lower bound
      // Below 3 million, it drops off correctly but let's just return a safe baseline or 0 if very low
      if (annualIncomeManYen < 150) return 0;
      return 10000; // minimal baseline
    }

    // Data points (Income in ManYen, Limit in ManYen)
    // Source: Ministry of Internal Affairs and Communications (Approximate)
    final Map<int, double> singleTable = {
      300: 2.8,
      400: 4.2,
      500: 6.1,
      600: 7.7,
      700: 10.8,
      800: 12.9,
      900: 15.2,
      1000: 17.6,
      1200: 22.5,
      1500: 38.9,
      2000: 56.5,
      2500: 84.5,
    };

    final Map<int, double> marriedTable = {
      300: 1.9,
      400: 3.3,
      500: 4.9,
      600: 6.9,
      700: 8.6,
      800: 12.0,
      900: 14.1,
      1000: 16.6,
      1200: 21.5,
      1500: 38.0, // Deduc reduces impact at high income
      2000: 55.8,
      2500: 83.5,
    };

    final table = (familyType == 'married') ? marriedTable : singleTable;

    // Find the range
    int? lowerKey;
    int? upperKey;

    final sortedKeys = table.keys.toList()..sort();

    for (final key in sortedKeys) {
      if (key <= annualIncomeManYen) {
        lowerKey = key;
      }
      if (key >= annualIncomeManYen) {
        upperKey = key;
        break;
      }
    }

    // Extrapolation or Exact Match
    if (lowerKey == null) return 0;
    if (upperKey == null)
      return (table[lowerKey]! * 10000).round(); // Above max range
    if (lowerKey == upperKey) return (table[lowerKey]! * 10000).round();

    // Interpolation
    final double lowerVal = table[lowerKey]!;
    final double upperVal = table[upperKey]!;

    final double fraction =
        (annualIncomeManYen - lowerKey) / (upperKey - lowerKey);
    final double estimatedManYen = lowerVal + (upperVal - lowerVal) * fraction;

    return (estimatedManYen * 10000).round();
  }
}
