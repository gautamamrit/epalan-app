import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/animal_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/farm_provider.dart';
import '../../home/home_screen.dart';
import '../../animals/animals_screen.dart';
import '../../market_prices/market_prices_screen.dart';
import '../../../l10n/app_localizations.dart';
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
        ref.read(alertsProvider.notifier).loadAlerts(farmId: next);
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
      ),
    );
  }

}

/// Custom bottom navigation bar with modern styling
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
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
              Builder(builder: (ctx) {
                final l10n = AppLocalizations.of(ctx);
                return _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                  label: l10n.home, isSelected: currentIndex == 0, onTap: () => onTap(0));
              }),
              Builder(builder: (ctx) {
                final l10n = AppLocalizations.of(ctx);
                return _NavItem(icon: Icons.pets_outlined, activeIcon: Icons.pets_rounded,
                  label: l10n.animals, isSelected: currentIndex == 1, onTap: () => onTap(1));
              }),
              Builder(builder: (ctx) {
                final l10n = AppLocalizations.of(ctx);
                return _NavItem(icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up_rounded,
                  label: l10n.prices, isSelected: currentIndex == 2, onTap: () => onTap(2));
              }),
              Builder(builder: (ctx) {
                final l10n = AppLocalizations.of(ctx);
                return _NavItem(icon: Icons.menu_rounded, activeIcon: Icons.menu_rounded,
                  label: l10n.more, isSelected: currentIndex == 3, onTap: () => onTap(3));
              }),
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
