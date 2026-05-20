import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/banner_model.dart';
import '../cubits/banners_cubit.dart';
import 'banner_form_screen.dart';

class BannersMgmtScreen extends StatefulWidget {
  const BannersMgmtScreen({super.key});

  @override
  State<BannersMgmtScreen> createState() => _BannersMgmtScreenState();
}

class _BannersMgmtScreenState extends State<BannersMgmtScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BannersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text('Banners',
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
      body: BlocConsumer<BannersCubit, BannersState>(
        listener: (context, state) {
          if (state.mutationStatus == BannerMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Operation failed',
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14))),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state.status == BannersStatus.loading && state.banners.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDeep));
          }
          if (state.status == BannersStatus.failure && state.banners.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                SizedBox(height: 12.h),
                Text(state.errorMessage ?? 'Failed to load',
                    style: GoogleFonts.nunito(color: AppColors.textLight)),
                SizedBox(height: 16.h),
                TextButton(
                    onPressed: () => context.read<BannersCubit>().load(),
                    child: const Text('Retry')),
              ]),
            );
          }
          if (state.banners.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.image_outlined, size: 64.r, color: AppColors.primaryLight),
                SizedBox(height: 16.h),
                Text('No banners yet',
                    style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textCharcoal)),
                SizedBox(height: 8.h),
                Text('Tap + to add the first banner',
                    style: GoogleFonts.nunito(color: AppColors.textLight)),
              ]),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.banners.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (ctx, i) => _BannerCard(
              banner: state.banners[i],
              isFirst: i == 0,
              isLast: i == state.banners.length - 1,
              onEdit: () => _openForm(context, state.banners[i]),
              onDelete: () => _confirmDelete(context, state.banners[i]),
            ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, BannerModel? banner) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<BannersCubit>(),
        child: BannerFormScreen(banner: banner),
      ),
    ));
  }

  void _confirmDelete(BuildContext context, BannerModel banner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Banner',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
            'Delete "${banner.title ?? 'this banner'}"? This cannot be undone.',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.nunito())),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BannersCubit>().delete(id: banner.id);
            },
            child: Text('Delete',
                style: GoogleFonts.nunito(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });
  final BannerModel banner;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _actionColor {
    switch (banner.actionType) {
      case BannerActionType.none:       return AppColors.border;
      case BannerActionType.url:        return const Color(0xFF1565C0);
      case BannerActionType.product:    return const Color(0xFF2E7D32);
      case BannerActionType.collection: return const Color(0xFF6A1B9A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
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
      child: Row(children: [
        // Thumbnail
        ClipRRect(
          borderRadius: AppBorderRadius.r8,
          child: SizedBox(
            width: 80.r,
            height: 56.r,
            child: banner.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                    placeholder: (_, __) =>
                        Container(color: AppColors.primaryMist),
                  )
                : _placeholder(),
          ),
        ),
        SizedBox(width: 12.w),
        // Info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              banner.title?.isNotEmpty == true
                  ? banner.title!
                  : 'Banner #${banner.sortOrder}',
              style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w700,
                  color: banner.isActive ? AppColors.textDark : AppColors.textLight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Row(children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _actionColor.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.full,
                  border: Border.all(color: _actionColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  banner.actionType.label,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 10),
                      fontWeight: FontWeight.w700,
                      color: _actionColor),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Order: ${banner.sortOrder}',
                style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 11), color: AppColors.textLight),
              ),
            ]),
          ]),
        ),
        SizedBox(width: 4.w),
        // Controls
        Column(children: [
          // Reorder buttons
          Row(mainAxisSize: MainAxisSize.min, children: [
            _IconBtn(
              icon: Icons.keyboard_arrow_up_rounded,
              enabled: !isFirst,
              onTap: () => context.read<BannersCubit>().moveUp(banner: banner),
            ),
            _IconBtn(
              icon: Icons.keyboard_arrow_down_rounded,
              enabled: !isLast,
              onTap: () => context.read<BannersCubit>().moveDown(banner: banner),
            ),
          ]),
          Switch(
            value: banner.isActive,
            onChanged: (_) =>
                context.read<BannersCubit>().toggleActive(banner: banner),
            activeThumbColor: AppColors.primaryDeep,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _IconBtn(
                icon: Icons.edit_outlined,
                color: AppColors.textLight,
                onTap: onEdit),
            _IconBtn(
                icon: Icons.delete_outline_rounded,
                color: AppColors.error,
                onTap: onDelete),
          ]),
        ]),
      ]),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primaryMist,
        child: Icon(Icons.image_outlined,
            color: AppColors.primaryDeep, size: 24.r),
      );
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.color,
    this.enabled = true,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 18.r,
          color: enabled ? (color ?? AppColors.textLight) : AppColors.border,
        ),
      ),
    );
  }
}
