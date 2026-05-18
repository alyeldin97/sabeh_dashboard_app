import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/branch_model.dart';
import '../cubits/branches_cubit.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        title: Text(
          'Branches',
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
            tooltip: 'Add Branch',
          ),
        ],
      ),
      body: BlocConsumer<BranchesCubit, BranchesState>(
        listener: (context, state) {
          if (state.mutationStatus == BranchMutationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Operation failed',
                  style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14))),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          if (state.status == BranchesStatus.loading && state.branches.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDeep));
          }
          if (state.status == BranchesStatus.failure && state.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                  SizedBox(height: 12.h),
                  Text(state.errorMessage ?? 'Failed to load branches',
                      style: GoogleFonts.nunito(color: AppColors.textLight)),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => context.read<BranchesCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store_outlined, size: 64.r, color: AppColors.primaryLight),
                  SizedBox(height: 16.h),
                  Text('No branches yet',
                      style: GoogleFonts.nunito(
                          fontSize: Responsive.sp(context, 18),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textCharcoal)),
                  SizedBox(height: 8.h),
                  Text('Tap + to add the first branch',
                      style: GoogleFonts.nunito(color: AppColors.textLight)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.branches.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) =>
                _BranchCard(branch: state.branches[i], onEdit: () => _openForm(context, state.branches[i])),
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

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.onEdit});
  final BranchModel branch;
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
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: branch.isActive ? AppColors.primaryMist : AppColors.border,
              borderRadius: AppBorderRadius.r12,
            ),
            child: Icon(
              Icons.store_rounded,
              color: branch.isActive ? AppColors.primaryDeep : AppColors.textLight,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Coverage: ${branch.coverageRadius.toStringAsFixed(1)} km  •  '
                  '${branch.lat.toStringAsFixed(4)}, ${branch.lng.toStringAsFixed(4)}',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 12),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: branch.isActive,
                onChanged: (_) => context.read<BranchesCubit>().toggleActive(branch: branch),
                activeThumbColor: AppColors.primaryDeep,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              GestureDetector(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18.r, color: AppColors.textLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
