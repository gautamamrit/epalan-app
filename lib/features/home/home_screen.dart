import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/animal_provider.dart';
import '../../data/providers/farm_provider.dart';
import '../animals/animal_detail_screen.dart';
import '../animals/scan_qr_screen.dart';
import '../animals/add_animal_screen.dart';
import '../animals/add_record_screen.dart';
import '../alerts/alerts_screen.dart';
import '../shared/widgets/app_shell.dart';
import '../../l10n/app_localizations.dart';

// ── Palette aliases ──
const _navy = AppColors.primary;
const _navyLight = Color(0xFF2D2380);
const _bg = AppColors.background;
const _cardBorder = AppColors.border;
const _textDark = AppColors.textPrimary;
const _textMuted = AppColors.textSecondary;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final alertsState = ref.watch(alertsProvider);
    final selectedFarm = ref.watch(selectedFarmProvider);
    final alertsCount = ref.watch(alertsCountProvider);

    final l10n = AppLocalizations.of(context);
    final userName = user?.firstName ?? 'Farmer';
    final dueTodayAlerts = alertsState.dueToday;
    final overdueAlerts = dueTodayAlerts.where((a) => a.isOverdue).toList();
    final pendingAlerts = dueTodayAlerts.where((a) => !a.isOverdue).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _navy,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await ref.read(farmsProvider.notifier).loadFarms(refresh: true);
            ref.read(animalsProvider.notifier).loadAnimals();
            ref.read(alertsProvider.notifier).loadAlerts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: Column(
              children: [
                // ════════════════════════════════════════════
                // HEADER (Nordea-style)
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
                          // Top row: centered farm selector + alerts on right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 54), // Balance the alerts icon width
                              Expanded(
                                child: Center(
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
                                            constraints: const BoxConstraints(maxWidth: 180),
                                            child: Text(
                                              selectedFarm?.name ?? l10n.selectFarm,
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
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const AlertsScreen())),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: _navyLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                                      if (alertsCount > 0)
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF6B6B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.appName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.welcome(userName),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                ),

                // ════════════════════════════════════════════
                // CONTENT (light background)
                // ════════════════════════════════════════════
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 200),
                  child: Container(
                    color: _bg,
                    child: Column(
                      children: [

                // QUICK ACTIONS (floating over navy area)
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickActions,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickAction(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Add\nAnimal',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const AddAnimalScreen(),
                              ));
                            },
                          ),
                          _QuickAction(
                            icon: Icons.edit_note_rounded,
                            label: 'Daily\nRecord',
                            onTap: () => _navigateToAddRecord(),
                          ),
                          _QuickAction(
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Scan\nQR',
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ScanQrScreen())),
                          ),
                          const SizedBox(width: 72),
                        ],
                      ),
                    ],
                  ),
                  ),
                ),

                // ════════════════════════════════════════════
                // SECTION CARDS
                // ════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    children: [
                      // ── DUE TODAY ──
                      if (selectedFarm != null && pendingAlerts.isNotEmpty) ...[
                        _SectionCard(
                          title: l10n.dueToday,
                          trailing: '${pendingAlerts.length}',
                          onChevronTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AlertsScreen())),
                          children: _groupAlertsByAnimal(pendingAlerts)
                              .entries
                              .take(3)
                              .map((entry) => _AnimalTaskGroup(
                                    animalName: entry.key,
                                    alerts: entry.value,
                                    onTap: () => _navigateToAnimal(
                                      entry.value.first.animalId,
                                      initialTab: entry.value.first.isVaccination ? 1 : 2,
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── OVERDUE ──
                      if (selectedFarm != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: overdueAlerts.isEmpty
                              ? Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded,
                                        color: Color(0xFF16A34A), size: 20),
                                    const SizedBox(width: 12),
                                    Text(l10n.noOverdueTasks,
                                        style: TextStyle(color: _textMuted, fontSize: 15)),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(l10n.overdue,
                                              style: TextStyle(
                                                  color: AppColors.error, fontSize: 18, fontWeight: FontWeight.w700)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${overdueAlerts.length}',
                                            style: const TextStyle(
                                                color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    ..._groupAlertsByAnimal(overdueAlerts)
                                        .entries
                                        .map((entry) => _AnimalTaskGroup(
                                              animalName: entry.key,
                                              alerts: entry.value,
                                              isOverdue: true,
                                              onTap: () => _navigateToAnimal(
                                                entry.value.first.animalId,
                                                initialTab: entry.value.first.isVaccination ? 1 : 2,
                                              ),
                                            )),
                                  ],
                                ),
                        ),

                      if (selectedFarm != null) const SizedBox(height: 12),

                      // ── ALL CAUGHT UP ──
                      if (selectedFarm != null &&
                          pendingAlerts.isEmpty &&
                          overdueAlerts.isEmpty &&
                          !alertsState.isLoading)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 32),
                              const SizedBox(height: 10),
                              Text(l10n.allCaughtUp,
                                  style: const TextStyle(color: _textDark, fontSize: 15, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(l10n.noHealthTasksDueToday,
                                  style: const TextStyle(color: _textMuted, fontSize: 13)),
                            ],
                          ),
                        ),

                      // ── NO FARM SELECTED ──
                      if (selectedFarm == null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.home_work_outlined, color: _textMuted, size: 40),
                              const SizedBox(height: 12),
                              Text(l10n.selectFarmToSeeOverview,
                                  style: const TextStyle(color: _textMuted, fontSize: 14)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                    ],
                  ),
                ), // end light background Container
                ), // end ConstrainedBox

              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<AlertItem>> _groupAlertsByAnimal(List<AlertItem> alerts) {
    final map = <String, List<AlertItem>>{};
    for (final a in alerts) {
      map.putIfAbsent(a.animalName, () => []).add(a);
    }
    return map;
  }

  void _navigateToAddRecord() {
    final selectedFarm = ref.read(selectedFarmProvider);
    final activeAnimals = ref.read(animalsProvider).activeAnimals;

    if (selectedFarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectFarmFirst)),
      );
      return;
    }

    if (activeAnimals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noActiveAnimalsToRecord)),
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
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppLocalizations.of(context).selectAnimal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
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

  void _navigateToAnimal(String animalId, {int initialTab = 0}) {
    final selectedFarm = ref.read(selectedFarmProvider);
    if (selectedFarm != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AnimalDetailScreen(
            farmId: selectedFarm.id,
            animalId: animalId,
            initialTab: initialTab,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(AppLocalizations.of(context).selectFarm,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ...farms.map((farm) => ListTile(
                      title: Text(farm.name),
                      subtitle: farm.locationString.isNotEmpty
                          ? Text(farm.locationString,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))
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

// ═══════════════════════════════════════════════════════════════════
// QUICK ACTION BUTTON (Nordea circular icon style)
// ═══════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════
// SECTION CARD (with title + chevron)
// ═══════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onChevronTap;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.trailing,
    this.onChevronTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              if (trailing != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(trailing!,
                      style: const TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              if (onChevronTap != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onChevronTap,
                  child: const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 24),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANIMAL TASK GROUP
// ═══════════════════════════════════════════════════════════════════

class _AnimalTaskGroup extends StatelessWidget {
  final String animalName;
  final List<AlertItem> alerts;
  final bool isOverdue;
  final VoidCallback onTap;

  const _AnimalTaskGroup({
    required this.animalName,
    required this.alerts,
    this.isOverdue = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vaccCount = alerts.where((a) => a.isVaccination).length;
    final medCount = alerts.where((a) => a.isMedication).length;

    final parts = <String>[];
    if (vaccCount > 0) parts.add('$vaccCount vaccination${vaccCount > 1 ? 's' : ''}');
    if (medCount > 0) parts.add('$medCount medication${medCount > 1 ? 's' : ''}');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined, size: 20, color: _navy),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(animalName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 2),
                  Text(parts.join(', '),
                      style: const TextStyle(fontSize: 13, color: _textMuted)),
                ],
              ),
            ),
            if (isOverdue)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              ),
            Icon(Icons.chevron_right_rounded, size: 24, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
