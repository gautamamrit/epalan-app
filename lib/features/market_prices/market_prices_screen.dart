import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/market_price.dart';
import '../../data/providers/farm_provider.dart';
import '../../data/providers/market_price_provider.dart';
import '../shared/widgets/app_shell.dart';
import '../../data/services/location_service.dart';

final _provincesProvider = FutureProvider<List<LocationProvince>>((ref) {
  return LocationService().getProvinces();
});

const _rangeOptions = [
  (label: '7D', days: 7),
  (label: '1M', days: 30),
  (label: '3M', days: 90),
  (label: '6M', days: 180),
  (label: '1Y', days: 365),
];

const _chartColor = Color(0xFF2563EB);

class MarketPricesScreen extends ConsumerStatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  ConsumerState<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends ConsumerState<MarketPricesScreen> {
  bool _initialized = false;

  void _showProvinceSelector(List<LocationProvince> provinces) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Province', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            ...provinces.map((prov) => ListTile(
              title: Text(prov.name, style: const TextStyle(fontSize: 14)),
              trailing: ref.read(marketPriceProvider).selectedProvinceId == prov.id
                  ? const Icon(Icons.check, color: AppColors.primary, size: 20)
                  : null,
              dense: true,
              onTap: () {
                ref.read(marketPriceProvider.notifier).load(provinceId: prov.id);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showItemFilter(List<MarketPriceItem> items) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Filter Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      if (ref.read(marketPriceProvider).selectedItemIds.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref.read(marketPriceProvider.notifier).clearItemFilter();
                            setSheetState(() {});
                          },
                          child: const Text('Clear all', style: TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: items.map((item) => CheckboxListTile(
                      value: ref.read(marketPriceProvider).selectedItemIds.contains(item.id),
                      title: Text(item.name, style: const TextStyle(fontSize: 14)),
                      dense: true,
                      activeColor: AppColors.primary,
                      onChanged: (checked) {
                        ref.read(marketPriceProvider.notifier).toggleItem(item.id);
                        setSheetState(() {});
                      },
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provincesAsync = ref.watch(_provincesProvider);
    final mpState = ref.watch(marketPriceProvider);

    final currentTab = ref.watch(navigationIndexProvider);
    final isVisible = currentTab == 2;

    if (isVisible && !_initialized) {
      provincesAsync.whenData((provinces) {
        if (provinces.isNotEmpty && mpState.selectedProvinceId == null) {
          final selectedFarm = ref.read(selectedFarmProvider);
          final provinceId = selectedFarm?.provinceId ?? provinces.first.id;
          Future.microtask(() => ref.read(marketPriceProvider.notifier).load(provinceId: provinceId));
        } else {
          Future.microtask(() => ref.read(marketPriceProvider.notifier).load(provinceId: mpState.selectedProvinceId));
        }
        _initialized = true;
      });
    }

    // Reset when leaving tab so data refreshes on return
    if (!isVisible && _initialized) {
      _initialized = false;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Market Prices',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Province selector
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Province', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 6),
                    provincesAsync.when(
                      data: (provinces) => GestureDetector(
                        onTap: () => _showProvinceSelector(provinces),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  provinces.where((p) => p.id == mpState.selectedProvinceId).firstOrNull?.name ?? 'Select Province',
                                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),

                    // Item filter
                    if (mpState.items.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (mpState.items.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showItemFilter(mpState.items),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mpState.selectedItemIds.isEmpty
                                      ? 'All Items'
                                      : '${mpState.selectedItemIds.length} item${mpState.selectedItemIds.length > 1 ? 's' : ''} selected',
                                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Range buttons
                    Row(
                      children: _rangeOptions.map((opt) {
                        final isActive = mpState.selectedDays == opt.days;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => ref.read(marketPriceProvider.notifier).changeDays(opt.days),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.textPrimary : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isActive ? AppColors.textPrimary : AppColors.border),
                              ),
                              child: Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            if (mpState.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (mpState.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text('Failed to load prices', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.read(marketPriceProvider.notifier).load(provinceId: mpState.selectedProvinceId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (mpState.items.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 64, color: AppColors.border),
                      SizedBox(height: 12),
                      Text('No price data available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      SizedBox(height: 4),
                      Text('Prices will appear here once available', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )
            else ...[
              () {
                final filteredItems = mpState.selectedItemIds.isEmpty
                    ? mpState.items
                    : mpState.items.where((i) => mpState.selectedItemIds.contains(i.id)).toList();
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        final latest = mpState.latestForItem(item.id);
                        final history = mpState.historyForItem(item.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PriceCard(item: item, price: latest, history: history),
                        );
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                );
              }(),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends StatefulWidget {
  final MarketPriceItem item;
  final MarketPrice? price;
  final List<MarketPrice> history;

  const _PriceCard({required this.item, this.price, required this.history});

  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  bool _chartExpanded = false;

  MarketPriceItem get item => widget.item;
  MarketPrice? get price => widget.price;
  List<MarketPrice> get history => widget.history;

  String _timeAgo(String dateStr) {
    final now = DateTime.now();
    final then = DateTime.parse(dateStr);
    final diff = now.difference(then);
    if (diff.inHours < 1) return 'just now';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      if (item.nameNe != null)
                        Text(item.nameNe!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price + chart toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 0),
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: price != null
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Rs ${price!.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(item.unitLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF166534))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Updated ${_timeAgo(price!.date)}${price!.source != null ? ' \u00b7 Source: ${price!.source}' : ''}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (history.length >= 2)
                          GestureDetector(
                            onTap: () => setState(() => _chartExpanded = !_chartExpanded),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _chartExpanded ? _chartColor.withValues(alpha: 0.1) : AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _chartExpanded ? Icons.show_chart : Icons.show_chart,
                                size: 20,
                                color: _chartExpanded ? _chartColor : AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Text('No data available', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
          ),

          // Chart (collapsible)
          if (history.length >= 2 && _chartExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: SizedBox(
                height: 140,
                child: _buildChart(),
              ),
            ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Build date-indexed data with forward-fill
    final dates = <String>[];
    final priceMap = <String, double>{};
    for (final p in history) {
      priceMap[p.date] = p.price;
    }

    // Build continuous date range
    final sortedDates = priceMap.keys.toList()..sort();
    final start = DateTime.parse(sortedDates.first);
    final end = DateTime.now();
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      dates.add('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }

    // Forward-fill
    final values = <double>[];
    final realPoints = <int>{};
    double? lastKnown;
    double? firstKnown;

    for (var i = 0; i < dates.length; i++) {
      final actual = priceMap[dates[i]];
      if (actual != null) {
        values.add(actual);
        lastKnown = actual;
        firstKnown ??= actual;
        realPoints.add(i);
      } else {
        values.add(lastKnown ?? firstKnown ?? 0);
      }
    }

    if (values.isEmpty) return const SizedBox.shrink();

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    final spots = values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 4).clamp(1, double.infinity),
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 0.5, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, _) => Text(
                'Rs ${value.toInt()}',
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (dates.length / 4).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= dates.length) return const SizedBox.shrink();
                final d = DateTime.parse(dates[idx]);
                final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${months[d.month - 1]} ${d.day}', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: (minY - padding).floorToDouble(),
        maxY: (maxY + padding).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: _chartColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => realPoints.contains(spot.x.toInt()),
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 2,
                color: _chartColor,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) => LineTooltipItem(
              'Rs ${s.y.toStringAsFixed(2)}',
              const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            )).toList(),
          ),
        ),
      ),
    );
  }
}
