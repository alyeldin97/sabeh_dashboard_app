import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../data/model/branch_model.dart';
import '../cubits/branches_cubit.dart';
import '../../../delivery_zones/data/model/delivery_zone_model.dart';
import '../../../delivery_zones/presentation/cubits/delivery_zones_cubit.dart';
import 'branch_form_screen.dart';

class BranchesMgmtScreen extends StatefulWidget {
  const BranchesMgmtScreen({super.key});

  @override
  State<BranchesMgmtScreen> createState() => _BranchesMgmtScreenState();
}

class _BranchesMgmtScreenState extends State<BranchesMgmtScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BranchesCubit>().load();
    context.read<DeliveryZonesCubit>().load();
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
          AppLocalizations.of(context)!.branchesTitle,
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
            tooltip: AppLocalizations.of(context)!.branchesAddTooltip,
          ),
        ],
      ),
      body: BlocConsumer<BranchesCubit, BranchesState>(
        listener: (context, state) {
          if (state.mutationStatus == BranchMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  state.errorMessage ??
                      AppLocalizations.of(context)!.branchesMutationFailed,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 14))),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, branchState) {
          if (branchState.status == BranchesStatus.loading &&
              branchState.branches.isEmpty) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryDeep));
          }
          if (branchState.status == BranchesStatus.failure &&
              branchState.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                  SizedBox(height: 12.h),
                  Text(
                      branchState.errorMessage ??
                          AppLocalizations.of(context)!.branchesFailedLoad,
                      style: GoogleFonts.nunito(color: AppColors.textLight)),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => context.read<BranchesCubit>().load(),
                    child: Text(AppLocalizations.of(context)!.branchesRetry),
                  ),
                ],
              ),
            );
          }
          if (branchState.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store_outlined,
                      size: 64.r, color: AppColors.primaryLight),
                  SizedBox(height: 16.h),
                  Text(
                      AppLocalizations.of(context)!.branchesEmpty,
                      style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 18),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textCharcoal)),
                  SizedBox(height: 8.h),
                  Text(AppLocalizations.of(context)!.branchesEmptyHint,
                      style: GoogleFonts.nunito(color: AppColors.textLight)),
                ],
              ),
            );
          }

          return BlocBuilder<DeliveryZonesCubit, DeliveryZonesState>(
            builder: (context, zoneState) {
              return ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: branchState.branches.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) => _BranchCard(
                  branch: branchState.branches[i],
                  allZones: zoneState.zones,
                  onEdit: () =>
                      _openForm(context, branchState.branches[i]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, BranchModel? branch) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<BranchesCubit>(),
        child: BranchFormScreen(branch: branch),
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BranchCard extends StatefulWidget {
  const _BranchCard({
    required this.branch,
    required this.allZones,
    required this.onEdit,
  });
  final BranchModel branch;
  final List<DeliveryZoneModel> allZones;
  final VoidCallback onEdit;

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  bool _expanded = false;

  List<DeliveryZoneModel> get _assignedZones =>
      widget.allZones.where((z) => z.branchId == widget.branch.id).toList();

  List<DeliveryZoneModel> get _unassignedZones =>
      widget.allZones.where((z) => z.branchId == null).toList();

  List<DeliveryZoneModel> get _otherBranchZones => widget.allZones
      .where((z) => z.branchId != null && z.branchId != widget.branch.id)
      .toList();

  Future<void> _toggle(DeliveryZoneModel zone, bool assign) async {
    final cubit = context.read<DeliveryZonesCubit>();
    await cubit.assignBranch(zone.id, assign ? widget.branch.id : null);
  }

  @override
  Widget build(BuildContext context) {
    final assignedCount = _assignedZones.length;

    return Container(
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
      child: Column(
        children: [
          // ── Branch header row ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: widget.branch.isActive
                        ? AppColors.primaryMist
                        : AppColors.border,
                    borderRadius: AppBorderRadius.r12,
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: widget.branch.isActive
                        ? AppColors.primaryDeep
                        : AppColors.textLight,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.branch.name,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$assignedCount zone${assignedCount == 1 ? '' : 's'} assigned',
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 12),
                          color: assignedCount > 0
                              ? AppColors.primaryDeep
                              : AppColors.textLight,
                          fontWeight: assignedCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.branch.isActive,
                  onChanged: (_) => context
                      .read<BranchesCubit>()
                      .toggleActive(branch: widget.branch),
                  activeThumbColor: AppColors.primaryDeep,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                GestureDetector(
                  onTap: widget.onEdit,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined,
                        size: 18.r, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22.r, color: AppColors.textLight),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Expandable zones section ──────────────────────────────────
          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assigned zones
                  if (_assignedZones.isNotEmpty) ...[
                    _SectionLabel('مناطق التوصيل · Assigned Zones',
                        AppColors.primaryDeep),
                    const SizedBox(height: 6),
                    ..._assignedZones.map((z) => _ZoneRow(
                          zone: z,
                          checked: true,
                          subtitle: null,
                          onChanged: (v) => _toggle(z, v),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Unassigned zones
                  if (_unassignedZones.isNotEmpty) ...[
                    _SectionLabel('غير مخصصة · Unassigned Zones',
                        Colors.grey.shade500),
                    const SizedBox(height: 6),
                    ..._unassignedZones.map((z) => _ZoneRow(
                          zone: z,
                          checked: false,
                          subtitle: null,
                          onChanged: (v) => _toggle(z, v),
                        )),
                  ],

                  // Other-branch zones (read-only hint)
                  if (_otherBranchZones.isNotEmpty) ...[
                    if (_assignedZones.isNotEmpty || _unassignedZones.isNotEmpty)
                      const SizedBox(height: 12),
                    _SectionLabel('في فرع آخر · In Another Branch',
                        Colors.orange.shade700),
                    const SizedBox(height: 6),
                    ..._otherBranchZones.map((z) => _ZoneRow(
                      zone: z,
                      checked: false,
                      subtitle: 'assigned elsewhere',
                      subtitleColor: Colors.orange.shade600,
                      onChanged: (v) => _toggle(z, v),
                    )),
                  ],

                  if (widget.allZones.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'No delivery zones found. Create zones first.',
                        style: GoogleFonts.nunito(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({
    required this.zone,
    required this.checked,
    required this.onChanged,
    this.subtitle,
    this.subtitleColor,
  });
  final DeliveryZoneModel zone;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.primaryDeep,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.nameAr != null
                        ? '${zone.name}  ·  ${zone.nameAr}'
                        : zone.name,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: subtitleColor ?? Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            // Fee chips
            _FeeChip(
              label: 'User: EGP ${zone.userPaidDeliveryFees.toStringAsFixed(0)}',
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 6),
            _FeeChip(
              label: 'Driver: EGP ${zone.deliveryFeesPaidToDriver.toStringAsFixed(0)}',
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeChip extends StatelessWidget {
  const _FeeChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: color,
        ),
      );
}
