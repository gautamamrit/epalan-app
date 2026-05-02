import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/animal.dart';
import '../../data/providers/animal_provider.dart';
import '../../data/providers/livestock_provider.dart';
import '../../data/models/livestock.dart';

class AddAnimalScreen extends ConsumerStatefulWidget {
  final Animal? existingAnimal;

  const AddAnimalScreen({super.key, this.existingAnimal});

  bool get isEditMode => existingAnimal != null;

  @override
  ConsumerState<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends ConsumerState<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countController = TextEditingController();
  final _notesController = TextEditingController();
  // Individual fields
  final _tagNumberController = TextEditingController();
  final _shortCodeController = TextEditingController();

  LivestockCategory? _selectedCategory;
  LivestockBreed? _selectedBreed;
  DateTime _startDate = DateTime.now();
  DateTime? _dateOfBirth;
  String _sourceType = 'hatchery';
  String? _sex;
  bool _isSubmitting = false;

  bool get _isIndividual => _selectedCategory?.isIndividual ?? false;

  final List<Map<String, String>> _sourceTypes = [
    {'value': 'hatchery', 'label': 'Hatchery'},
    {'value': 'farm_transfer', 'label': 'Farm Transfer'},
    {'value': 'purchase', 'label': 'Purchase'},
    {'value': 'breeding', 'label': 'Breeding'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    final animal = widget.existingAnimal;
    if (animal != null) {
      _nameController.text = animal.name ?? '';
      _countController.text = animal.initialQuantity != null ? '${animal.initialQuantity}' : '';
      _notesController.text = animal.sourceNotes ?? '';
      _tagNumberController.text = animal.tagNumber ?? '';
      _shortCodeController.text = animal.shortCode ?? '';
      _sourceType = animal.sourceType ?? 'hatchery';
      _startDate = animal.startDate;
      _dateOfBirth = animal.dateOfBirth;
      _sex = animal.sex;
      if (animal.category != null) {
        _selectedCategory = LivestockCategory(
          id: animal.categoryId,
          name: animal.category!.name,
          subtypeId: animal.category!.subtypeId,
          managedAs: animal.category!.managedAs,
          isActive: true,
        );
      }
      if (animal.breed != null && animal.breedId != null) {
        _selectedBreed = LivestockBreed(
          id: animal.breedId!,
          name: animal.breed!.name,
          categoryId: animal.categoryId,
          isActive: true,
        );
      }
    }
    Future.microtask(() {
      ref.read(categoriesProvider.notifier).loadCategories();
      if (animal?.categoryId != null) {
        ref.read(breedsProvider.notifier).loadBreeds(animal!.categoryId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _notesController.dispose();
    _tagNumberController.dispose();
    _shortCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initial = isStartDate ? _startDate : (_dateOfBirth ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now()) ? DateTime.now() : initial,
      firstDate: DateTime(2000),
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
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _dateOfBirth = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a livestock type')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.isEditMode) {
        final animalService = ref.read(animalServiceProvider);
        await animalService.updateAnimal(
          widget.existingAnimal!.farmId,
          widget.existingAnimal!.id,
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          breedId: _selectedBreed?.id,
          initialQuantity: _isIndividual ? null : int.tryParse(_countController.text),
          startDate: _startDate,
          sourceType: _sourceType,
          sourceNotes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Animal updated'),
                backgroundColor: AppColors.primary),
          );
        }
      } else {
        final animal = await ref.read(animalsProvider.notifier).createAnimal(
              categoryId: _selectedCategory!.id,
              breedId: _selectedBreed?.id,
              name: _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
              startDate: _startDate,
              initialQuantity: _isIndividual ? null : int.tryParse(_countController.text),
              tagNumber: _isIndividual && _tagNumberController.text.trim().isNotEmpty
                  ? _tagNumberController.text.trim()
                  : null,
              sex: _isIndividual ? _sex : null,
              dateOfBirth: _isIndividual ? _dateOfBirth : null,
              shortCode: _shortCodeController.text.trim().isNotEmpty
                  ? _shortCodeController.text.trim()
                  : null,
              sourceType: _sourceType,
              sourceNotes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
        if (animal != null && mounted) {
          Navigator.pop(context, animal);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Animal created'),
                backgroundColor: AppColors.primary),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final breedsState = ref.watch(breedsProvider);

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
        title: Text(
          widget.isEditMode ? 'Edit Animal' : 'New Animal',
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
            // ── Livestock Type ──
            _sectionHeader('Livestock Type'),
            const SizedBox(height: 12),
            if (categoriesState.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ))
            else
              _pickerRow(
                label: _selectedCategory?.name ?? 'Select type',
                isPlaceholder: _selectedCategory == null,
                onTap: widget.isEditMode ? null : () => _showCategoryPicker(categoriesState.categories),
              ),

            _divider(),

            // ── Breed ──
            if (_selectedCategory != null) ...[
              _sectionHeader('Breed'),
              const SizedBox(height: 12),
              if (breedsState.isLoading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ))
              else if (breedsState.breeds.isEmpty)
                _pickerRow(
                  label: 'No breeds available',
                  isPlaceholder: true,
                  onTap: null,
                )
              else
                _pickerRow(
                  label: _selectedBreed?.name ?? 'Not specified',
                  isPlaceholder: _selectedBreed == null,
                  onTap: () => _showBreedPicker(breedsState.breeds),
                ),
              _divider(),
            ],

            // ── Animal Name ──
            _sectionHeader(_isIndividual ? 'Name' : 'Animal Name'),
            const SizedBox(height: 8),
            _textInput(
              controller: _nameController,
              hint: _isIndividual ? 'e.g., Lakshmi' : 'e.g., Spring 2026 Broilers',
            ),

            _divider(),

            // ── Individual: Tag Number + Sex ──
            if (_isIndividual) ...[
              _sectionHeader('Tag Number'),
              const SizedBox(height: 8),
              _textInput(
                controller: _tagNumberController,
                hint: 'e.g., EAR-0042',
              ),

              _divider(),

              _sectionHeader('Sex'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    label: 'Male',
                    isSelected: _sex == 'male',
                    onTap: () => setState(() => _sex = 'male'),
                  ),
                  _chip(
                    label: 'Female',
                    isSelected: _sex == 'female',
                    onTap: () => setState(() => _sex = 'female'),
                  ),
                ],
              ),

              _divider(),

              _sectionHeader('Date of Birth'),
              const SizedBox(height: 12),
              _pickerRow(
                label: _dateOfBirth != null
                    ? _formatDate(_dateOfBirth!)
                    : 'Not specified',
                isPlaceholder: _dateOfBirth == null,
                onTap: () => _selectDate(isStartDate: false),
              ),

              _divider(),
            ],

            // ── Group: Initial Quantity ──
            if (!_isIndividual) ...[
              _sectionHeader('Initial Quantity'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Number of animals',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (!_isIndividual) {
                    if (value == null || value.isEmpty) return 'Required';
                    final count = int.tryParse(value);
                    if (count == null || count <= 0) return 'Must be positive';
                  }
                  return null;
                },
              ),

              _divider(),
            ],

