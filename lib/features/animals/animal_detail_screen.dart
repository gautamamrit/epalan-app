import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_form_fields.dart';
import '../../data/models/animal.dart';
import '../../data/providers/animal_provider.dart';
import 'add_animal_screen.dart';
import 'add_record_screen.dart';
import 'animal_qr_screen.dart';
import 'end_tracking_screen.dart';

class AnimalDetailScreen extends ConsumerStatefulWidget {
  final String farmId;
  final String animalId;
  final int initialTab;
  final String? animalName;
  final String? categoryName;
  final String? breedName;

  const AnimalDetailScreen({
    super.key,
    required this.farmId,
    required this.animalId,
    this.initialTab = 0,
    this.animalName,
    this.categoryName,
    this.breedName,
  });

  @override
  ConsumerState<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends ConsumerState<AnimalDetailScreen>
    {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(animalDetailProvider.notifier).loadAnimalDetail(
            widget.farmId,
            widget.animalId,
          );
    });
  }

  Future<void> _completeVaccination(Vaccination vaccination) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.vaccines_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Complete Vaccination')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark "${vaccination.name}" as completed?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Day ${vaccination.scheduledDay}${vaccination.method != null ? ' · ${vaccination.method}' : ''}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final animalService = ref.read(animalServiceProvider);
      await animalService.completeVaccination(
        widget.farmId,
        widget.animalId,
        vaccination.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination marked as complete'),
            backgroundColor: AppColors.primary,
          ),
        );
        // Refresh animal detail
        ref.read(animalDetailProvider.notifier).loadAnimalDetail(
              widget.farmId,
              widget.animalId,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete vaccination: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _completeMedication(Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication_rounded, color: AppColors.warning, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Complete Medication')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark "${medication.name}" as completed?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${medication.scheduledStartDay}-${medication.scheduledEndDay} (${medication.durationDays} days)',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  if (medication.dosage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dosage: ${medication.dosage}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final animalService = ref.read(animalServiceProvider);
      await animalService.completeMedication(
        widget.farmId,
        widget.animalId,
        medication.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication completed'),
            backgroundColor: AppColors.primary,
          ),
        );
        // Refresh animal detail
        ref.read(animalDetailProvider.notifier).loadAnimalDetail(
              widget.farmId,
              widget.animalId,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete medication: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(animalDetailProvider);
    final detail = detailState.detail;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: detailState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(detailState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(animalDetailProvider.notifier).loadAnimalDetail(
                                widget.farmId,
                                widget.animalId,
                              );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : detail != null
                  ? _buildContent(detail)
                  : Container(color: AppColors.primary),
    );
  }

  Widget _buildContent(AnimalDetail detail) {
    final animal = detail.animal;
    final stats = detail.stats;
    final isLayer =
        animal.category?.name.toLowerCase().contains('layer') ?? false;
    final currentQuantity = stats.currentQuantity ?? stats.initialQuantity;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── NAVY HEADER (minimal — name + breed only) ──
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: SizedBox(
                  height: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                        child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Text('Animals', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(animal.displayName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      [animal.category?.name ?? 'Animal', if (animal.breed != null) animal.breed!.name].join(' · '),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),

        // ── CONTENT AREA (light background, fills remaining space) ──
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 200,
          ),
          child: Container(
            color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

          // ── QUICK ACTIONS (overlaps into navy via negative margin) ──
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
                  _QuickAction(icon: Icons.edit_outlined, label: 'Edit', onTap: () => _editAnimal(detail)),
                  if (animal.shortCode != null)
                    _QuickAction(icon: Icons.qr_code_2, label: 'QR\nCode', onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AnimalQrScreen(animalName: animal.displayName, shortCode: animal.shortCode!, categoryName: animal.category?.name, breedName: animal.breed?.name),
                    ))),
                  if (animal.isActive)
                    _QuickAction(icon: Icons.check_circle_outline, label: 'End\nTracking', onTap: () => _changeAnimalStatus(detail)),
                  _QuickAction(icon: Icons.delete_outline, label: 'Delete', onTap: () => _deleteAnimal(detail), isDestructive: true),
                ],
              ),
            ),
          ),

        // ── STATS CARD (two columns) ──
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: stacked fraction + alive label
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$currentQuantity',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1,
                        ),
                      ),
                      Container(
                        width: 55,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: AppColors.border,
                      ),
                      Text(
                        '${stats.initialQuantity}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ALIVE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 50, color: AppColors.border),
              const SizedBox(width: 20),
              // Right: stats column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.mortalityRate.toStringAsFixed(1)}% MORTALITY',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (stats.latestAvgWeightKg != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${stats.latestAvgWeightKg!.toStringAsFixed(1)}KG WEIGHT',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                    if (isLayer) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${stats.totalEggs} EGGS',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      '${stats.totalFeedKg.toStringAsFixed(0)}KG FEED',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── SECTION CARDS (grouped in one card) ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildNavRow(
                icon: Icons.edit_note_rounded,
                title: 'Daily Records',
                subtitle: detail.recentRecords.isEmpty
                    ? 'No records yet'
                    : '${detail.recentRecords.length} records',
                count: detail.recentRecords.length,
                onTap: () => _openRecordsScreen(detail),
              ),
              const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
              _buildNavRow(
                icon: Icons.vaccines,
                title: 'Vaccinations',
                subtitle: () {
                  final pending = detail.upcomingHealth.vaccinations.where((v) => !v.isCompleted).length;
                  final total = detail.upcomingHealth.vaccinations.length;
                  if (total == 0) return 'No vaccinations scheduled';
                  return '$pending pending of $total';
                }(),
                count: detail.upcomingHealth.vaccinations.where((v) => !v.isCompleted).length,
                hasWarning: detail.upcomingHealth.vaccinations.any((v) => v.isOverdue),
                onTap: () => _openVaccinationsScreen(detail),
              ),
              const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
              _buildNavRow(
                icon: Icons.medication,
                title: 'Medications',
                subtitle: () {
                  final pending = detail.upcomingHealth.medications.where((m) => m.isPending).length;
                  final total = detail.upcomingHealth.medications.length;
                  if (total == 0) return 'No medications scheduled';
                  return '$pending pending of $total';
                }(),
                count: detail.upcomingHealth.medications.where((m) => m.isPending).length,
                onTap: () => _openMedicationsScreen(detail),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
            ],
          ),
        ), // end content area Container
        ), // end ConstrainedBox
      ],
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onTap,
    bool hasWarning = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (hasWarning)
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        ),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: hasWarning ? AppColors.error : AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  void _openRecordsScreen(AnimalDetail detail) {
    final isLayer = detail.animal.category?.name.toLowerCase().contains('layer') ?? false;
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => _SubListScreen(
        title: 'Daily Records',
        backLabel: detail.animal.displayName,
        onAdd: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => AddRecordScreen(
              farmId: widget.farmId, animalId: widget.animalId,
              animalName: detail.animal.displayName, currentDay: detail.stats.daysElapsed, isLayer: isLayer,
            ),
          )).then((result) {
            if (result != null) ref.read(animalDetailProvider.notifier).loadAnimalDetail(widget.farmId, widget.animalId);
          });
        },
        child: detail.recentRecords.isEmpty
            ? Center(child: _buildEmptyState(icon: Icons.edit_note_rounded, title: 'No records yet', subtitle: 'Add your first daily record'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemCount: detail.recentRecords.length,
                itemBuilder: (_, i) => _buildRecordCard(detail.recentRecords[i], detail),
              ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ));
  }

  void _openVaccinationsScreen(AnimalDetail detail) {
    final vaccinations = detail.upcomingHealth.vaccinations;
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => _SubListScreen(
        title: 'Vaccinations',
        backLabel: detail.animal.displayName,
        onAdd: () => _addManualEntry('vaccination'),
        child: vaccinations.isEmpty
            ? _buildApplyProgramSection(type: 'vaccination', categoryId: detail.animal.categoryId, icon: Icons.vaccines)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  ...vaccinations.where((v) => !v.isCompleted).map((v) => _buildVaccinationCard(v)),
                  if (vaccinations.any((v) => v.isCompleted)) ...[
                    _buildSectionHeader('COMPLETED'),
                    ...vaccinations.where((v) => v.isCompleted).map((v) => _buildVaccinationCard(v)),
                  ],
                ],
              ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ));
  }

  void _openMedicationsScreen(AnimalDetail detail) {
    final medications = detail.upcomingHealth.medications;
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => _SubListScreen(
        title: 'Medications',
        backLabel: detail.animal.displayName,
        onAdd: () => _addManualEntry('medication'),
        child: medications.isEmpty
            ? _buildApplyProgramSection(type: 'medication', categoryId: detail.animal.categoryId, icon: Icons.medication)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  ...medications.where((m) => m.isPending).map((m) => _buildMedicationCard(m)),
                  if (medications.any((m) => m.isCompleted)) ...[
                    _buildSectionHeader('COMPLETED'),
                    ...medications.where((m) => m.isCompleted).map((m) => _buildMedicationCard(m)),
                  ],
                ],
              ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ));
  }

  void _editRecord(DailyRecord record, AnimalDetail detail, bool isLayer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecordScreen(
          farmId: widget.farmId,
          animalId: widget.animalId,
          animalName: detail.animal.displayName,
          currentDay: detail.stats.daysElapsed,
          isLayer: isLayer,
          existingRecord: record,
        ),
      ),
    );
    if (result != null && mounted) {
      ref.read(animalDetailProvider.notifier).loadAnimalDetail(
            widget.farmId, widget.animalId);
    }
  }

  void _deleteRecord(DailyRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record?'),
        content: Text(
            'Delete the record for Day ${record.dayNumber ?? ""}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final animalService = ref.read(animalServiceProvider);
                await animalService.deleteDailyRecord(
                    widget.farmId, widget.animalId, record.id);
                if (mounted) {
                  ref.read(animalDetailProvider.notifier).loadAnimalDetail(
                        widget.farmId, widget.animalId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Record deleted'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editAnimal(AnimalDetail detail) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAnimalScreen(existingAnimal: detail.animal),
      ),
    );
    if (result != null && mounted) {
      ref.read(animalDetailProvider.notifier).loadAnimalDetail(
            widget.farmId, widget.animalId);
    }
  }

  void _changeAnimalStatus(AnimalDetail detail) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EndTrackingScreen(
          farmId: widget.farmId,
          animal: detail.animal,
        ),
      ),
    );
    if (result != null && mounted) {
      ref.read(animalDetailProvider.notifier).loadAnimalDetail(
            widget.farmId, widget.animalId);
    }
  }

  void _deleteAnimal(AnimalDetail detail) {
    final hasRecords = detail.recentRecords.isNotEmpty ||
        detail.healthSummary.vaccinations.total > 0 ||
        detail.healthSummary.medications.total > 0;

    final message = hasRecords
        ? 'This will permanently delete "${detail.animal.displayName}" and all its records, vaccinations, and medications. This cannot be undone.'
        : 'Are you sure you want to delete "${detail.animal.displayName}"? This cannot be undone.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Animal?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (hasRecords) {
                // Second confirmation for animals with data
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx2) => AlertDialog(
                    title: const Text('Are you absolutely sure?'),
                    content: const Text(
                        'All daily records, vaccinations, and medications will be permanently lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx2, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx2, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error),
                        child: const Text('Yes, Delete Everything'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
              }
              try {
                await ref.read(animalServiceProvider).deleteAnimal(
                    widget.farmId, widget.animalId);
                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Animal deleted'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _actionCircle({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: Icon(icon, size: 18, color: isDestructive ? const Color(0xFFFF6B6B) : Colors.white),
      ),
    );
  }


  Widget _buildRecordsTab(AnimalDetail detail) {
    final records = detail.recentRecords;
    final isLayer = detail.animal.category?.name.toLowerCase().contains('layer') ?? false;

    return Stack(
      children: [
        ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          children: [
            if (records.isEmpty)
              _buildEmptyState(
                icon: Icons.assignment_outlined,
                title: 'No records yet',
                subtitle: 'Start logging daily records to track your animals',
              )
            else
              ...records.map((record) => _buildRecordCard(record, detail)),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 40,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddRecordScreen(
                    farmId: widget.farmId,
                    animalId: widget.animalId,
                    animalName: detail.animal.displayName,
                    currentDay: detail.stats.daysElapsed,
                    isLayer: isLayer,
                  ),
                ),
              );
              if (result != null) {
                ref.read(animalDetailProvider.notifier).loadAnimalDetail(
                      widget.farmId, widget.animalId);
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF356D3D), Color(0xFF254A2A)],
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
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(DailyRecord record, AnimalDetail detail) {
    final isLayer = detail.animal.category?.name.toLowerCase().contains('layer') ?? false;
    return _ExpandableRecordCard(
      record: record,
      isLayer: isLayer,
      onEdit: () => _editRecord(record, detail, isLayer),
      onDelete: () => _deleteRecord(record),
      formatDate: _formatDate,
    );
  }

  Widget _buildVaccinationsTab(AnimalDetail detail) {
    final vaccinations = detail.upcomingHealth.vaccinations;
    final completed = vaccinations.where((v) => v.isCompleted).toList();
    final pending = vaccinations.where((v) => !v.isCompleted).toList();

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (vaccinations.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => _addManualEntry('vaccination'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Vaccination',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        if (vaccinations.isNotEmpty)
          const SizedBox(height: 16),
        if (pending.isNotEmpty) ...[
          _buildSectionHeader('PENDING'),
          ...pending.map((v) => _buildVaccinationCard(v)),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          _buildSectionHeader('COMPLETED'),
          ...completed.map((v) => _buildVaccinationCard(v)),
        ],
        if (vaccinations.isEmpty)
          _buildApplyProgramSection(
            type: 'vaccination',
            categoryId: detail.animal.categoryId,
            icon: Icons.vaccines_outlined,
          ),
      ],
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccination) {
    final isOverdue = vaccination.isOverdue;
    final isCompleted = vaccination.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.05)
            : isOverdue
                ? AppColors.error.withValues(alpha: 0.05)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : isOverdue
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.vaccines,
                color: isCompleted
                    ? AppColors.success
                    : isOverdue
                        ? AppColors.error
                        : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vaccination.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              if (isOverdue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OVERDUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Day ${vaccination.scheduledDay}${vaccination.method != null ? ' · ${vaccination.method}' : ''}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (isCompleted && vaccination.recordedByName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Recorded by ${vaccination.recordedByName}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _completeVaccination(vaccination),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Mark Complete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isOverdue ? AppColors.error : AppColors.primary,
                  side: BorderSide(
                    color: isOverdue ? AppColors.error : AppColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationsTab(AnimalDetail detail) {
    final medications = detail.upcomingHealth.medications;
    final pending = medications.where((m) => m.isPending).toList();
    final completed = medications.where((m) => m.isCompleted).toList();

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (medications.isNotEmpty) ...[
          OutlinedButton.icon(
            onPressed: () => _addManualEntry('medication'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Medication',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (pending.isNotEmpty) ...[
          _buildSectionHeader('PENDING'),
          ...pending.map((m) => _buildMedicationCard(m)),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          _buildSectionHeader('COMPLETED'),
          ...completed.map((m) => _buildMedicationCard(m)),
        ],
        if (medications.isEmpty)
          _buildApplyProgramSection(
            type: 'medication',
            categoryId: detail.animal.categoryId,
            icon: Icons.medication_outlined,
          ),
      ],
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    final isCompleted = medication.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medication,
                color: isCompleted
                    ? AppColors.success
                    : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Day ${medication.scheduledStartDay}-${medication.scheduledEndDay} · ${medication.durationDays} days',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (medication.method != null || medication.dosage != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (medication.method != null)
                  _buildInfoChip(Icons.local_drink, medication.method!),
                if (medication.dosage != null)
                  _buildInfoChip(Icons.science, medication.dosage!),
              ],
            ),
          ],
          if (isCompleted && medication.recordedByName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Recorded by ${medication.recordedByName}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (medication.isPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _completeMedication(medication),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Mark Complete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildApplyProgramSection({
    required String type,
    required String categoryId,
    required IconData icon,
  }) {
    final animalService = ref.read(animalServiceProvider);
    final isVaccination = type == 'vaccination';

    return FutureBuilder<List<HealthProgram>>(
      future: isVaccination
          ? animalService.getVaccinationPrograms(categoryId)
          : animalService.getMedicationPrograms(categoryId),
      builder: (context, snapshot) {
        final programs = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(
                'No ${isVaccination ? 'vaccinations' : 'medications'} scheduled',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                programs.isEmpty
                    ? 'No programs available for this category'
                    : 'Apply a program to schedule ${isVaccination ? 'vaccinations' : 'medications'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (programs.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...programs.map((program) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(icon, color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  program.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (program.description != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              program.description!,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _viewProgramDetails(type, program.id),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: const Text('View Details',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _applyProgram(type, program.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: const Text('Apply Program',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
              // Add manually button
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _addManualEntry(type),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Add ${isVaccination ? 'Vaccination' : 'Medication'} Manually',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyProgram(String type, String programId) async {
    final animalService = ref.read(animalServiceProvider);
    final detailState = ref.read(animalDetailProvider);
    final detail = detailState.detail;
    if (detail == null) return;

    try {
      final result = type == 'vaccination'
          ? await animalService.applyVaccinationProgram(
              widget.farmId, widget.animalId, programId)
          : await animalService.applyMedicationProgram(
              widget.farmId, widget.animalId, programId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.applied} items applied, ${result.skipped} skipped'),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh animal detail
        ref.read(animalDetailProvider.notifier).loadAnimalDetail(
              widget.farmId, widget.animalId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply program: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _viewProgramDetails(String type, String programId) async {
    final animalService = ref.read(animalServiceProvider);
    final detail = type == 'vaccination'
        ? await animalService.getVaccinationProgramDetail(programId)
        : await animalService.getMedicationProgramDetail(programId);

    if (detail == null || !mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                detail.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (detail.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  detail.description!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${detail.scheduleItems.length} items',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: detail.scheduleItems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, i) {
                    final item = detail.scheduleItems[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'D${item.fromDay}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Day ${item.fromDay}-${item.toDay}${item.route != null ? ' · ${item.route}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addManualEntry(String type) {
    final detailState = ref.read(animalDetailProvider);
    final animal = detailState.detail?.animal;
    if (animal == null) return;

    final isVaccination = type == 'vaccination';
    final nameController = TextEditingController();
    final fromDayController = TextEditingController();
    final toDayController = TextEditingController();
    final routeController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add ${isVaccination ? 'Vaccination' : 'Medication'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameController,
                label: '${isVaccination ? 'Vaccine' : 'Medication'} Name *',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: fromDayController,
                      label: 'From Day *',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || int.tryParse(v) == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: toDayController,
                      label: 'To Day *',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || int.tryParse(v) == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: routeController,
                label: isVaccination ? 'Route (e.g. Oral, Injectable)' : 'Purpose',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final fromDay = int.parse(fromDayController.text);
                    final toDay = int.parse(toDayController.text);
                    final startDate = animal.startDate;
                    final dueFrom = startDate.add(Duration(days: fromDay - 1));
                    final dueTo = startDate.add(Duration(days: toDay - 1));
                    final animalService = ref.read(animalServiceProvider);

                    try {
                      if (isVaccination) {
                        await animalService.addVaccination(
                          widget.farmId, widget.animalId,
                          vaccineName: nameController.text.trim(),
                          fromDay: fromDay,
                          toDay: toDay,
                          dueFromDate: dueFrom.toIso8601String().split('T')[0],
                          dueToDate: dueTo.toIso8601String().split('T')[0],
                          route: routeController.text.trim().isEmpty
                              ? null : routeController.text.trim(),
                        );
                      } else {
                        await animalService.addMedication(
                          widget.farmId, widget.animalId,
                          medicationName: nameController.text.trim(),
                          fromDay: fromDay,
                          toDay: toDay,
                          dueFromDate: dueFrom.toIso8601String().split('T')[0],
                          dueToDate: dueTo.toIso8601String().split('T')[0],
                          purpose: routeController.text.trim().isEmpty
                              ? null : routeController.text.trim(),
                        );
                      }
                      if (mounted) {
                        Navigator.pop(ctx);
                        ref.read(animalDetailProvider.notifier).loadAnimalDetail(
                            widget.farmId, widget.animalId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${isVaccination ? 'Vaccination' : 'Medication'} added'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text('Add ${isVaccination ? 'Vaccination' : 'Medication'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Animal Info Card skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab bar skeleton
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            // Content skeleton
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB LIST SCREEN (records, vaccinations, medications)
// =============================================================================

class _SubListScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAdd;
  final String? backLabel;

  const _SubListScreen({required this.title, required this.child, this.onAdd, this.backLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
            if (backLabel != null) ...[
              const SizedBox(height: 2),
              Text(backLabel!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
            ],
          ],
        ),
        actions: [
          if (onAdd != null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: GestureDetector(
                  onTap: () => onAdd!(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: child,
    );
  }
}

// =============================================================================
// QUICK ACTION (same style as home/animals screens)
// =============================================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _QuickAction({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDestructive ? AppColors.error : AppColors.textPrimary, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EXPANDABLE RECORD CARD
// =============================================================================

class _ExpandableRecordCard extends StatefulWidget {
  final DailyRecord record;
  final bool isLayer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;

  const _ExpandableRecordCard({
    required this.record,
    required this.isLayer,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
  });

  @override
  State<_ExpandableRecordCard> createState() => _ExpandableRecordCardState();
}

class _ExpandableRecordCardState extends State<_ExpandableRecordCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.dayNumber != null ? 'Day ${record.dayNumber}' : 'Record',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  widget.formatDate(record.recordDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),

            // Summary row (always visible)
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                if (record.mortalityCount > 0)
                  _stat(Icons.warning_amber, '${record.mortalityCount} deaths'),
                if (record.feedConsumedKg != null)
                  _stat(Icons.restaurant,
                      '${record.feedConsumedKg!.toStringAsFixed(1)}kg feed'),
                if (record.avgWeightKg != null)
                  _stat(Icons.monitor_weight,
                      '${record.avgWeightKg!.toStringAsFixed(2)}kg avg'),
                if (record.eggsCollected != null)
                  _stat(Icons.egg, '${record.eggsCollected} eggs'),
              ],
            ),

            // Expanded details
            if (_expanded) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: AppColors.border, height: 1),
              ),

              // Detail rows
              if (record.mortalityCount > 0) ...[
                _detailRow('Mortality', '${record.mortalityCount} deaths'),
                if (record.mortalityReason != null && record.mortalityReason!.isNotEmpty)
                  _detailRow('Cause', record.mortalityReason!),
              ],
              if (record.feedConsumedKg != null)
                _detailRow('Feed consumed', '${record.feedConsumedKg!.toStringAsFixed(1)} kg'),
              if (record.avgWeightKg != null)
                _detailRow('Avg weight', '${record.avgWeightKg!.toStringAsFixed(2)} kg'),
              if (record.sampleCount != null)
                _detailRow('Sample size', '${record.sampleCount}'),
              if (record.eggsCollected != null)
                _detailRow('Eggs collected', '${record.eggsCollected}'),
              if (record.notes != null && record.notes!.isNotEmpty)
                _detailRow('Notes', record.notes!),

              const SizedBox(height: 14),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
