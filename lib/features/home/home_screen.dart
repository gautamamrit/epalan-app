import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/animal_provider.dart';
import '../../data/providers/farm_provider.dart';
import '../animals/animal_detail_screen.dart';
import '../animals/scan_qr_screen.dart';
import '../alerts/alerts_screen.dart';

// ── Palette aliases (from AppColors) ──
const _navy = AppColors.primary;
const _navyLight = Color(0xFF2D2380);
const _navyCard = AppColors.cardDark;
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
  void initState() {
    super.initState();
    // Data loading handled by AppShell — no duplicate calls
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final alertsState = ref.watch(alertsProvider);
    final animalsState = ref.watch(animalsProvider);
    final selectedFarm = ref.watch(selectedFarmProvider);
    final alertsCount = ref.watch(alertsCountProvider);

    final userName = user?.firstName ?? 'Farmer';
    final dueTodayAlerts = alertsState.dueToday;
    final overdueAlerts = dueTodayAlerts.where((a) => a.isOverdue).toList();
    final pendingAlerts = dueTodayAlerts.where((a) => !a.isOverdue).toList();
    final activeAnimals = animalsState.activeAnimals;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
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
              // DARK NAVY HEADER + WHITE CURVE (exact Helen)
              // ════════════════════════════════════════════
              SizedBox(
                height: 260,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Navy background — shorter
                    Positioned.fill(
                      child: Container(color: _navy),
                    ),
                    // White curved hill (Helen style)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipPath(
                        clipper: _ConvexCurveClipper(),
                        child: Container(height: 160, color: _bg),
                      ),
                    ),
                    // TODO: Add farm illustration later
                    // Top bar (farm selector + alerts) — on top of everything
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showFarmPicker(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _navyLight,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedFarm?.name ?? 'Select Farm',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down,
                                            color: Colors.white, size: 22),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ScanQrScreen())),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: _navyLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.qr_code_scanner,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const AlertsScreen())),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: _navyLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(Icons.notifications_outlined,
                                          color: Colors.white, size: 22),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hi, $userName',
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "It's ${_formatDate(DateTime.now())} today",
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ════════════════════════════════════════════
              // CARDS
              // ════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  children: [
                    // ── 1. ACTIVE ANIMALS (dark navy) ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _navyCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: selectedFarm == null
                          ? const _NoFarmContent()
                          : animalsState.isLoading
                              ? const _LoadingContent()
                              : activeAnimals.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'No active animals',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${activeAnimals.length} active ${activeAnimals.length == 1 ? 'animal' : 'animals'}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.5),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ...activeAnimals.take(4).map((animal) =>
                                            GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () => _navigateToAnimal(animal.id),
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom: 18),
                                                child: Row(
                                                  children: [
                                                    // Animal icon
                                                    Container(
                                                      width: 44,
                                                      height: 44,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withValues(alpha: 0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'Day\n',
                                                                style: TextStyle(
                                                                  color: Colors.white.withValues(alpha: 0.5),
                                                                  fontSize: 10,
                                                                  height: 1.3,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: '${animal.daysElapsed}',
                                                                style: TextStyle(
                                                                  color: Colors.white.withValues(alpha: 0.8),
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w700,
                                                                  height: 1.3,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            animal.displayName,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 3),
                                                          Text(
                                                            '${animal.category?.name ?? ''} · ${_formatCount(animal.headCount)} head',
                                                            style: TextStyle(
                                                              color: Colors.white.withValues(alpha: 0.45),
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(Icons.chevron_right_rounded,
                                                        size: 24,
                                                        color: Colors.white.withValues(alpha: 0.4)),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                    ),

                    const SizedBox(height: 12),

                    // ── 2. DUE TODAY (white) ──
                    if (selectedFarm != null && pendingAlerts.isNotEmpty)
                      _buildCard(
                        title: 'Due today',
                        trailing: '${pendingAlerts.length}',
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

                    if (selectedFarm != null && pendingAlerts.isNotEmpty)
                      const SizedBox(height: 12),

                    // ── 3. OVERDUE ──
                    if (selectedFarm != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _cardBorder),
                        ),
                        child: overdueAlerts.isEmpty
                            ? const Row(
                                children: [
                                  Icon(Icons.check_circle_outline_rounded,
                                      color: Color(0xFF16A34A), size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'No overdue tasks',
                                    style: TextStyle(
                                      color: _textMuted,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Overdue',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${overdueAlerts.length}',
                                          style: const TextStyle(
                                            color: AppColors.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
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

                    if (selectedFarm != null)
                      const SizedBox(height: 12),

                    // ── 4. NO TASKS STATE ──
                    if (selectedFarm != null &&
                        pendingAlerts.isEmpty &&
                        overdueAlerts.isEmpty &&
                        !alertsState.isLoading) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _cardBorder),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: Color(0xFF16A34A), size: 32),
                            SizedBox(height: 10),
                            Text(
                              'All caught up!',
                              style: TextStyle(
                                color: _textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'No health tasks due today',
                              style: TextStyle(color: _textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

  Widget _buildCard({
    required String title,
    String? trailing,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trailing,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  void _navigateToAnimal(String animalId, {int initialTab = 0}) {
    final selectedFarm = ref.read(selectedFarmProvider);
    if (selectedFarm != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimalDetailScreen(
            farmId: selectedFarm.id,
            animalId: animalId,
            initialTab: initialTab,
          ),
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
                          color: _textDark)),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  title: const Text('All Farms'),
                  trailing: currentFarm == null
                      ? const Icon(Icons.check, size: 18, color: _navy)
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

String _formatDate(DateTime date) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatCount(int c) {
  if (c >= 10000) return '${(c / 1000).toStringAsFixed(1)}k';
  return c.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ═══════════════════════════════════════════════════════════════════
// ANIMAL TASK GROUP — tasks grouped by animal name
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 20,
                color: _navy,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animalName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    parts.join(', '),
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isOverdue)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(Icons.chevron_right_rounded,
                size: 24,
                color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PLACEHOLDER CONTENT
// ═══════════════════════════════════════════════════════════════════

class _NoFarmContent extends StatelessWidget {
  const _NoFarmContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'Select a farm to see overview',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CONVEX CURVE CLIPPER (Helen's white hill shape)
// ═══════════════════════════════════════════════════════════════════

class _ConvexCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.55);
    // Deep inward curve — peaks higher in the center like Helen
    path.quadraticBezierTo(size.width / 2, -size.height * 0.15, 0, size.height * 0.55);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
