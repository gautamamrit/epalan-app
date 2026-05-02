import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/farm.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/farm_provider.dart';
import 'add_farm_screen.dart';
import 'edit_farm_screen.dart';

class ManageFarmsScreen extends ConsumerStatefulWidget {
  const ManageFarmsScreen({super.key});

  @override
  ConsumerState<ManageFarmsScreen> createState() => _ManageFarmsScreenState();
}

class _ManageFarmsScreenState extends ConsumerState<ManageFarmsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(farmsProvider.notifier).loadFarms());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddFarm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFarmScreen()),
    );
    ref.read(farmsProvider.notifier).loadFarms(refresh: true);
  }

  void _openEditFarm(Farm farm) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditFarmScreen(farm: farm)),
    );
    ref.read(farmsProvider.notifier).loadFarms(refresh: true);
  }

  Future<void> _confirmDelete(Farm farm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Delete Farm')),
          ],
        ),
        content: Text('Delete "${farm.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final wasSelected = ref.read(selectedFarmIdProvider) == farm.id;
      final success =
          await ref.read(farmsProvider.notifier).deleteFarm(farm.id);
      if (mounted) {
        if (success && wasSelected) {
          ref.read(selectedFarmIdProvider.notifier).state = null;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '"${farm.name}" deleted'
                : 'Failed to delete farm'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmsProvider);
    final user = ref.watch(currentUserProvider);

    // Build farmId → role lookup from user memberships
    final farmRoles = <String, String>{};
    if (user?.memberships != null) {
      for (final m in user!.memberships!) {
        if (m.entityType == 'farm') {
          farmRoles[m.entityId] = m.role;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.primary, size: 20),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Manage Farms',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            )
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(state.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(farmsProvider.notifier)
                            .loadFarms(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // ── ADD FARM BUTTON ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: GestureDetector(
                        onTap: _openAddFarm,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add_home_work_outlined,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Register a New Farm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Add another farm location to your account',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── TABS ──────────────────────────────────────────
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2,
                      labelStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      unselectedLabelStyle:
                          const TextStyle(fontSize: 14),
                      tabs: [
                        Tab(
                          text:
                              'Active (${state.farms.length})',
                        ),
                        Tab(
                          text:
                              'Deleted (${state.deletedFarms.length})',
                        ),
                      ],
                    ),

                    const Divider(height: 1, color: AppColors.border),

                    // ── TAB CONTENT ───────────────────────────────────
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Active farms
                          _FarmList(
                            farms: state.farms,
                            farmRoles: farmRoles,
                            emptyIcon: Icons.home_work_outlined,
                            emptyTitle: 'No active farms',
                            emptySubtitle: 'Add your first farm to get started',
                            onEdit: _openEditFarm,
                            onDelete: _confirmDelete,
                            onRefresh: () => ref.read(farmsProvider.notifier).loadFarms(refresh: true),
                          ),

                          // Deleted farms
                          _FarmList(
                            farms: state.deletedFarms,
                            farmRoles: farmRoles,
                            emptyIcon: Icons.delete_outline,
                            emptyTitle: 'No deleted farms',
                            emptySubtitle: 'Farms you delete will appear here',
                            isDeleted: true,
                            onRefresh: () => ref.read(farmsProvider.notifier).loadFarms(refresh: true),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FarmList extends StatelessWidget {
  final List<Farm> farms;
  final Map<String, String> farmRoles;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final void Function(Farm)? onEdit;
  final Future<void> Function(Farm)? onDelete;
  final Future<void> Function()? onRefresh;
  final bool isDeleted;

  const _FarmList({
    required this.farms,
    required this.farmRoles,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.onEdit,
    this.onDelete,
    this.onRefresh,
    this.isDeleted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              emptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emptySubtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh ?? () async {},
      child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      itemCount: farms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final role = farmRoles[farms[i].id];
        final canEdit = role == 'owner' || role == 'manager';
        final canDelete = role == 'owner';
        return _FarmCard(
          farm: farms[i],
          role: role,
          isDeleted: isDeleted,
          onEdit: onEdit != null && canEdit ? () => onEdit!(farms[i]) : null,
          onDelete: onDelete != null && canDelete ? () => onDelete!(farms[i]) : null,
        );
      },
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FarmCard extends StatelessWidget {
  final Farm farm;
  final String? role;
  final bool isDeleted;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _FarmCard({
    required this.farm,
    this.role,
    this.isDeleted = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDeleted ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDeleted ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDeleted
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDeleted ? Icons.delete_outline : Icons.home_work_outlined,
                color: isDeleted ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: farm.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDeleted
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (role != null) ...[
                          TextSpan(
                            text: '  · ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          TextSpan(
                            text: _roleLabel(role!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _roleTextColor(role!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (farm.locationString.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      farm.locationString,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                  if (isDeleted && farm.deletedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Deleted ${_formatDate(farm.deletedAt!)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.error),
                    ),
                  ] else if (farm.livestockTypes?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: farm.livestockTypes!
                          .map((lt) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  lt.livestockType?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 22),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'manager':
        return 'Manager';
      case 'staff':
        return 'Staff';
      default:
        return role[0].toUpperCase() + role.substring(1);
    }
  }

  static Color _roleBadgeColor(String role) {
    switch (role) {
      case 'owner':
        return AppColors.success.withValues(alpha: 0.1);
      case 'manager':
        return AppColors.info.withValues(alpha: 0.1);
      default:
        return AppColors.textSecondary.withValues(alpha: 0.12);
    }
  }

  static Color _roleTextColor(String role) {
    switch (role) {
      case 'owner':
        return AppColors.success;
      case 'manager':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}
