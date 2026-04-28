import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/animal_provider.dart';
import '../../data/providers/farm_provider.dart';
import '../../data/models/animal.dart';
import 'animal_detail_screen.dart';

enum AnimalFilter { active, past }

final animalFilterProvider = StateProvider<AnimalFilter>((ref) => AnimalFilter.active);

class AnimalsScreen extends ConsumerStatefulWidget {
  const AnimalsScreen({super.key});

  @override
  ConsumerState<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends ConsumerState<AnimalsScreen> {
  @override
  void initState() {
    super.initState();
    // Data loading handled by AppShell — no duplicate calls
  }

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.read(animalsProvider.notifier).loadAnimals();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ── Farm selector (centered, like Helen) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _showFarmPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedFarm?.name ?? 'Select Farm',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Title (large, centered like Helen's "Electricity") ──
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Center(
                    child: Text(
                      'Animals',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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

                // ── Animal list (vertical) ──
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filter == AnimalFilter.active
                              ? 'Add animals to begin tracking'
                              : 'Past animals will appear here',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
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
        ),
        ),
    );
  }

  void _navigateToAnimal(Animal animal) async {
    final selectedFarm = ref.read(selectedFarmProvider);
    if (selectedFarm != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimalDetailScreen(
            farmId: selectedFarm.id,
            animalId: animal.id,
          ),
        ),
      );
      // Always refresh on return — data may have changed
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
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Select Farm',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  title: const Text('All Farms'),
                  trailing: currentFarm == null
                      ? const Icon(Icons.check,
                          size: 18, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(selectedFarmIdProvider.notifier).state = null;
                    Navigator.pop(sheetContext);
                  },
                ),
                ...farms.map((farm) => ListTile(
                      title: Text(farm.name),
                      subtitle: farm.locationString.isNotEmpty
                          ? Text(farm.locationString,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary))
                          : null,
                      trailing: farm.id == currentFarm?.id
                          ? const Icon(Icons.check,
                              size: 18, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref.read(selectedFarmIdProvider.notifier).state =
                            farm.id;
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
    final categoryName = animal.category?.name.toUpperCase() ?? 'ANIMAL';
    final isLayer = animal.category?.name.toLowerCase().contains('layer') ?? false;
    final initialQty = animal.initialQuantity ?? 1;
    final hasMortality =
        animal.currentQuantity != null && animal.currentQuantity! < initialQty;
    final mortalityCount =
        hasMortality ? initialQty - animal.currentQuantity! : 0;
    final mortalityRate =
        hasMortality ? (mortalityCount / initialQty * 100) : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: badges + arrow
            Row(
              children: [
                // Status + category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: animal.isActive ? AppColors.animalActive : AppColors.animalInactive,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.primary, letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'DAY ${animal.daysElapsed}',
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    size: 22, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 12),

            // Animal name + breed
            Text(
              animal.displayName,
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (animal.breed != null) ...[
              const SizedBox(height: 3),
              Text(
                animal.breed!.name,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 14),

            // Stats row
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _StatBox(label: 'CURRENT', value: '${animal.headCount}'),
                  Container(width: 1, height: 32, color: AppColors.border),
                  _StatBox(
                    label: 'MORTALITY',
                    value: hasMortality ? '$mortalityCount' : '0',
                    subValue: hasMortality ? '${mortalityRate.toStringAsFixed(1)}%' : null,
                    valueColor: mortalityRate > 5 ? AppColors.error : null,
                  ),
                  Container(width: 1, height: 32, color: AppColors.border),
                  _StatBox(label: isLayer ? 'EGGS' : 'INITIAL', value: '${animal.initialQuantity}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color? valueColor;

  const _StatBox({
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
            if (subValue != null)
              Text(
                subValue!,
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textSecondary,
                ),
              ),
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
        borderRadius: BorderRadius.circular(12),
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
      borderRadius: BorderRadius.circular(10),
      elevation: isSelected ? 1 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
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
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
