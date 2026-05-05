import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_form_fields.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/locale_provider.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedLanguage = 'ne';

  final _formKey = GlobalKey<FormState>();

  bool get _hasChanges {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    return _firstNameController.text.trim() != user.firstName ||
        _lastNameController.text.trim() != user.lastName ||
        _middleNameController.text.trim() != (user.middleName ?? '') ||
        _emailController.text.trim() != (user.email ?? '') ||
        _phoneController.text.trim() != (user.phone ?? '') ||
        _selectedLanguage != user.language;
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _middleNameController = TextEditingController(text: user?.middleName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedLanguage = user?.language ?? 'ne';

    _firstNameController.addListener(_onFieldChanged);
    _middleNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (_isEditing) setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFieldChanged);
    _middleNameController.removeListener(_onFieldChanged);
    _lastNameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startEditing() {
    final user = ref.read(currentUserProvider);
    _firstNameController.text = user?.firstName ?? '';
    _middleNameController.text = user?.middleName ?? '';
    _lastNameController.text = user?.lastName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _selectedLanguage = user?.language ?? 'ne';
    setState(() => _isEditing = true);
  }

  void _cancelEditing() => setState(() => _isEditing = false);

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final success = await ref.read(authProvider.notifier).updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          middleName: _middleNameController.text.trim().isEmpty
              ? null
              : _middleNameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          language: _selectedLanguage,
        );

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated' : 'Failed to update profile'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: _isEditing ? _cancelEditing : () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Icon(
                  _isEditing ? Icons.close : Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isEditing
                ? Center(
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : TextButton(
                            onPressed: _hasChanges ? _saveProfile : null,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: _hasChanges
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  )
                : GestureDetector(
                    onTap: _startEditing,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Avatar + name hero ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${user.firstName[0]}${user.lastName[0]}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    if (!_isEditing) ...[
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      if (user.types.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _accountTypeLabel(user.types),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // ── Content ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                child: _isEditing ? _buildEditForm() : _buildViewContent(user),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewContent(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Contact'),
        const SizedBox(height: 12),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email ?? '—',
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone ?? '—',
          ),
        ]),

        const SizedBox(height: 24),

        const _SectionLabel('Account'),
        const SizedBox(height: 12),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: _formatMemberSince(user.createdAt),
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.translate,
            label: 'Language',
            value: user.language == 'ne' ? 'Nepali' : 'English',
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Status',
            value: _statusLabel(user.status),
            valueColor: _statusColor(user.status),
          ),
        ]),

        const SizedBox(height: 24),

        const _SectionLabel('Security'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ChangePasswordScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Name'),
        const SizedBox(height: 12),
        AppTextField(
          controller: _firstNameController,
          label: 'First Name',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'First name is required' : null,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _middleNameController,
          label: 'Middle Name (optional)',
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _lastNameController,
          label: 'Last Name',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Last name is required' : null,
        ),

        const SizedBox(height: 28),

        const _SectionLabel('Contact'),
        const SizedBox(height: 12),
        AppTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _phoneController,
          label: 'Phone',
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 28),

        const _SectionLabel('Preferences'),
        const SizedBox(height: 12),
        _LanguageSelector(
          selected: _selectedLanguage,
          onChanged: (lang) {
            setState(() => _selectedLanguage = lang);
            ref.read(localeProvider.notifier).setLocale(lang);
          },
        ),
      ],
    );
  }

  String _accountTypeLabel(List<String> types) {
    if (types.contains('admin')) return 'Admin';
    if (types.contains('farmer')) return 'Farmer';
    if (types.contains('breeder')) return 'Breeder';
    if (types.contains('feeder')) return 'Feeder';
    return types.first[0].toUpperCase() + types.first.substring(1);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'verified':
        return 'Verified';
      case 'awaiting_user_verification':
        return 'Awaiting Verification';
      case 'awaiting_user_invitation_acceptance':
        return 'Awaiting Invitation';
      case 'awaiting_admin_verification':
        return 'Awaiting Admin Approval';
      case 'rejected':
        return 'Rejected';
      case 'suspended':
        return 'Suspended';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
      case 'suspended':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatMemberSince(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _LangOption(
            label: 'Nepali',
            isSelected: selected == 'ne',
            onTap: () => onChanged('ne'),
          ),
          _LangOption(
            label: 'English',
            isSelected: selected == 'en',
            onTap: () => onChanged('en'),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
