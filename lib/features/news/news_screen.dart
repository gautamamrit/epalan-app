import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../shared/widgets/epalan_app_bar.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Logo, Farm Selector, and Alerts
            const EPalanSliverAppBar(),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  const Text(
                    'News & Updates',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Latest news and tips for your farm.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _NewsCard(
                    imageUrl: null,
                    category: 'TIPS',
                    title: 'Best Practices for Broiler Management in Summer',
                    excerpt: 'Learn how to keep your birds healthy during hot weather with proper ventilation and hydration strategies.',
                    date: '2 hours ago',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  _NewsCard(
                    imageUrl: null,
                    category: 'MARKET',
                    title: 'Poultry Prices Expected to Rise in Q2',
                    excerpt: 'Industry analysts predict a 15% increase in poultry prices due to rising feed costs.',
                    date: 'Yesterday',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  _NewsCard(
                    imageUrl: null,
                    category: 'HEALTH',
                    title: 'New Vaccination Protocol for Newcastle Disease',
                    excerpt: 'Updated guidelines from the Department of Livestock Services for commercial farms.',
                    date: '3 days ago',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  _NewsCard(
                    imageUrl: null,
                    category: 'EPALAN',
                    title: 'App Update: New Analytics Dashboard',
                    excerpt: 'Track your farm performance with improved charts and reporting features.',
                    date: '1 week ago',
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final String title;
  final String excerpt;
  final String date;
  final VoidCallback onTap;

  const _NewsCard({
    this.imageUrl,
    required this.category,
    required this.title,
    required this.excerpt,
    required this.date,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (category) {
      case 'TIPS':
        return AppColors.primary;
      case 'MARKET':
        return AppColors.warning;
      case 'HEALTH':
        return AppColors.error;
      case 'EPALAN':
        return Colors.blue;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: AppColors.border,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _categoryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Excerpt
                  Text(
                    excerpt,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
