import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/animal_provider.dart';
import '../../../data/providers/farm_provider.dart';
import '../../alerts/alerts_screen.dart';

/// Common app bar with ePalan logo, farm selector, and alerts bell
class EPalanAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const EPalanAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: _EPalanLogo(),
      ),
      actions: const [
        // Farm Selector Chip
        _FarmSelectorChip(),
        SizedBox(width: 8),
        // Alerts Bell
        _AlertsBell(),
        SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.border,
        ),
      ),
    );
  }
}

/// ePalan logo widget - clean and modern
class _EPalanLogo extends StatelessWidget {
  const _EPalanLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon with gradient-like effect
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.spa_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        // Brand name with subtle styling
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
          ).createShader(bounds),
          child: const Text(
            'ePalan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Farm selector chip - compact and tappable
class _FarmSelectorChip extends ConsumerStatefulWidget {
  const _FarmSelectorChip();

  @override
  ConsumerState<_FarmSelectorChip> createState() => _FarmSelectorChipState();
}

class _FarmSelectorChipState extends ConsumerState<_FarmSelectorChip> {
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
    final hasError = farmsState.error != null;

    return GestureDetector(
      onTap: () => _showFarmPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasError ? AppColors.error.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasError ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (farmsState.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              Icon(
                hasError ? Icons.error_outline : Icons.location_on,
                size: 16,
                color: hasError ? AppColors.error : AppColors.primary,
              ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                farmsState.isLoading ? 'Loading...' : displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: hasError ? AppColors.error : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showFarmPicker(BuildContext context) {
    // Try reloading farms when opening picker
    ref.read(farmsProvider.notifier).loadFarms();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Use Consumer to make the sheet reactive
        return Consumer(
          builder: (context, ref, _) {
            final farmsState = ref.watch(farmsProvider);
            final farms = farmsState.farms;
            final currentFarm = ref.watch(selectedFarmProvider);

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Farm',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (farmsState.isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () {
                              ref.read(farmsProvider.notifier).loadFarms();
                            },
                            tooltip: 'Refresh farms',
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Error state
                  if (farmsState.error != null && farms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: 8),
                          const Text(
                            'Failed to load farms',
                            style: TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              ref.read(farmsProvider.notifier).loadFarms();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // All farms option
                    _FarmOption(
                      title: 'All Farms',
                      subtitle: 'View data from all farms',
                      icon: Icons.apps_rounded,
                      isSelected: currentFarm == null,
                      onTap: () {
                        ref.read(selectedFarmIdProvider.notifier).state = null;
                        Navigator.pop(sheetContext);
                      },
                    ),
                    // Individual farms
                    ...farms.map((farm) => _FarmOption(
                          title: farm.name,
                          subtitle: farm.locationString,
                          icon: Icons.home_work_rounded,
                          isSelected: farm.id == currentFarm?.id,
                          onTap: () {
                            ref.read(selectedFarmIdProvider.notifier).state = farm.id;
                            Navigator.pop(sheetContext);
                          },
                        )),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Farm option in the picker
class _FarmOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FarmOption({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          : null,
      trailing: isSelected
          ? Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Alerts bell with badge
class _AlertsBell extends ConsumerWidget {
  const _AlertsBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsCount = ref.watch(alertsCountProvider);
    final hasAlerts = alertsCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AlertsScreen()),
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: hasAlerts ? AppColors.error.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                hasAlerts ? Icons.notifications_active : Icons.notifications_outlined,
                color: hasAlerts ? AppColors.error : AppColors.textSecondary,
                size: 24,
              ),
              if (hasAlerts)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alertsCount > 99 ? '99+' : alertsCount.toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
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

/// Sliver version of the app bar for CustomScrollView
class EPalanSliverAppBar extends ConsumerWidget {
  final bool floating;
  final bool pinned;

  const EPalanSliverAppBar({
    super.key,
    this.floating = true,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: floating,
      pinned: pinned,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: _EPalanLogo(),
      ),
      actions: const [
        // Farm Selector Chip
        _FarmSelectorChip(),
        SizedBox(width: 8),
        // Alerts Bell
        _AlertsBell(),
        SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.border,
        ),
      ),
    );
  }
}
