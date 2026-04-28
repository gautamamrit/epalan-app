import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/animal.dart';
import '../../data/providers/animal_provider.dart';

class AddRecordScreen extends ConsumerStatefulWidget {
  final String farmId;
  final String animalId;
  final String animalName;
  final int currentDay;
  final bool isLayer;
  final DailyRecord? existingRecord;

  const AddRecordScreen({
    super.key,
    required this.farmId,
    required this.animalId,
    required this.animalName,
    required this.currentDay,
    required this.isLayer,
    this.existingRecord,
  });

  bool get isEditMode => existingRecord != null;

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mortalityController = TextEditingController();
  final _mortalityNotesController = TextEditingController();
  final _feedController = TextEditingController();
  final _weightSampleController = TextEditingController();
  final _weightAvgController = TextEditingController();
  final _eggsController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final record = widget.existingRecord;
    if (record != null) {
      _mortalityController.text = record.mortalityCount > 0 ? '${record.mortalityCount}' : '';
      _mortalityNotesController.text = record.mortalityReason ?? '';
      _feedController.text = record.feedConsumedKg != null ? '${record.feedConsumedKg}' : '';
      _weightSampleController.text = record.sampleCount != null ? '${record.sampleCount}' : '';
      _weightAvgController.text = record.avgWeightKg != null ? '${record.avgWeightKg}' : '';
      _eggsController.text = record.eggsCollected != null ? '${record.eggsCollected}' : '';
      _notesController.text = record.notes ?? '';
      _recordDate = record.recordDate;
    }
  }

  @override
  void dispose() {
    _mortalityController.dispose();
    _mortalityNotesController.dispose();
    _feedController.dispose();
    _weightSampleController.dispose();
    _weightAvgController.dispose();
    _eggsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
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
    if (picked != null) {
      setState(() => _recordDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasMortality = _mortalityController.text.isNotEmpty;
    final hasFeed = _feedController.text.isNotEmpty;
    final hasWeight = _weightAvgController.text.isNotEmpty;
    final hasEggs = _eggsController.text.isNotEmpty;

    if (!hasMortality && !hasFeed && !hasWeight && !hasEggs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least one field')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final animalService = ref.read(animalServiceProvider);

      if (widget.isEditMode) {
        await animalService.updateDailyRecord(
          widget.farmId,
          widget.animalId,
          widget.existingRecord!.id,
          mortalityCount: hasMortality ? int.parse(_mortalityController.text) : 0,
          mortalityReason: _mortalityNotesController.text.trim().isEmpty
              ? null
              : _mortalityNotesController.text.trim(),
          feedConsumedKg: hasFeed ? double.parse(_feedController.text) : null,
          sampleCount: _weightSampleController.text.isNotEmpty
              ? int.parse(_weightSampleController.text)
              : null,
          sampleWeightKg:
              hasWeight ? double.parse(_weightAvgController.text) : null,
          eggsCollected: hasEggs ? int.parse(_eggsController.text) : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await animalService.createDailyRecord(
          widget.farmId,
          widget.animalId,
          recordDate: _recordDate,
          mortalityCount:
              hasMortality ? int.parse(_mortalityController.text) : null,
          mortalityReason: _mortalityNotesController.text.trim().isEmpty
              ? null
              : _mortalityNotesController.text.trim(),
          feedConsumedKg: hasFeed ? double.parse(_feedController.text) : null,
          sampleCount: _weightSampleController.text.isNotEmpty
              ? int.parse(_weightSampleController.text)
              : null,
          sampleWeightKg:
              hasWeight ? double.parse(_weightAvgController.text) : null,
          eggsCollected: hasEggs ? int.parse(_eggsController.text) : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditMode ? 'Record updated' : 'Record saved'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: const Icon(Icons.close,
                    color: AppColors.textPrimary, size: 20),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.isEditMode ? 'Edit Record' : 'Daily Record',
          style: const TextStyle(
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
            // Animal context
            Center(
              child: Text(
                widget.animalName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Day ${widget.currentDay}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            _divider(),

            // ── DATE ──
            _sectionHeader('Date'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_recordDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textTertiary, size: 22),
                  ],
                ),
              ),
            ),

            _divider(),

            // ── MORTALITY ──
            _sectionHeader('Mortality'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _input(
                    controller: _mortalityController,
                    hint: '0',
                    label: 'Deaths',
                    isNumber: true,
                    digitsOnly: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _input(
                    controller: _mortalityNotesController,
                    hint: 'Cause (optional)',
                    label: 'Notes',
                  ),
                ),
              ],
            ),

            _divider(),

            // ── FEED ──
            _sectionHeader('Feed'),
            const SizedBox(height: 10),
            _input(
              controller: _feedController,
              hint: '0.0',
              label: 'Feed consumed',
              suffix: 'kg',
              isNumber: true,
              allowDecimal: true,
            ),

            _divider(),

            // ── WEIGHT ──
            _sectionHeader('Weight Sampling'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _input(
                    controller: _weightSampleController,
                    hint: '10',
                    label: 'Sample size',
                    isNumber: true,
                    digitsOnly: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _input(
                    controller: _weightAvgController,
                    hint: '0.00',
                    label: 'Avg weight',
                    suffix: 'kg',
                    isNumber: true,
                    allowDecimal: true,
                  ),
                ),
              ],
            ),

            // ── EGGS (layers only) ──
            if (widget.isLayer) ...[
              _divider(),
              _sectionHeader('Egg Collection'),
              const SizedBox(height: 10),
              _input(
                controller: _eggsController,
                hint: '0',
                label: 'Eggs collected',
                isNumber: true,
                digitsOnly: true,
              ),
            ],

            _divider(),

            // ── NOTES ──
            _sectionHeader('Notes'),
            const SizedBox(height: 10),
            _input(
              controller: _notesController,
              hint: 'Any observations...',
              maxLines: 3,
            ),

            const SizedBox(height: 36),

            // ── SAVE ──
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
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : Text(
                        widget.isEditMode ? 'Update Record' : 'Save Record',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

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

  Widget _input({
    required TextEditingController controller,
    String? hint,
    String? label,
    String? suffix,
    bool isNumber = false,
    bool digitsOnly = false,
    bool allowDecimal = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? (allowDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [
              if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
              if (allowDecimal)
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ]
          : null,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        suffixText: suffix,
        suffixStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
