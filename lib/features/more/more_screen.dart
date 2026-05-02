import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../farms/manage_farms_screen.dart';
import '../profile/profile_screen.dart';
import '../shared/widgets/app_shell.dart';
import '../team/team_screen.dart';

const _navy = AppColors.primary;
const _navyLight = Color(0xFF2D2380);
const _bg = AppColors.background;
const _textDark = AppColors.textPrimary;
const _textMuted = AppColors.textSecondary;

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Future.delayed(const Duration(milliseconds: 100));
              ref.read(navigationIndexProvider.notifier).state = 0;
              ref.read(authProvider.notifier).logout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _navy,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── NAVY HEADER ──
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            l10n.more,
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── CONTENT (light background) ──
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 250),
                child: Container(
                  color: _bg,
                  child: Column(
                    children: [
                      // Profile Card (floating)
                      Transform.translate(
                        offset: const Offset(0, -24),
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen())),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
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
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    user != null ? '${user.firstName[0]}${user.lastName[0]}' : 'NA',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ?? l10n.guestUser,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark),
                                    ),
                                    if (user?.email != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.email_outlined, size: 14, color: _textMuted),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(user!.email!, style: const TextStyle(fontSize: 13, color: _textMuted), overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (user?.phone != null) ...[
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone_outlined, size: 14, color: _textMuted),
                                          const SizedBox(width: 6),
                                          Text(user!.phone!, style: const TextStyle(fontSize: 13, color: _textMuted)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                        ),
                      ),

                      // Menu Items
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _MenuItem(
                              icon: Icons.home_work_outlined,
                              label: l10n.manageFarms,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const ManageFarmsScreen())),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                            _MenuItem(
                              icon: Icons.people_outline,
                              label: l10n.team,
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TeamScreen())),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                            _MenuItem(
                              icon: Icons.help_outline,
                              label: l10n.helpAndSupport,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      // Logout
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _MenuItem(
                          icon: Icons.logout,
                          label: l10n.logout,
                          iconColor: AppColors.error,
                          textColor: AppColors.error,
                          showArrow: false,
                          onTap: () => _showLogoutConfirmation(context, ref),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: Text(l10n.version('1.0.0'), style: const TextStyle(fontSize: 12, color: _textMuted)),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.textColor,
    this.showArrow = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? _textDark)),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}
