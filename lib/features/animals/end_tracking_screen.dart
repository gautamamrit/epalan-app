import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/animal.dart';
import '../../data/providers/animal_provider.dart';

class EndTrackingScreen extends ConsumerStatefulWidget {
  final String farmId;
  final Animal animal;

  const EndTrackingScreen({
    super.key,
    required this.farmId,
    required this.animal,
  });

  @override
  ConsumerState<EndTrackingScreen> createState() => _EndTrackingScreenState();
}

class _EndTrackingScreenState extends ConsumerState<EndTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _saleCountController = TextEditingController();
  final _saleWeightController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _saleTotalController = TextEditingController();

  String _selectedStatus = 'sold';
  DateTime _endDate = DateTime.now();
  bool _isSubmitting = false;

  static const _statusOptions = [
    ('sold', 'Sold'),
    ('transferred', 'Transferred'),
    ('deceased', 'Deceased'),
    ('slaughtered', 'Slaughtered'),
    ('archived', 'Archived'),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _saleCountController.dispose();
    _saleWeightController.dispose();
    _salePriceController.dispose();
    _saleTotalController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(animalServiceProvider).updateAnimal(
        widget.farmId,
        widget.animal.id,
        status: _selectedStatus,
        endDate: _endDate,
        endNotes: _notesController.text.isNotEmpty ? _notesController.text : null,
        saleCount: _saleCountController.text.isNotEmpty
            ? int.tryParse(_saleCountController.text) : null,
        saleWeightKg: _saleWeightController.text.isNotEmpty
            ? double.tryParse(_saleWeightController.text) : null,
        salePricePerKg: _salePriceController.text.isNotEmpty
            ? double.tryParse(_salePriceController.text) : null,
        saleTotal: _saleTotalController.text.isNotEmpty
            ? double.tryParse(_saleTotalController.text) : null,
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Animal marked as $_selectedStatus'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    color: AppColors.primary, size: 20),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'End Tracking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Status ──
            _sectionHeader('Status'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions
                  .map((s) => _chip(
                        label: s.$2,
                        isSelected: _selectedStatus == s.$1,
                        onTap: () => setState(() => _selectedStatus = s.$1),
                      ))
                  .toList(),
            ),

            _divider(),

            // ── End Date ──
            _sectionHeader('End Date'),
            const SizedBox(height: 12),
            _pickerRow(
              label: _formatDate(_endDate),
              onTap: _selectDate,
            ),

            _divider(),

            // ── Notes ──
            _sectionHeader('Notes'),
            const SizedBox(height: 8),
            _textInput(
              controller: _notesController,
              hint: 'Optional notes...',
              maxLines: 3,
            ),

            // ── Sale Details (only for sold) ──
            if (_selectedStatus == 'sold') ...[
              _divider(),
              _sectionHeader('Sale Details'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _labeledNumberInput(label: 'Count', controller: _saleCountController, digitsOnly: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _labeledNumberInput(label: 'Weight (kg)', controller: _saleWeightController)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _labeledNumberInput(label: 'Price/kg', controller: _salePriceController)),
                  const SizedBox(width: 12),
                  Expanded(child: _labeledNumberInput(label: 'Total', controller: _saleTotalController)),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Confirm',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared helpers (same as AddAnimalScreen) ──

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: AppColors.border, height: 1),
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _labeledNumberInput({
    required String label,
    required TextEditingController controller,
    bool digitsOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        _numberInput(controller: controller, digitsOnly: digitsOnly),
      ],
    );
  }

  Widget _numberInput({
    required TextEditingController controller,
    bool digitsOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: digitsOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _pickerRow({
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
