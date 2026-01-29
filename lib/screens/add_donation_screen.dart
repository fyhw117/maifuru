import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class AddDonationScreen extends StatefulWidget {
  final Donation? donation;

  const AddDonationScreen({super.key, this.donation});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _municipalityController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productUrlController = TextEditingController();
  final _amountController = TextEditingController();
  late DateTime _selectedDate;
  final _repository = DonationRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.donation?.date ?? DateTime.now();
    if (widget.donation != null) {
      _municipalityController.text = widget.donation!.municipality;
      _productNameController.text = widget.donation!.productName;
      _productUrlController.text = widget.donation!.productUrl ?? '';
      _amountController.text = widget.donation!.amount.toString();
    }
  }

  @override
  void dispose() {
    _municipalityController.dispose();
    _productNameController.dispose();
    _productUrlController.dispose();
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
          id: widget.donation?.id ?? '', // Use existing ID if editing
          municipality: _municipalityController.text,
          productName: _productNameController.text,
          productUrl: _productUrlController.text.isEmpty
              ? null
              : _productUrlController.text,
          amount: int.parse(_amountController.text),
          date: _selectedDate,
          status: widget.donation?.status ?? OneStopStatus.pending,
        );

        if (widget.donation != null) {
          await _repository.updateDonation(donation);
        } else {
          await _repository.addDonation(donation);
        }

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

  Future<void> _deleteDonation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('この寄付記録を削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _repository.deleteDonation(widget.donation!.id);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('寄付を削除しました')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.donation != null ? '寄付を編集' : '寄付を追加'),
        actions: [
          if (widget.donation != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteDonation,
            ),
        ],
      ),
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
                      controller: _productUrlController,
                      decoration: InputDecoration(
                        labelText: '商品ページURL (任意)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.link),
                        suffixIcon: _productUrlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () async {
                                  final urlString = _productUrlController.text;
                                  final uri = Uri.tryParse(urlString);
                                  if (uri != null && await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('無効なURLです'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (value) {
                        setState(() {}); // Rebuild to substring suffix icon
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
