import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/farm.dart';
import '../../data/models/farm_member.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/farm_provider.dart';
import '../../data/services/farm_member_service.dart';
import 'add_member_screen.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  final _service = FarmMemberService();
  final Map<String, List<FarmMember>> _membersByFarm = {};
  final Map<String, List<FarmInvite>> _invitesByFarm = {};
  final Map<String, String> _farmRoles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);

    final farms = ref.read(farmsProvider).farms;
    final user = ref.read(currentUserProvider);

    // Build role lookup
    _farmRoles.clear();
    if (user?.memberships != null) {
      for (final m in user!.memberships!) {
        if (m.entityType == 'farm') _farmRoles[m.entityId] = m.role;
      }
    }

    // Load members for all farms in parallel
    _membersByFarm.clear();
    _invitesByFarm.clear();
    await Future.wait(farms.map((farm) async {
      try {
        final result = await _service.getMembers(farm.id);
        _membersByFarm[farm.id] = result.members;
        _invitesByFarm[farm.id] = result.invites;
      } catch (_) {
        _membersByFarm[farm.id] = [];
        _invitesByFarm[farm.id] = [];
      }
    }));

    if (mounted) setState(() => _isLoading = false);
  }

  String _roleForFarm(String farmId) => _farmRoles[farmId] ?? '';
  bool _canInvite(String farmId) {
    final r = _roleForFarm(farmId);
    return r == 'owner' || r == 'manager';
  }

  bool _isOwnerOf(String farmId) => _roleForFarm(farmId) == 'owner';

  void _openAddMember(Farm farm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemberScreen(
          farmId: farm.id,
          farmName: farm.name,
        ),
      ),
    );
    if (result == true) _loadAll();
  }

  Future<void> _changeRole(Farm farm, FarmMember member) async {
    final newRole = member.role == 'manager' ? 'staff' : 'manager';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Role'),
        content: Text(
          'Change ${member.user.fullName} from '
          '${_roleLabel(member.role)} to ${_roleLabel(newRole)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Change to ${_roleLabel(newRole)}'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await _service.updateRole(farm.id, member.id, newRole);
        _loadAll();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ));
        }
      }
    }
  }

  Future<void> _removeMember(Farm farm, FarmMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Member'),
        content:
            Text('Remove ${member.user.fullName} from ${farm.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await _service.removeMember(farm.id, member.id);
        _loadAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${member.user.fullName} removed'),
            backgroundColor: AppColors.success,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ));
        }
      }
    }
  }

  Future<void> _cancelInvite(Farm farm, FarmInvite invite) async {
    try {
      await _service.cancelInvite(farm.id, invite.id);
      _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invite cancelled'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farms = ref.watch(farmsProvider).farms;

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
          'Team',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
          : farms.isEmpty
              ? const Center(
                  child: Text('No farms yet',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    itemCount: farms.length,
                    itemBuilder: (_, i) =>
                        _buildFarmSection(farms[i]),
                  ),
                ),
    );
  }

  Widget _buildFarmSection(Farm farm) {
    final members = _membersByFarm[farm.id] ?? [];
    final invites = _invitesByFarm[farm.id] ?? [];
    final isOwner = _isOwnerOf(farm.id);
    final canInvite = _canInvite(farm.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_work_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  farm.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (canInvite)
                GestureDetector(
                  onTap: () => _openAddMember(farm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_outlined,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Invite',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Members card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                if (members.isEmpty && invites.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No team members yet',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                    ),
                  )
                else ...[
                  for (int i = 0; i < members.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 1, color: AppColors.border),
                    _MemberRow(
                      member: members[i],
                      isOwner: isOwner,
                      onChangeRole: isOwner && members[i].role != 'owner'
                          ? () => _changeRole(farm, members[i])
                          : null,
                      onRemove: isOwner && members[i].role != 'owner'
                          ? () => _removeMember(farm, members[i])
                          : null,
                    ),
                  ],
                  for (int i = 0; i < invites.length; i++) ...[
                    const Divider(height: 1, color: AppColors.border),
                    _InviteRow(
                      invite: invites[i],
                      canCancel: canInvite,
                      onCancel: () => _cancelInvite(farm, invites[i]),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
        return role;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MemberRow extends StatelessWidget {
  final FarmMember member;
  final bool isOwner;
  final VoidCallback? onChangeRole;
  final VoidCallback? onRemove;

  const _MemberRow({
    required this.member,
    required this.isOwner,
    this.onChangeRole,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.user.initials,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.user.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.user.phone ?? member.user.email ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _roleBgColor(member.role),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _roleLabel(member.role),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _roleColor(member.role),
              ),
            ),
          ),
          if (isOwner && member.role != 'owner') ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppColors.textTertiary, size: 20),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                if (v == 'role') onChangeRole?.call();
                if (v == 'remove') onRemove?.call();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 18),
                      const SizedBox(width: 10),
                      Text(member.role == 'manager'
                          ? 'Change to Staff'
                          : 'Change to Manager'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_outlined,
                          size: 18, color: AppColors.error),
                      SizedBox(width: 10),
                      Text('Remove',
                          style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _roleLabel(String r) {
    switch (r) {
      case 'owner':
        return 'Owner';
      case 'manager':
        return 'Manager';
      default:
        return 'Staff';
    }
  }

  static Color _roleBgColor(String r) {
    switch (r) {
      case 'owner':
        return AppColors.success.withValues(alpha: 0.1);
      case 'manager':
        return AppColors.info.withValues(alpha: 0.1);
      default:
        return AppColors.textSecondary.withValues(alpha: 0.12);
    }
  }

  static Color _roleColor(String r) {
    switch (r) {
      case 'owner':
        return AppColors.success;
      case 'manager':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InviteRow extends StatelessWidget {
  final FarmInvite invite;
  final bool canCancel;
  final VoidCallback onCancel;

  const _InviteRow({
    required this.invite,
    required this.canCancel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.schedule, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.inviteValue,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pending · ${invite.role == 'manager' ? 'Manager' : 'Staff'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (canCancel)
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InviteSheet extends StatefulWidget {
  final String farmId;
  final String farmName;
  final FarmMemberService service;
  final VoidCallback onInvited;

  const _InviteSheet({
    required this.farmId,
    required this.farmName,
    required this.service,
    required this.onInvited,
  });

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  String _contactType = 'phone';
  String _role = 'staff';
  bool _isSending = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      await widget.service.createAndInvite(
        widget.farmId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _contactType == 'email' ? _contactController.text.trim() : null,
        phone: _contactType == 'phone' ? _contactController.text.trim() : null,
        role: _role,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onInvited();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created and added to farm'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 20),
            Text(
              'Add to ${widget.farmName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Name fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary),
                    decoration: _inputDecoration('First Name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary),
                    decoration: _inputDecoration('Last Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contact type toggle
            _ToggleRow(
              options: const ['Phone', 'Email'],
              selected: _contactType == 'phone' ? 0 : 1,
              onChanged: (i) =>
                  setState(() => _contactType = i == 0 ? 'phone' : 'email'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _contactController,
              keyboardType: _contactType == 'phone'
                  ? TextInputType.phone
                  : TextInputType.emailAddress,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textPrimary),
              decoration: _inputDecoration(
                _contactType == 'phone' ? 'Phone Number' : 'Email Address',
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'ROLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            _ToggleRow(
              options: const ['Staff', 'Manager'],
              selected: _role == 'staff' ? 0 : 1,
              onChanged: (i) =>
                  setState(() => _role = i == 0 ? 'staff' : 'manager'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.3),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Add Member',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const _ToggleRow({
    required this.options,
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
          for (int i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        selected == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: selected == i
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
                      options[i],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected == i
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected == i
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