            // ── Start Date ──
            _sectionHeader(_isIndividual ? 'Tracking Start Date' : 'Start Date'),
            const SizedBox(height: 12),
            _pickerRow(
              label: _formatDate(_startDate),
              onTap: () => _selectDate(isStartDate: true),
            ),

            _divider(),

            // ── Source ──
            _sectionHeader('Source'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sourceTypes
                  .map((s) => _chip(
                        label: s['label']!,
                        isSelected: _sourceType == s['value'],
                        onTap: () =>
                            setState(() => _sourceType = s['value']!),
                      ))
                  .toList(),
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
                    : Text(
                        widget.isEditMode ? 'Save Changes' : 'Create Animal',
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

  // ── Shared helpers ──

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

  Widget _pickerRow({
    required String label,
    bool isPlaceholder = false,
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      isPlaceholder ? AppColors.textTertiary : AppColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
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

  void _showCategoryPicker(List<LivestockCategory> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Livestock Type',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: categories.map((cat) => ListTile(
                  title: Text(cat.name),
                  subtitle: Text(
                    cat.isIndividual ? 'Individual tracking' : 'Group tracking',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  trailing: _selectedCategory?.id == cat.id
                      ? const Icon(Icons.check, size: 20, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      _selectedBreed = null;
                    });
                    ref.read(breedsProvider.notifier).loadBreeds(cat.id);
                    Navigator.pop(ctx);
                  },
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showBreedPicker(List<LivestockBreed> breeds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Breed',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            ListTile(
              title: const Text('Not specified'),
              trailing: _selectedBreed == null
                  ? const Icon(Icons.check, size: 20, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedBreed = null);
                Navigator.pop(ctx);
              },
            ),
            ...breeds.map((breed) => ListTile(
                  title: Text(breed.name),
                  trailing: _selectedBreed?.id == breed.id
                      ? const Icon(Icons.check, size: 20, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedBreed = breed);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
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
