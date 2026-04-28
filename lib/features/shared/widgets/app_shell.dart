import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/animal_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/farm_provider.dart';
import '../../home/home_screen.dart';
import '../../animals/animals_screen.dart';
import '../../animals/add_animal_screen.dart';
import '../../animals/add_record_screen.dart';
import '../../market_prices/market_prices_screen.dart';
import '../../more/more_screen.dart';

/// Provider for the current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main app shell with bottom navigation
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load only what Home tab needs — other tabs load on switch
    Future.microtask(() async {
      await ref.read(farmsProvider.notifier).loadFarms();
      final farms = ref.read(farmsProvider).farms;
      if (ref.read(selectedFarmIdProvider) == null && farms.isNotEmpty) {
        ref.read(selectedFarmIdProvider.notifier).state = farms.first.id;
      }
      ref.read(animalsProvider.notifier).loadAnimals();
      ref.read(alertsProvider.notifier).loadAlerts();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  void _refreshAll() {
    ref.read(farmsProvider.notifier).loadFarms(refresh: true);
    ref.read(animalsProvider.notifier).loadAnimals();
    ref.read(alertsProvider.notifier).loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    // Reload animals & alerts when selected farm changes
    ref.listen(selectedFarmIdProvider, (prev, next) {
      if (prev != next && next != null) {
        ref.read(animalsProvider.notifier).loadAnimals(farmId: next);
        ref.read(alertsProvider.notifier).loadAlerts();
      }
    });

    final user = ref.watch(currentUserProvider);
    final isPending = user != null && user.status != 'verified';
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: Column(
        children: [
          if (isPending)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 8),
              color: AppColors.warning,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your account is pending approval. Some features are limited.',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: const [
                HomeScreen(),
                AnimalsScreen(),
                MarketPricesScreen(),
                MoreScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          ref.read(navigationIndexProvider.notifier).state = index;
          // Refresh data when switching tabs
          if (index == 0) {
            ref.read(farmsProvider.notifier).loadFarms(refresh: true);
            ref.read(animalsProvider.notifier).loadAnimals();
            ref.read(alertsProvider.notifier).loadAlerts();
          } else if (index == 1) {
            ref.read(animalsProvider.notifier).loadAnimals();
          }
        },
        onAddTap: isPending || ref.read(farmsProvider).farms.isEmpty
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isPending
                        ? 'Account pending approval'
                        : 'Please create a farm first'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            : _handleAddTap,
      ),
    );
  }

  void _handleAddTap() {
    final selectedFarm = ref.read(selectedFarmProvider);
    final activeAnimals = ref.read(animalsProvider).activeAnimals;

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
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded,
                    color: AppColors.primary, size: 22),
              ),
              title: const Text('Add Daily Record',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Log mortality, feed, weight',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToAddRecord(selectedFarm, activeAnimals);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_box_rounded,
                    color: AppColors.primary, size: 22),
              ),
              title: const Text('New Animal',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Start tracking a new animal group',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAnimalScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToAddRecord(dynamic selectedFarm, List activeAnimals) {
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
      // Go directly to add record
      final animal = activeAnimals.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddRecordScreen(
            farmId: selectedFarm.id,
            animalId: animal.id,
            animalName: animal.displayName,
            currentDay: animal.daysElapsed,
            isLayer: animal.category?.name.toLowerCase().contains('layer') ?? false,
          ),
        ),
      );
      return;
    }

    // Multiple animals — show picker
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
                'Select Animal',
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
                children: activeAnimals.map((animal) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'D${animal.daysElapsed}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  title: Text(animal.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    '${animal.category?.name ?? ''} · ${animal.headCount} head',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRecordScreen(
                          farmId: selectedFarm.id,
                          animalId: animal.id,
                          animalName: animal.displayName,
                          currentDay: animal.daysElapsed,
                          isLayer: animal.category?.name
                                  .toLowerCase()
                                  .contains('layer') ??
                              false,
                        ),
                      ),
                    );
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
}

/// Custom bottom navigation bar with modern styling
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.pets_outlined,
                activeIcon: Icons.pets_rounded,
                label: 'Animals',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // Center add button
              Expanded(
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2D2380), Color(0xFF1B1464)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront_rounded,
                label: 'Prices',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.menu_rounded,
                activeIcon: Icons.menu_rounded,
                label: 'More',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    widget.isSelected ? widget.activeIcon : widget.icon,
                    key: ValueKey(widget.isSelected),
                    color: widget.isSelected ? AppColors.primary : AppColors.inactiveTab,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: widget.isSelected ? AppColors.primary : AppColors.inactiveTab,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
