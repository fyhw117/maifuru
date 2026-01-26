import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _municipalityController = TextEditingController();
  final _productNameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _repository = DonationRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _municipalityController.dispose();
    _productNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveDonation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final donation = Donation(
          id: '', // Firestore will generate ID
          municipality: _municipalityController.text,
          productName: _productNameController.text,
          amount: int.parse(_amountController.text),
          date: _selectedDate,
        );

        await _repository.addDonation(donation);

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('寄付を記録しました')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('寄付を追加')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _municipalityController,
                      decoration: const InputDecoration(
                        labelText: '自治体名',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '自治体名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: '返礼品名',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.card_giftcard),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '返礼品名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '寄付金額',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_yen),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '寄付金額を入力してください';
                        }
                        if (int.tryParse(value) == null) {
                          return '有効な数字を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '寄付日',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('yyyy/MM/dd').format(_selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _saveDonation,
                      icon: const Icon(Icons.save),
                      label: const Text('保存'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
