import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_form_fields.dart';
import '../../data/models/farm.dart';
import '../../data/providers/farm_provider.dart';
import '../../data/providers/livestock_provider.dart';
import '../../data/models/livestock.dart';
import '../../data/services/location_service.dart';

class EditFarmScreen extends ConsumerStatefulWidget {
  final Farm farm;
  const EditFarmScreen({super.key, required this.farm});

  @override
  ConsumerState<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends ConsumerState<EditFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  final _locationService = LocationService();

  List<LocationProvince> _provinces = [];
  List<LocationDistrict> _districts = [];
  LocationProvince? _selectedProvince;
  LocationDistrict? _selectedDistrict;
  bool _loadingProvinces = true;
  bool _loadingDistricts = false;

  late Set<String> _selectedTypeIds;
  late Set<String> _initialTypeIds;
  bool _isSubmitting = false;

  bool get _hasChanges {
    return _nameController.text.trim() != widget.farm.name ||
        _addressController.text.trim() != (widget.farm.address ?? '') ||
        _selectedProvince?.id != widget.farm.provinceId ||
        _selectedDistrict?.id != widget.farm.districtId ||
        !_setEquals(_selectedTypeIds, _initialTypeIds);
  }

  static bool _setEquals(Set<String> a, Set<String> b) {
    return a.length == b.length && a.containsAll(b);
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farm.name);
    _addressController =
        TextEditingController(text: widget.farm.address ?? '');

    _nameController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);

    // Pre-select existing livestock types
    _initialTypeIds = widget.farm.livestockTypes
            ?.map((lt) => lt.livestockTypeId)
            .toSet() ??
        {};
    _selectedTypeIds = Set.from(_initialTypeIds);

    _loadProvinces();
    Future.microtask(() => ref.read(livestockTypesProvider.future));
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _addressController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _locationService.getProvinces();
      if (!mounted) return;

      // Find the province matching the farm's provinceId
      final matchedProvince = provinces
          .where((p) => p.id == widget.farm.provinceId)
          .firstOrNull;

      setState(() {
        _provinces = provinces;
        _selectedProvince = matchedProvince;
        _loadingProvinces = false;
      });

      if (matchedProvince != null) {
        await _loadDistricts(matchedProvince, preselect: widget.farm.districtId);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProvinces = false);
    }
  }

  Future<void> _loadDistricts(LocationProvince province,
      {int? preselect}) async {
    setState(() {
      _loadingDistricts = true;
      _districts = [];
      if (preselect == null) _selectedDistrict = null;
    });
    try {
      final districts =
          await _locationService.getDistricts(provinceId: province.id);
      if (!mounted) return;
      setState(() {
        _districts = districts;
        _loadingDistricts = false;
        if (preselect != null) {
          _selectedDistrict =
              districts.where((d) => d.id == preselect).firstOrNull;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingDistricts = false);
    }
  }

  Future<void> _selectProvince(LocationProvince province) async {
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;
    });
    await _loadDistricts(province);
  }

  void _showProvincePicker() {
    if (_loadingProvinces) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Province',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
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
    if (_loadingDistricts || _selectedProvince == null || _districts.isEmpty)
      return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select District',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a province')));
      return;
    }
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a district')));
      return;
    }
    if (_selectedTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select at least one livestock type')));
      return;
    }

    setState(() => _isSubmitting = true);

    final farmId = widget.farm.id;
    final notifier = ref.read(farmsProvider.notifier);

    // 1. Update basic farm fields
    final ok = await notifier.updateFarm(
      farmId,
      name: _nameController.text.trim(),
      provinceId: _selectedProvince!.id,
      districtId: _selectedDistrict!.id,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
    );

    if (!ok || !mounted) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final error =
            ref.read(farmsProvider).error ?? 'Failed to update farm';
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppColors.error));
      }
      return;
    }

    // 2. Handle livestock type changes
    final added = _selectedTypeIds.difference(_initialTypeIds).toList();
    final removed = _initialTypeIds.difference(_selectedTypeIds);

    if (added.isNotEmpty) {
      await notifier.addLivestockTypes(farmId, added);
    }

    // For removed types, find the FarmLivestockType.id (not livestockTypeId)
    for (final removedTypeId in removed) {
      final flt = widget.farm.livestockTypes
          ?.where((lt) => lt.livestockTypeId == removedTypeId)
          .firstOrNull;
      if (flt != null) {
        await notifier.removeLivestockType(farmId, flt.id);
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_nameController.text.trim()}" updated'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
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
          'Edit Farm',
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
            const AppSectionHeader('Farm Name'),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              label: 'Farm Name',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),

            const AppFormDivider(),

            const AppSectionHeader('Address'),
            const SizedBox(height: 8),
            AppTextField(
              controller: _addressController,
              label: 'Address',
            ),

            const AppFormDivider(),

            const AppSectionHeader('Province'),
            const SizedBox(height: 12),
            _pickerRow(
              label: _loadingProvinces
                  ? 'Loading...'
                  : (_selectedProvince?.name ?? 'Select province'),
              isPlaceholder: _selectedProvince == null,
              showSpinner: _loadingProvinces,
              onTap: _showProvincePicker,
            ),

            const AppFormDivider(),

            const AppSectionHeader('District'),
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

            const AppFormDivider(),

            const AppSectionHeader('Livestock Types'),
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
              error: (_, __) => const Text('Failed to load livestock types',
                  style: TextStyle(color: AppColors.error)),
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

            const AppFormDivider(),

            AppPrimaryButton(
              label: 'Save Changes',
              isLoading: _isSubmitting,
              onPressed: _hasChanges ? _submit : null,
            ),
          ],
        ),
      ),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isPlaceholder
                          ? AppColors.textTertiary
                          : AppColors.textPrimary)),
            ),
            if (showSpinner)
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textTertiary))
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

  const _LivestockTypeRow(
      {required this.type,
      required this.selected,
      required this.onChanged});

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
                  Text(type.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  if (type.nameNe != null)
                    Text(type.nameNe!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
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
                    color:
                        selected ? AppColors.primary : AppColors.border,
                    width: 1.5),
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
