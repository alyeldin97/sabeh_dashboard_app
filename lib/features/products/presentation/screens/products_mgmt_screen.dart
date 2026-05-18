import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../categories/presentation/cubits/categories_cubit.dart';
import '../../data/model/product.dart';
import '../cubits/products_cubit.dart';
import 'product_form_screen.dart';

class ProductsMgmtScreen extends StatelessWidget {
  const ProductsMgmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branchId = context.read<AuthCubit>().state.user?.branchId;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              DependencyInjector().productsCubit..load(branchId: branchId),
        ),
        BlocProvider(
          create: (_) =>
              DependencyInjector().categoriesCubit..load(branchId: branchId),
        ),
      ],
      child: _ProductsMgmtView(branchId: branchId),
    );
  }
}

class _ProductsMgmtView extends StatefulWidget {
  const _ProductsMgmtView({this.branchId});
  final String? branchId;

  @override
  State<_ProductsMgmtView> createState() => _ProductsMgmtViewState();
}

class _ProductsMgmtViewState extends State<_ProductsMgmtView> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        title: Text(
          'Products',
          style: GoogleFonts.nunito(
            fontSize: Responsive.sp(context, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.white),
            onPressed: () =>
                context.read<ProductsCubit>().load(branchId: widget.branchId),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'products_fab',
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Product',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        onPressed: () => _openForm(context, null),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
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
          hintText: 'Search products...',
          hintStyle: GoogleFonts.nunito(
            color: AppColors.textLight,
            fontSize: Responsive.sp(context, 14),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.scaffoldBg,
          border: OutlineInputBorder(
            borderRadius: AppBorderRadius.full,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ProductsStatus.failure) {
          return Center(
            child: Text(
              state.errorMessage ?? 'Error',
              style: TextStyle(color: AppColors.textLight),
            ),
          );
        }

        final products = _search.isEmpty
            ? state.products
            : state.products
                  .where((p) => p.name.toLowerCase().contains(_search))
                  .toList();

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64.r,
                  color: AppColors.primaryLight,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No products yet',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textCharcoal,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap + to add your first product',
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 14),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        final crossAxisCount = Responsive.listGridCrossAxisCount(context);
        if (crossAxisCount == 1) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ProductTile(
              product: products[i],
              branchId: widget.branchId,
              onEdit: () => _openForm(context, products[i]),
              onDelete: () => _confirmDelete(context, products[i]),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.0,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => _ProductTile(
            product: products[i],
            branchId: widget.branchId,
            onEdit: () => _openForm(context, products[i]),
            onDelete: () => _confirmDelete(context, products[i]),
          ),
        );
      },
    );
  }

  void _openForm(BuildContext context, Product? product) {
    final cubit = context.read<ProductsCubit>();
    final catCubit = context.read<CategoriesCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider.value(value: catCubit),
          ],
          child: ProductFormScreen(product: product, branchId: widget.branchId),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
        title: Text(
          'Delete Product',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${product.name}"? This will deactivate it.',
          style: GoogleFonts.nunito(color: AppColors.textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: AppColors.textLight),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ProductsCubit>().delete(
                id: product.id,
                branchId: widget.branchId,
              );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.nunito(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    this.branchId,
    required this.onEdit,
    required this.onDelete,
  });
  final Product product;
  final String? branchId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
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
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
            child: product.primaryImage != null
                ? CachedNetworkImage(
                    imageUrl: product.primaryImage!,
                    width: 72.r,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.isActive
                              ? AppColors.primaryMist
                              : const Color(0xFFFFEBEE),
                          borderRadius: AppBorderRadius.r8,
                        ),
                        child: Text(
                          product.isActive ? 'Active' : 'Off',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 10),
                            fontWeight: FontWeight.w700,
                            color: product.isActive
                                ? AppColors.primaryDeep
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'EGP ${product.price.toStringAsFixed(2)} · ${product.type.label}',
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 12),
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18.r,
                  color: AppColors.primaryMid,
                ),
                onPressed: onEdit,
                padding: EdgeInsets.all(8.r),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18.r,
                  color: AppColors.error,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.all(8.r),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 72.r,
        height: double.infinity,
        color: AppColors.primaryMist,
        child: Icon(Icons.eco_rounded, color: AppColors.primaryLight, size: 28.r),
      );
}
