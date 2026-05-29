import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../data/model/category.dart';
import '../cubits/categories_cubit.dart';
import 'category_form_screen.dart';

class CategoriesMgmtScreen extends StatelessWidget {
  const CategoriesMgmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branchId = context.read<AuthCubit>().state.user?.branchId;
    return BlocProvider(
      create: (_) => DependencyInjector().categoriesCubit..load(branchId: branchId),
      child: _CategoriesView(branchId: branchId),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView({this.branchId});
  final String? branchId;

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.categoriesTitle, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 20), fontWeight: FontWeight.w700, color: AppColors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.white),
            onPressed: () => context.read<CategoriesCubit>().load(branchId: widget.branchId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories_fab',
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.categoriesAddCategory, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        onPressed: () => _openForm(context, null),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_search.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.drag_indicator_rounded, size: 16.r, color: AppColors.textLight),
                  SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.categoriesDragReorder,
                    style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 12), color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        onChanged: (v) => setState(() => _search = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.categoriesSearchHint,
          hintStyle: GoogleFonts.nunito(color: AppColors.textLight, fontSize: Responsive.sp(context, 14)),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.scaffoldBg,
          border: OutlineInputBorder(borderRadius: AppBorderRadius.full, borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state.status == CategoriesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == CategoriesStatus.failure) {
          return Center(child: Text(state.errorMessage ?? 'Error', style: TextStyle(color: AppColors.textLight)));
        }

        final isFiltering = _search.isNotEmpty;
        final cats = isFiltering
            ? state.categories.where((c) => c.name.toLowerCase().contains(_search)).toList()
            : state.categories;

        if (cats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view_rounded, size: 64.r, color: AppColors.primaryLight),
                SizedBox(height: 16.h),
                Text(AppLocalizations.of(context)!.categoriesEmpty, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.w700, color: AppColors.textCharcoal)),
                SizedBox(height: 8.h),
                Text(AppLocalizations.of(context)!.categoriesEmptyHint, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 14), color: AppColors.textLight)),
              ],
            ),
          );
        }

        if (isFiltering) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cats.length,
            itemBuilder: (_, i) => _CategoryTile(
              key: ValueKey(cats[i].id),
              category: cats[i],
              index: i,
              draggable: false,
              onEdit: () => _openForm(context, cats[i]),
              onDelete: () => _confirmDelete(context, cats[i]),
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          onReorder: (oldIndex, newIndex) =>
              context.read<CategoriesCubit>().reorder(oldIndex, newIndex, branchId: widget.branchId),
          proxyDecorator: (child, _, animation) => AnimatedBuilder(
            animation: animation,
            builder: (_, c) => Material(
              elevation: 8 * animation.value,
              borderRadius: AppBorderRadius.r12,
              color: Colors.transparent,
              child: c,
            ),
            child: child,
          ),
          itemCount: cats.length,
          itemBuilder: (_, i) => _CategoryTile(
            key: ValueKey(cats[i].id),
            category: cats[i],
            index: i,
            draggable: true,
            onEdit: () => _openForm(context, cats[i]),
            onDelete: () => _confirmDelete(context, cats[i]),
          ),
        );
      },
    );
  }

  void _openForm(BuildContext context, Category? category) {
    final cubit = context.read<CategoriesCubit>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CategoryFormScreen(category: category, branchId: widget.branchId),
      ),
    ));
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
        title: Text(AppLocalizations.of(context)!.categoriesDeleteTitle, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(AppLocalizations.of(context)!.categoriesDeleteConfirm(category.name), style: GoogleFonts.nunito(color: AppColors.textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.categoriesCancel, style: GoogleFonts.nunito(color: AppColors.textLight))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<CategoriesCubit>().delete(id: category.id, branchId: widget.branchId);
            },
            child: Text(AppLocalizations.of(context)!.categoriesDelete, style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    super.key,
    required this.category,
    required this.index,
    required this.draggable,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final int index;
  final bool draggable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        leading: ClipRRect(
          borderRadius: AppBorderRadius.r8,
          child: SizedBox(
            width: 56.r,
            height: 56.r,
            child: category.imageUrl != null
                ? Image.network(
                    category.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        title: Text(
          category.name,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: Responsive.sp(context, 15), color: AppColors.textDark),
        ),
        subtitle: category.branchIds.isNotEmpty || !category.isActive
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: [
                    if (category.branchIds.isNotEmpty)
                      _buildBranchChip(context, category.branchIds.length),
                    if (!category.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: AppBorderRadius.r8),
                        child: Text(AppLocalizations.of(context)!.categoriesInactive, style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w700, color: AppColors.error)),
                      ),
                  ],
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(icon: Icons.edit_outlined, color: AppColors.primaryDeep, onTap: onEdit),
            const SizedBox(width: 4),
            _ActionButton(icon: Icons.delete_outline_rounded, color: AppColors.error, onTap: onDelete),
            if (draggable) ...[
              const SizedBox(width: 4),
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  width: 30.r,
                  height: 30.r,
                  alignment: Alignment.center,
                  child: Icon(Icons.drag_handle_rounded, size: 20.r, color: AppColors.textLight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primaryMist,
        child: Center(child: Icon(Icons.grid_view_rounded, color: AppColors.primaryLight, size: 28.r)),
      );

  Widget _buildBranchChip(BuildContext context, int count) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.primaryMist, borderRadius: AppBorderRadius.r8),
        child: Text(
          '$count ${count == 1 ? 'branch' : 'branches'}',
          style: GoogleFonts.nunito(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w700, color: AppColors.primaryDeep),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.r, height: 30.r,
        decoration: BoxDecoration(color: Colors.white, borderRadius: AppBorderRadius.r8,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
        child: Icon(icon, size: 16.r, color: color),
      ),
    );
  }
}
