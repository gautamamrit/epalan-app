import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnimalPreviewCard extends StatelessWidget {
  final String animalId;
  final int dayCount;
  final String type;
  final String farmName;
  final int headCount;
  final String? weight;
  final String? fcr;
  final int? eggsToday;
  final VoidCallback onTap;

  const AnimalPreviewCard({
    super.key,
    required this.animalId,
    required this.dayCount,
    required this.type,
    required this.farmName,
    required this.headCount,
    this.weight,
    this.fcr,
    this.eggsToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Animal Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.egg_alt,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Animal Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$animalId · Day $dayCount $type',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$headCount head',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        farmName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (weight != null)
                        Text(
                          'Weight: $weight',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (fcr != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          'FCR: $fcr',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (eggsToday != null)
                        Text(
                          'Eggs today: $eggsToday',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
