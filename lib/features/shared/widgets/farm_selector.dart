import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/farm_provider.dart';
import '../../../data/models/farm.dart';

class FarmSelector extends ConsumerStatefulWidget {
  const FarmSelector({super.key});

  @override
  ConsumerState<FarmSelector> createState() => _FarmSelectorState();
}

class _FarmSelectorState extends ConsumerState<FarmSelector> {
  @override
  void initState() {
    super.initState();
    // Load farms on init
    Future.microtask(() {
      ref.read(farmsProvider.notifier).loadFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final farmsState = ref.watch(farmsProvider);
    final selectedFarm = ref.watch(selectedFarmProvider);

    final displayName = selectedFarm?.name ?? 'All Farms';

    return GestureDetector(
      onTap: () => _showFarmPicker(context, farmsState.farms, selectedFarm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (farmsState.isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showFarmPicker(
    BuildContext context,
    List<Farm> farms,
    Farm? currentFarm,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Farm',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              // All farms option
              ListTile(
                title: const Text('All Farms'),
                trailing: currentFarm == null
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(selectedFarmIdProvider.notifier).state = null;
                  Navigator.pop(context);
                },
              ),
              // Individual farms
              ...farms.map((farm) => ListTile(
                    title: Text(farm.name),
                    subtitle: farm.district != null
                        ? Text(
                            farm.locationString,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          )
                        : null,
                    trailing: farm.id == currentFarm?.id
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(selectedFarmIdProvider.notifier).state = farm.id;
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
