import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

/// Base shimmer container for skeleton loading effects
class ShimmerContainer extends StatelessWidget {
  final Widget child;

  const ShimmerContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: child,
    );
  }
}

/// Skeleton box for placeholder content
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton for animal cards in the list
class AnimalCardSkeleton extends StatelessWidget {
  const AnimalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and day badges
            const Row(
              children: [
                SkeletonBox(width: 90, height: 28, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 70, height: 28, borderRadius: 20),
                Spacer(),
                SkeletonBox(width: 32, height: 32, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 16),
            // Animal name
            const SkeletonBox(width: 150, height: 22),
            const SizedBox(height: 8),
            // Subtitle
            const SkeletonBox(width: 100, height: 16),
            const SizedBox(height: 16),
            // Stats row
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(child: _StatSkeleton()),
                  SizedBox(width: 1),
                  Expanded(child: _StatSkeleton()),
                  SizedBox(width: 1),
                  Expanded(child: _StatSkeleton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Column(
        children: [
          SkeletonBox(width: 50, height: 10),
          SizedBox(height: 8),
          SkeletonBox(width: 40, height: 20),
        ],
      ),
    );
  }
}

/// Skeleton for alert cards
class AlertCardSkeleton extends StatelessWidget {
  const AlertCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            SkeletonBox(width: 48, height: 48, borderRadius: 12),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 16),
                  SizedBox(height: 6),
                  SkeletonBox(width: 100, height: 12),
                ],
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(width: 60, height: 18, borderRadius: 8),
                SizedBox(height: 8),
                SkeletonBox(width: 20, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list for loading multiple items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget itemSkeleton;
  final double spacing;

  const SkeletonList({
    super.key,
    this.itemCount = 3,
    required this.itemSkeleton,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < itemCount - 1 ? spacing : 0),
          child: itemSkeleton,
        ),
      ),
    );
  }
}

/// Full page loading skeleton with animal cards
class AnimalsLoadingSkeleton extends StatelessWidget {
  const AnimalsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Filter tabs skeleton
        SkeletonBox(height: 44, borderRadius: 12),
        SizedBox(height: 20),
        // Animal cards
        AnimalCardSkeleton(),
        SizedBox(height: 12),
        AnimalCardSkeleton(),
        SizedBox(height: 12),
        AnimalCardSkeleton(),
      ],
    );
  }
}

/// Loading skeleton for home screen alerts
class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonList(
      itemCount: 3,
      itemSkeleton: AlertCardSkeleton(),
    );
  }
}
