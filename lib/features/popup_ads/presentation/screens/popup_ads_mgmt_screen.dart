import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../data/model/popup_ad_model.dart';
import '../cubits/popup_ads_cubit.dart';
import '../cubits/popup_ads_state.dart';
import 'popup_ad_form_screen.dart';

class PopupAdsMgmtScreen extends StatelessWidget {
  const PopupAdsMgmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjector().popupAdsCubit..load(),
      child: const _PopupAdsMgmtView(),
    );
  }
}

class _PopupAdsMgmtView extends StatelessWidget {
  const _PopupAdsMgmtView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.popupAdsTitle, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: BlocBuilder<PopupAdsCubit, PopupAdsState>(
        builder: (context, state) {
          if (state.status == PopupAdsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.ads.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign_outlined, size: 64.r, color: AppColors.textLight),
                  SizedBox(height: 12.h),
                  Text(l10n.popupAdsEmpty, style: GoogleFonts.nunito(color: AppColors.textLight, fontSize: Responsive.sp(context, 15))),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.popupAdsCreate),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDeep, foregroundColor: AppColors.white),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.ads.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (ctx, i) => _AdTile(ad: state.ads[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primaryDeep,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<PopupAdsCubit>(),
        child: const PopupAdFormScreen(),
      ),
    ));
  }
}

class _AdTile extends StatelessWidget {
  const _AdTile({required this.ad});
  final PopupAdModel ad;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PopupAdsCubit>();
    final fmt = DateFormat('MMM d, yyyy');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(
          color: ad.isActive ? AppColors.primaryLight.withValues(alpha: 0.4) : AppColors.border,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.h),
        leading: Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: ad.isActive ? AppColors.primaryMist : AppColors.scaffoldBg,
            borderRadius: AppBorderRadius.r8,
          ),
          child: Icon(
            Icons.campaign_outlined,
            color: ad.isActive ? AppColors.primaryDeep : AppColors.textLight,
            size: 24.r,
          ),
        ),
        title: Text(
          ad.title,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: Responsive.sp(context, 14)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ad.bodyText != null)
              Text(ad.bodyText!, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight)),
            if (ad.endsAt != null)
              Text(l10n.popupAdsEnds(fmt.format(ad.endsAt!)),
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 11), color: AppColors.textLight)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: ad.isActive,
              activeColor: AppColors.primaryDeep,
              onChanged: (_) => cubit.toggleActive(ad: ad),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: PopupAdFormScreen(ad: ad),
                    ),
                  ));
                } else if (v == 'delete') {
                  _confirmDelete(context, cubit);
                }
              },
              itemBuilder: (_) {
                final l10n = AppLocalizations.of(context)!;
                return [
                  PopupMenuItem(value: 'edit', child: Text(l10n.popupAdsEdit)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.popupAdsDelete, style: const TextStyle(color: Colors.red))),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PopupAdsCubit cubit) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.popupAdsDeleteTitle),
        content: Text('This will permanently delete "${ad.title}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.popupAdsCancel)),
          TextButton(
            onPressed: () {
              cubit.delete(id: ad.id);
              Navigator.pop(context);
            },
            child: Text(l10n.popupAdsDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
