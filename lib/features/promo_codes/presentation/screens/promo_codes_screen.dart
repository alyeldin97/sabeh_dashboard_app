import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../data/model/promo_code_model.dart';
import '../cubits/promo_codes_cubit.dart';
import 'promo_code_form_screen.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    context.read<PromoCodesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text(l10n.promoCodesTitle,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: 24.r),
            onPressed: () => _openForm(context, null),
          ),
        ],
      ),
      body: BlocConsumer<PromoCodesCubit, PromoCodesState>(
        listener: (context, state) {
          if (state.mutationStatus == PromoMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? l10n.promoCodes_mutationFailed,
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14))),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state.status == PromoCodesStatus.loading && state.codes.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDeep));
          }
          if (state.status == PromoCodesStatus.failure && state.codes.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                SizedBox(height: 12.h),
                Text(state.errorMessage ?? l10n.promoCodesFailedLoad,
                    style: GoogleFonts.nunito(color: AppColors.textLight)),
                SizedBox(height: 16.h),
                TextButton(
                    onPressed: () => context.read<PromoCodesCubit>().load(),
                    child: Text(l10n.promoCodesRetry)),
              ]),
            );
          }

          final now = DateTime.now();
          final filtered = state.codes.where((c) {
            switch (_filter) {
              case _Filter.all:      return true;
              case _Filter.active:   return c.isActive && (c.expiresAt == null || c.expiresAt!.isAfter(now));
              case _Filter.expired:  return c.expiresAt != null && c.expiresAt!.isBefore(now);
              case _Filter.inactive: return !c.isActive;
            }
          }).toList();

          return Column(children: [
            _FilterBar(filter: _filter, onChanged: (f) => setState(() => _filter = f)),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.discount_outlined, size: 64.r, color: AppColors.primaryLight),
                        SizedBox(height: 16.h),
                        Text(l10n.promoCodesEmpty,
                            style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textCharcoal)),
                        SizedBox(height: 8.h),
                        Text(l10n.promoCodesEmptyHint,
                            style: GoogleFonts.nunito(color: AppColors.textLight)),
                      ]),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(16.r),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (ctx, i) => _PromoCard(
                        code: filtered[i],
                        onEdit: () => _openForm(context, filtered[i]),
                        onDelete: () => _confirmDelete(context, filtered[i]),
                      ),
                    ),
            ),
          ]);
        },
      ),
    );
  }

  void _openForm(BuildContext context, PromoCodeModel? code) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<PromoCodesCubit>(),
        child: PromoCodeFormScreen(code: code),
      ),
    ));
  }

  void _confirmDelete(BuildContext context, PromoCodeModel code) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.promoCodesDeleteTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('Delete "${code.code}"? This cannot be undone.',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.promoCodesCancel, style: GoogleFonts.nunito())),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PromoCodesCubit>().delete(id: code.id);
            },
            child: Text(l10n.promoCodesDelete,
                style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

enum _Filter { all, active, expired, inactive }

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filter, required this.onChanged});
  final _Filter filter;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (_Filter.all, l10n.promoCodesFilterAll),
      (_Filter.active, l10n.promoCodesFilterActive),
      (_Filter.expired, l10n.promoCodesFilterExpired),
      (_Filter.inactive, l10n.promoCodesFilterInactive),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: items.map((e) {
          final (f, label) = e;
          final selected = filter == f;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryDeep : AppColors.white,
                  borderRadius: AppBorderRadius.full,
                  border: Border.all(
                      color: selected ? AppColors.primaryDeep : AppColors.border),
                ),
                child: Text(label,
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.white : AppColors.textCharcoal)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.code,
    required this.onEdit,
    required this.onDelete,
  });
  final PromoCodeModel code;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _typeColor {
    switch (code.type) {
      case PromoType.freeDelivery: return const Color(0xFF2E7D32);
      case PromoType.percentage:   return const Color(0xFF1565C0);
      case PromoType.fixed:        return const Color(0xFFE65100);
      case PromoType.bogo:         return const Color(0xFF6A1B9A);
      case PromoType.cashback:     return const Color(0xFF00838F);
    }
  }

  String get _discountLabel {
    switch (code.type) {
      case PromoType.percentage:   return '${code.discountValue.toStringAsFixed(0)}% off';
      case PromoType.fixed:        return 'EGP ${code.discountValue.toStringAsFixed(0)} off';
      case PromoType.freeDelivery: return 'Free Delivery';
      case PromoType.bogo:         return 'BOGO';
      case PromoType.cashback:     return '${code.discountValue.toStringAsFixed(0)} pts';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired =
        code.expiresAt != null && code.expiresAt!.isBefore(DateTime.now());

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Code text
          Expanded(
            child: GestureDetector(
              onTap: () {
                final l10n = AppLocalizations.of(context)!;
                Clipboard.setData(ClipboardData(text: code.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.promoCodesCopied(code.code),
                        style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 13))),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Row(children: [
                Text(
                  code.code,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w800,
                    color: code.isActive && !isExpired
                        ? AppColors.primaryDeep
                        : AppColors.textLight,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.copy_rounded, size: 14.r, color: AppColors.textLight),
              ]),
            ),
          ),
          // Type chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.full,
              border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              code.type.label,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 11),
                  fontWeight: FontWeight.w700,
                  color: _typeColor),
            ),
          ),
        ]),
        SizedBox(height: 8.h),
        // Discount value row
        Row(children: [
          Icon(Icons.local_offer_outlined, size: 14.r, color: AppColors.textLight),
          SizedBox(width: 4.w),
          Text(_discountLabel,
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal)),
          if (code.minOrder > 0) ...[
            Text(' · Min EGP ${code.minOrder.toStringAsFixed(0)}',
                style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 12), color: AppColors.textLight)),
          ],
        ]),
        SizedBox(height: 4.h),
        // Usage + expiry row
        Row(children: [
          Icon(Icons.people_outline_rounded, size: 14.r, color: AppColors.textLight),
          SizedBox(width: 4.w),
          Text(
            code.maxUses == null
                ? '${code.usedCount} / ∞ uses'
                : '${code.usedCount} / ${code.maxUses} uses',
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
          ),
          if (code.expiresAt != null) ...[
            SizedBox(width: 12.w),
            Icon(
              isExpired ? Icons.timer_off_outlined : Icons.schedule_outlined,
              size: 14.r,
              color: isExpired ? AppColors.error : AppColors.textLight,
            ),
            SizedBox(width: 4.w),
            Text(
              'Expires ${DateFormat('MMM d, y').format(code.expiresAt!)}',
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  color: isExpired ? AppColors.error : AppColors.textLight),
            ),
          ],
        ]),
        if (code.description != null && code.description!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            code.description!,
            style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const Divider(height: 20),
        Row(children: [
          Switch(
            value: code.isActive,
            onChanged: (_) => context.read<PromoCodesCubit>().toggleActive(code: code),
            activeThumbColor: AppColors.primaryDeep,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(code.isActive ? 'Active' : 'Inactive',
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  color: code.isActive ? AppColors.primaryDeep : AppColors.textLight)),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18.r, color: AppColors.textLight),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 12.w),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 18.r, color: AppColors.error),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ]),
      ]),
    );
  }
}
