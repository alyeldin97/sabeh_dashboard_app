import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../../branches/presentation/cubits/branches_cubit.dart';
import '../../data/model/staff_member.dart';
import '../cubits/staff_cubit.dart';
import 'staff_form_screen.dart';

class StaffMgmtScreen extends StatefulWidget {
  const StaffMgmtScreen({super.key});

  @override
  State<StaffMgmtScreen> createState() => _StaffMgmtScreenState();
}

class _StaffMgmtScreenState extends State<StaffMgmtScreen> {
  StaffRole? _filterRole;

  @override
  void initState() {
    super.initState();
    context.read<StaffCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.staffTitle,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: 24.r),
            onPressed: () => _openForm(context, null),
            tooltip: AppLocalizations.of(context)!.staffAddTooltip,
          ),
        ],
      ),
      body: BlocConsumer<StaffCubit, StaffState>(
        listener: (context, state) {
          if (state.mutationStatus == StaffMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? AppLocalizations.of(context)!.staffMutationFailed,
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14))),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state.status == StaffStatus.loading && state.members.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDeep));
          }
          if (state.status == StaffStatus.failure && state.members.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                  SizedBox(height: 12.h),
                  Text(state.errorMessage ?? AppLocalizations.of(context)!.staffFailedLoad,
                      style: GoogleFonts.nunito(color: AppColors.textLight)),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => context.read<StaffCubit>().load(),
                    child: Text(AppLocalizations.of(context)!.staffRetry),
                  ),
                ],
              ),
            );
          }

          final filtered = _filterRole == null
              ? state.members
              : state.members.where((m) => m.role == _filterRole).toList();

          return Column(
            children: [
              _RoleFilterChips(
                selected: _filterRole,
                onChanged: (r) => setState(() => _filterRole = r),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 64.r, color: AppColors.primaryLight),
                            SizedBox(height: 16.h),
                            Text(AppLocalizations.of(context)!.staffEmpty,
                                style: GoogleFonts.nunito(
                                    fontSize: Responsive.sp(context, 18),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textCharcoal)),
                            SizedBox(height: 8.h),
                            Text(AppLocalizations.of(context)!.staffEmptyHint,
                                style: GoogleFonts.nunito(color: AppColors.textLight)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(16.r),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (ctx, i) => _StaffCard(
                          member: filtered[i],
                          onEdit: () => _openForm(context, filtered[i]),
                          onDelete: () => _confirmDelete(context, filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, StaffMember? member) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<StaffCubit>()),
          BlocProvider<BranchesCubit>(create: (_) => DependencyInjector().branchesCubit..load()),
        ],
        child: StaffFormScreen(member: member),
      ),
    ));
  }

  void _confirmDelete(BuildContext context, StaffMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.staffRemoveTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          AppLocalizations.of(context)!.staffRemoveConfirm(member.name),
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.staffCancel, style: GoogleFonts.nunito()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StaffCubit>().delete(id: member.id);
            },
            child: Text(AppLocalizations.of(context)!.staffRemove,
                style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _RoleFilterChips extends StatelessWidget {
  const _RoleFilterChips({required this.selected, required this.onChanged});
  final StaffRole? selected;
  final ValueChanged<StaffRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _Chip(label: AppLocalizations.of(context)!.staffFilterAll, isSelected: selected == null, onTap: () => onChanged(null)),
          SizedBox(width: 8.w),
          ...StaffRole.values.map((r) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _Chip(
                  label: r.label,
                  isSelected: selected == r,
                  onTap: () => onChanged(r),
                ),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDeep : AppColors.white,
          borderRadius: AppBorderRadius.full,
          border: Border.all(
              color: isSelected ? AppColors.primaryDeep : AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 12),
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textCharcoal,
          ),
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });
  final StaffMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: member.isActive ? AppColors.primaryDeep : AppColors.border,
              borderRadius: AppBorderRadius.r12,
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 20),
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w700,
                          color: member.isActive ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ),
                    _RoleChip(role: member.role),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  member.email,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 12),
                    color: AppColors.textLight,
                  ),
                ),
                if (member.branchId != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.store_outlined, size: 12.r, color: AppColors.textLight),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context)!.staffBranchScoped,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 11),
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Actions
          Column(
            children: [
              Switch(
                value: member.isActive,
                onChanged: (_) =>
                    context.read<StaffCubit>().toggleActive(member: member),
                activeThumbColor: AppColors.primaryDeep,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.edit_outlined, size: 18.r, color: AppColors.textLight),
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline_rounded, size: 18.r, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final StaffRole role;

  Color get _color {
    switch (role) {
      case StaffRole.admin:           return const Color(0xFF7B1FA2);
      case StaffRole.manager:         return const Color(0xFF1565C0);
      case StaffRole.customerService: return const Color(0xFF00838F);
      case StaffRole.deliveryManager: return const Color(0xFFE65100);
      case StaffRole.deliveryUser:    return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.full,
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        role.label,
        style: GoogleFonts.nunito(
          fontSize: Responsive.sp(context, 10),
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
