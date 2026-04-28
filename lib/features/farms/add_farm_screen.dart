import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/farm_provider.dart';
import '../../data/providers/livestock_provider.dart';
import '../../data/models/livestock.dart';
import '../../data/services/location_service.dart';

class AddFarmScreen extends ConsumerStatefulWidget {
  const AddFarmScreen({super.key});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  final _locationService = LocationService();

  List<LocationProvince> _provinces = [];
  List<LocationDistrict> _districts = [];
  LocationProvince? _selectedProvince;
  LocationDistrict? _selectedDistrict;
  bool _loadingProvinces = true;
  bool _loadingDistricts = false;

  final Set<String> _selectedTypeIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    Future.microtask(() => ref.read(livestockTypesProvider.future));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _locationService.getProvinces();
      if (mounted) {
        setState(() {
          _provinces = provinces;
          _loadingProvinces = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingProvinces = false);
      }
    }
  }

  Future<void> _selectProvince(LocationProvince province) async {
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;
      _districts = [];
      _loadingDistricts = true;
    });
    try {
      final districts = await _locationService.getDistricts(provinceId: province.id);
      if (mounted) {
        setState(() {
          _districts = districts;
          _loadingDistricts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingDistricts = false);
      }
    }
  }

  void _showProvincePicker() {
    if (_loadingProvinces) return;
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
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Province',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _provinces
                    .map((p) => ListTile(
                          title: Text(p.name),
                          trailing: _selectedProvince?.id == p.id
                              ? const Icon(Icons.check,
                                  size: 18, color: AppColors.primary)
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            _selectProvince(p);
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDistrictPicker() {
    if (_loadingDistricts || _selectedProvince == null || _districts.isEmpty) return;
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
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select District',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _districts
                    .map((d) => ListTile(
                          title: Text(d.name),
                          trailing: _selectedDistrict?.id == d.id
                              ? const Icon(Icons.check,
                                  size: 18, color: AppColors.primary)
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() => _selectedDistrict = d);
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a province')));
      return;
    }
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a district')));
      return;
    }
    if (_selectedTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one livestock type')));
      return;
    }

    setState(() => _isSubmitting = true);

    final farm = await ref.read(farmsProvider.notifier).createFarm(
          name: _nameController.text.trim(),
          countryId: 1,
          provinceId: _selectedProvince!.id,
          districtId: _selectedDistrict!.id,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          livestockTypes:
              _selectedTypeIds.map((id) => {'livestockTypeId': id}).toList(),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (farm != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${farm.name}" added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(farmsProvider).error ?? 'Failed to create farm';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(livestockTypesProvider);

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
        title: const Text(
          'New Farm',
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
            // ── Farm Name ──────────────────────────────────────────────
            _sectionHeader('Farm Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Thapa Poultry Farm',
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),

            _divider(),

            // ── Address ────────────────────────────────────────────────
            _sectionHeader('Address'),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Optional — street or village name',
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
            ),

            _divider(),

            // ── Province ───────────────────────────────────────────────
            _sectionHeader('Province'),
            const SizedBox(height: 12),
            _pickerRow(
              label: _loadingProvinces
                  ? 'Loading...'
                  : (_selectedProvince?.name ?? 'Select province'),
              isPlaceholder: _selectedProvince == null,
              showSpinner: _loadingProvinces,
              onTap: _showProvincePicker,
            ),

            _divider(),

            // ── District ───────────────────────────────────────────────
            _sectionHeader('District'),
            const SizedBox(height: 12),
            _pickerRow(
              label: _loadingDistricts
                  ? 'Loading...'
                  : _selectedProvince == null
                      ? 'Select a province first'
                      : (_selectedDistrict?.name ?? 'Select district'),
              isPlaceholder: _selectedDistrict == null,
              showSpinner: _loadingDistricts,
              onTap: _selectedProvince != null && !_loadingDistricts
                  ? _showDistrictPicker
                  : null,
            ),

            _divider(),

            // ── Livestock Types ────────────────────────────────────────
            _sectionHeader('Livestock Types'),
            const SizedBox(height: 4),
            const Text(
              'Select all types you will manage on this farm',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            typesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
              error: (_, __) => const Text(
                'Failed to load livestock types',
                style: TextStyle(color: AppColors.error),
              ),
              data: (types) => Column(
                children: types.asMap().entries.map((entry) {
                  final i = entry.key;
                  final type = entry.value;
                  final selected = _selectedTypeIds.contains(type.id);
                  return Column(
                    children: [
                      if (i > 0)
                        const Divider(color: AppColors.border, height: 1),
                      _LivestockTypeRow(
                        type: type,
                        selected: selected,
                        onChanged: (val) => setState(() {
                          if (val) {
                            _selectedTypeIds.add(type.id);
                          } else {
                            _selectedTypeIds.remove(type.id);
                          }
                        }),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            _divider(),

            // ── Submit ─────────────────────────────────────────────────
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
                        'Add Farm',
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

  Widget _pickerRow({
    required String label,
    bool isPlaceholder = false,
    bool showSpinner = false,
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
                  color: isPlaceholder
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (showSpinner)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.textTertiary),
              )
            else if (onTap != null)
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _LivestockTypeRow extends StatelessWidget {
  final LivestockType type;
  final bool selected;
  final void Function(bool) onChanged;

  const _LivestockTypeRow({
    required this.type,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (type.nameNe != null)
                    Text(
                      type.nameNe!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
