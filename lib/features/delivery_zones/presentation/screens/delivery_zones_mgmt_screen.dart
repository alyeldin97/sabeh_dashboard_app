import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/delivery_zone_model.dart';
import '../cubits/delivery_zones_cubit.dart';
import 'delivery_zone_form_screen.dart';

class DeliveryZonesMgmtScreen extends StatefulWidget {
  const DeliveryZonesMgmtScreen({super.key});

  @override
  State<DeliveryZonesMgmtScreen> createState() => _DeliveryZonesMgmtScreenState();
}

class _DeliveryZonesMgmtScreenState extends State<DeliveryZonesMgmtScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeliveryZonesCubit>().load();
  }

  void _openForm(BuildContext context, [DeliveryZoneModel? zone]) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<DeliveryZonesCubit>(),
        child: DeliveryZoneFormScreen(zone: zone),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text(
          'Delivery Zones',
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 18),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: 24.r),
            onPressed: () => _openForm(context),
            tooltip: 'Add Zone',
          ),
        ],
      ),
      body: BlocConsumer<DeliveryZonesCubit, DeliveryZonesState>(
        listener: (context, state) {
          if (state.mutationStatus == ZoneMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Operation failed',
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14))),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state.status == ZonesStatus.loading && state.zones.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDeep));
          }
          if (state.status == ZonesStatus.failure && state.zones.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                  SizedBox(height: 12.h),
                  Text(state.errorMessage ?? 'Failed to load zones',
                      style: GoogleFonts.nunito(color: AppColors.textLight)),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => context.read<DeliveryZonesCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.zones.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 64.r, color: AppColors.primaryLight),
                  SizedBox(height: 16.h),
                  Text('No delivery zones',
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textCharcoal,
                      )),
                  SizedBox(height: 8.h),
                  Text('Tap + to add the first zone',
                      style: GoogleFonts.nunito(color: AppColors.textLight)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.zones.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => _ZoneCard(
              zone: state.zones[i],
              onEdit: () => _openForm(context, state.zones[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({required this.zone, required this.onEdit});
  final DeliveryZoneModel zone;
  final VoidCallback onEdit;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: zone.isActive ? AppColors.primaryMist : AppColors.border,
              borderRadius: AppBorderRadius.r12,
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: zone.isActive ? AppColors.primaryDeep : AppColors.textLight,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      zone.name,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (zone.nameAr != null) ...[
                      SizedBox(width: 6.w),
                      Text(
                        zone.nameAr!,
                        style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 13),
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (!zone.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: AppBorderRadius.full,
                        ),
                        child: Text('Inactive',
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 10),
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _Chip(
                      icon: Icons.delivery_dining_outlined,
                      label: 'EGP ${zone.deliveryFee.toStringAsFixed(0)} delivery',
                      color: AppColors.primaryDeep,
                    ),
                    if (zone.minOrderValue > 0)
                      _Chip(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Min EGP ${zone.minOrderValue.toStringAsFixed(0)}',
                        color: const Color(0xFF6A1B9A),
                      ),
                    if (zone.minRiderQuantity > 0)
                      _Chip(
                        icon: Icons.inventory_2_outlined,
                        label: 'Min ${zone.minRiderQuantity} items',
                        color: const Color(0xFF1565C0),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.edit_outlined, size: 20.r, color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 11),
                fontWeight: FontWeight.w700,
                color: color,
              )),
        ],
      ),
    );
  }
}
