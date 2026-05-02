import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/animal_provider.dart';
import '../../data/providers/farm_provider.dart';
import '../../data/models/animal.dart';
import 'animal_detail_screen.dart';
import 'add_animal_screen.dart';
import 'add_record_screen.dart';
import 'scan_qr_screen.dart';

const _navy = AppColors.primary;
const _navyLight = Color(0xFF2D2380);
const _bg = AppColors.background;
const _textDark = AppColors.textPrimary;
const _textMuted = AppColors.textSecondary;

enum AnimalFilter { active, past }

final animalFilterProvider = StateProvider<AnimalFilter>((ref) => AnimalFilter.active);

class AnimalsScreen extends ConsumerStatefulWidget {
  const AnimalsScreen({super.key});

  @override
  ConsumerState<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends ConsumerState<AnimalsScreen> {
  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);
    final selectedFarm = ref.watch(selectedFarmProvider);
    final filter = ref.watch(animalFilterProvider);
    final activeAnimals = animalsState.activeAnimals;
    final pastAnimals = animalsState.pastAnimals;
    final filteredAnimals = filter == AnimalFilter.active
        ? activeAnimals
        : pastAnimals;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _navy,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.read(animalsProvider.notifier).loadAnimals();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: Column(
              children: [
                // ════════════════════════════════════════════
                // NAVY HEADER (matching home screen)
                // ════════════════════════════════════════════
                Container(
                  color: _navy,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: SizedBox(
                        height: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Farm selector (centered)
                          Center(
                            child: GestureDetector(
                              onTap: () => _showFarmPicker(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _navyLight,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 200),
                                      child: Text(
                                        selectedFarm?.name ?? 'Select Farm',
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Animals',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                ),

                // ── Content (light background) ──
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 200),
                  child: Container(
                    color: _bg,
                    child: Column(
                      children: [

                // ── Quick actions (floating over navy) ──
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickAction(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Add\nAnimal',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AddAnimalScreen())),
                      ),
                      _QuickAction(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan\nQR',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ScanQrScreen())),
                      ),
                    ],
                  ),
                  ),
                ),

                // ── Filter tabs ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _FilterTabs(
                    activeCount: activeAnimals.length,
                    pastCount: pastAnimals.length,
                    selectedFilter: filter,
                    onFilterChanged: (f) =>
                        ref.read(animalFilterProvider.notifier).state = f,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Animal list ──
                if (animalsState.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  )
                else if (filteredAnimals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(
                          filter == AnimalFilter.active
                              ? Icons.inventory_2_outlined
                              : Icons.check_circle_outline,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          filter == AnimalFilter.active
                              ? 'No active animals'
                              : 'No past animals',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filter == AnimalFilter.active
                              ? 'Add animals to begin tracking'
                              : 'Past animals will appear here',
                          style: const TextStyle(fontSize: 13, color: _textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: filteredAnimals
                          .map((animal) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ActiveAnimalCard(
                                  animal: animal,
                                  onTap: () => _navigateToAnimal(animal),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                const SizedBox(height: 100),

                      ],
                    ),
                  ),
                ), // end light background

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddRecord() {
    final selectedFarm = ref.read(selectedFarmProvider);
    final activeAnimals = ref.read(animalsProvider).activeAnimals;

    if (selectedFarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farm first')),
      );
      return;
    }
    if (activeAnimals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active animals to record for')),
      );
      return;
    }
    if (activeAnimals.length == 1) {
      final animal = activeAnimals.first;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => AddRecordScreen(
          farmId: selectedFarm.id,
          animalId: animal.id,
          animalName: animal.displayName,
          currentDay: animal.daysElapsed,
          isLayer: animal.category?.name.toLowerCase().contains('layer') ?? false,
        ),
      ));
      return;
    }
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
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Animal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            ...activeAnimals.map((animal) => ListTile(
              title: Text(animal.displayName),
              subtitle: Text('Day ${animal.daysElapsed} · ${animal.category?.name ?? ''}',
                  style: const TextStyle(fontSize: 13, color: _textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AddRecordScreen(
                    farmId: selectedFarm.id,
                    animalId: animal.id,
                    animalName: animal.displayName,
                    currentDay: animal.daysElapsed,
                    isLayer: animal.category?.name.toLowerCase().contains('layer') ?? false,
                  ),
                ));
              },
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _navigateToAnimal(Animal animal) async {
    final selectedFarm = ref.read(selectedFarmProvider);
    if (selectedFarm != null) {
      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AnimalDetailScreen(
            farmId: selectedFarm.id,
            animalId: animal.id,
            animalName: animal.displayName,
            categoryName: animal.category?.name,
            breedName: animal.breed?.name,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
      if (result == true || result == null) {
        ref.read(animalsProvider.notifier).loadAnimals();
      }
    }
  }

  void _showFarmPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final farms = ref.watch(farmsProvider).farms;
          final currentFarm = ref.watch(selectedFarmProvider);
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Select Farm',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ...farms.map((farm) => ListTile(
                      title: Text(farm.name),
                      subtitle: farm.locationString.isNotEmpty
                          ? Text(farm.locationString,
                              style: const TextStyle(fontSize: 13, color: _textMuted))
                          : null,
                      trailing: farm.id == currentFarm?.id
                          ? const Icon(Icons.check, size: 18, color: _navy)
                          : null,
                      onTap: () {
                        ref.read(selectedFarmIdProvider.notifier).state = farm.id;
                        Navigator.pop(sheetContext);
                      },
                    )),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// ACTIVE ANIMAL CARD
// =============================================================================

class _ActiveAnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;

  const _ActiveAnimalCard({required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryName = animal.category?.name ?? 'Animal';
    final initialQty = animal.initialQuantity ?? 0;
    final mortalityCount = (animal.currentQuantity != null && animal.currentQuantity! < initialQty)
        ? initialQty - animal.currentQuantity!
        : 0;
    final mortalityRate = initialQty > 0 ? (mortalityCount / initialQty * 100) : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: badges + name + breed
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: animal.isActive ? AppColors.animalActive : AppColors.animalInactive,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              categoryName.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'DAY ${animal.daysElapsed}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textDark, letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    animal.displayName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (animal.breed != null) ...[
                    const SizedBox(height: 2),
                    Text(animal.breed!.name, style: const TextStyle(fontSize: 12, color: _textMuted)),
                  ],
                ],
              ),
            ),
            // Right: stats + chevron (full height)
            _StatCol(label: 'Alive', value: '${animal.headCount}/${animal.initialQuantity ?? '-'}'),
            const SizedBox(width: 16),
            _StatCol(
              label: 'Mortality',
              value: mortalityRate > 0 ? '${mortalityRate.toStringAsFixed(1)}%' : '0%',
              valueColor: mortalityRate > 5 ? AppColors.error : null,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FILTER TABS
// =============================================================================

class _FilterTabs extends StatelessWidget {
  final int activeCount;
  final int pastCount;
  final AnimalFilter selectedFilter;
  final ValueChanged<AnimalFilter> onFilterChanged;

  const _FilterTabs({
    required this.activeCount,
    required this.pastCount,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              label: 'Active',
              count: activeCount,
              isSelected: selectedFilter == AnimalFilter.active,
              onTap: () => onFilterChanged(AnimalFilter.active),
            ),
          ),
          Expanded(
            child: _FilterTab(
              label: 'Past',
              count: pastCount,
              isSelected: selectedFilter == AnimalFilter.past,
              onTap: () => onFilterChanged(AnimalFilter.past),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      elevation: isSelected ? 1 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? _textDark : _textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// STAT COLUMN (compact inline stat)
// =============================================================================

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCol({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor ?? _textDark)),
      ],
    );
  }
}

// =============================================================================
// QUICK ACTION
// =============================================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _navy, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textDark, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
