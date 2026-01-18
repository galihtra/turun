import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/weight/weight_provider.dart';
import '../../../resources/colors_app.dart';
import '../../../resources/styles_app.dart';
import '../../../app/app_dialog.dart';

/// Modal bottom sheet for adding a new weight entry
class AddWeightModal extends StatefulWidget {
  const AddWeightModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddWeightModal(),
    );
  }

  @override
  State<AddWeightModal> createState() => _AddWeightModalState();
}

class _AddWeightModalState extends State<AddWeightModal> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A2B3C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text);
    if (weight == null) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<WeightProvider>(context, listen: false);
    final success = await provider.addWeight(weight, recordedAt: _selectedDate);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      AppDialog.toastSuccess('Weight added successfully!');
      Navigator.of(context).pop(true);
    } else {
      AppDialog.toastError(provider.error ?? 'Failed to add weight');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Add Weight',
                style: AppStyles.title2SemiBold.copyWith(
                  color: const Color(0xFF1A2B3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Record your current weight to track progress',
                style: AppStyles.body2Regular.copyWith(
                  color: const Color(0xFF8896A6),
                ),
              ),
              const SizedBox(height: 24),

              // Weight input
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: AppStyles.title3Medium.copyWith(
                  color: const Color(0xFF1A2B3C),
                ),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: AppStyles.body2Regular.copyWith(
                    color: const Color(0xFF8896A6),
                  ),
                  hintText: 'Enter your weight',
                  hintStyle: AppStyles.body2Regular.copyWith(
                    color: const Color(0xFFB0BEC5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF4A90E2),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.red.shade300,
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  suffixText: 'kg',
                  suffixStyle: AppStyles.body2SemiBold.copyWith(
                    color: const Color(0xFF4A90E2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0 || weight > 500) {
                    return 'Please enter a valid weight (1-500 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date selector
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF8896A6),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: AppStyles.label3Regular.copyWith(
                              color: const Color(0xFF8896A6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(_selectedDate),
                            style: AppStyles.body2Medium.copyWith(
                              color: const Color(0xFF1A2B3C),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveWeight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    disabledBackgroundColor: const Color(0xFF4A90E2).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Weight',
                          style: AppStyles.body1SemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}
