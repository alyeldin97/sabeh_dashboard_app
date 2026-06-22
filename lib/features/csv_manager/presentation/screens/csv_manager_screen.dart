import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/styling/colors.dart';
import '../cubits/csv_manager_cubit.dart';
import '../cubits/csv_manager_state.dart';

class CsvManagerScreen extends StatelessWidget {
  const CsvManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDeep,
          automaticallyImplyLeading: false,
          title: Text(
            l10n.csvTitle,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.white,
            labelColor: AppColors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: [
              Tab(text: l10n.csvTabProducts),
              Tab(text: l10n.csvTabCustomers),
              Tab(text: l10n.csvTabOrders),
            ],
          ),
        ),
        body: BlocConsumer<CsvManagerCubit, CsvManagerState>(
          listener: (context, state) {
            final msg = state.successMessage;
            final err = state.errorMessage;
            if (msg != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg, style: GoogleFonts.nunito()),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (err != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(err, style: GoogleFonts.nunito()),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 6),
                ),
              );
            }
          },
          builder: (context, state) {
            return TabBarView(
              children: [
                _ProductsTab(state: state),
                _CustomersTab(state: state),
                _OrdersTab(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Products Tab ─────────────────────────────────────────────────────────────

class _ProductsTab extends StatelessWidget {
  const _ProductsTab({required this.state});
  final CsvManagerState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CsvManagerCubit>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionCard(
          icon: Icons.upload_file_rounded,
          title: 'Export Products',
          description:
              'Download all products as a Shopify-compatible CSV file. '
              'Includes variants, options, pricing, and inventory totals.',
          actionLabel: 'Export CSV',
          isLoading: state.productsExport == CsvOp.loading,
          isSuccess: state.productsExport == CsvOp.success,
          onTap: cubit.exportProducts,
          color: AppColors.primaryDeep,
        ),
        const SizedBox(height: 20),
        _SectionCard(
          icon: Icons.download_rounded,
          title: 'Import Products',
          description:
              'Import products from a Shopify-format CSV file. '
              'Supports variants with up to 3 option dimensions. '
              'A preview will be shown before committing.',
          actionLabel: 'Pick CSV File',
          isLoading: state.productsImport == CsvOp.loading,
          isSuccess: state.productsImport == CsvOp.success,
          onTap: cubit.pickProductsFile,
          color: Colors.teal.shade700,
        ),
        if (state.productImportPreview != null) ...[
          const SizedBox(height: 20),
          _ImportPreviewCard(
            title: 'Product Import Preview',
            rowCount: state.productImportPreview!.length,
            rowLabels: state.productImportPreview!
                .map((p) => (p['fields'] as Map<String, dynamic>)['name']?.toString() ?? '?')
                .toList(),
            onCommit: cubit.commitProductsImport,
            onCancel: cubit.cancelProductsImport,
            isLoading: state.productsImport == CsvOp.loading,
          ),
        ],
        const SizedBox(height: 32),
        _ShopifyFormatNote(
          headers: const [
            'Handle', 'Title', 'Body (HTML)', 'Type', 'Published',
            'Option1 Name', 'Option1 Value', 'Option2 Name', 'Option2 Value',
            'Option3 Name', 'Option3 Value',
            'Variant Price', 'Variant Compare At Price',
            'Variant Inventory Qty', 'Image Src', 'Status',
          ],
        ),
      ],
    );
  }
}

// ─── Customers Tab ────────────────────────────────────────────────────────────

class _CustomersTab extends StatelessWidget {
  const _CustomersTab({required this.state});
  final CsvManagerState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CsvManagerCubit>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionCard(
          icon: Icons.upload_file_rounded,
          title: 'Export Customers',
          description:
              'Download all customers as a Shopify-compatible CSV file. '
              'Includes name, email, phone, spend totals, order count, and notes.',
          actionLabel: 'Export CSV',
          isLoading: state.customersExport == CsvOp.loading,
          isSuccess: state.customersExport == CsvOp.success,
          onTap: cubit.exportCustomers,
          color: AppColors.primaryDeep,
        ),
        const SizedBox(height: 20),
        _SectionCard(
          icon: Icons.download_rounded,
          title: 'Import Customers',
          description:
              'Import customers from a Shopify-format CSV file. '
              'Maps First Name + Last Name → name, Email, and Phone. '
              'A preview will be shown before committing.',
          actionLabel: 'Pick CSV File',
          isLoading: state.customersImport == CsvOp.loading,
          isSuccess: state.customersImport == CsvOp.success,
          onTap: cubit.pickCustomersFile,
          color: Colors.teal.shade700,
        ),
        if (state.customerImportPreview != null) ...[
          const SizedBox(height: 20),
          _ImportPreviewCard(
            title: 'Customer Import Preview',
            rowCount: state.customerImportPreview!.length,
            rowLabels: state.customerImportPreview!
                .map((c) => '${c['name'] ?? ''} ${c['email'] ?? ''}'.trim())
                .toList(),
            onCommit: cubit.commitCustomersImport,
            onCancel: cubit.cancelCustomersImport,
            isLoading: state.customersImport == CsvOp.loading,
          ),
        ],
        const SizedBox(height: 32),
        _ShopifyFormatNote(
          headers: const [
            'First Name', 'Last Name', 'Email', 'Phone',
            'Total Spent', 'Total Orders', 'Tags', 'Note',
          ],
        ),
      ],
    );
  }
}

// ─── Orders Tab ───────────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.state});
  final CsvManagerState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CsvManagerCubit>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionCard(
          icon: Icons.upload_file_rounded,
          title: 'Export Orders',
          description:
              'Download all orders as a CSV file. One row per line item. '
              'Includes status, payment method, fees, discounts, promo codes, '
              'delivery address, driver, and all item details.',
          actionLabel: 'Export CSV',
          isLoading: state.ordersExport == CsvOp.loading,
          isSuccess: state.ordersExport == CsvOp.success,
          onTap: cubit.exportOrders,
          color: AppColors.primaryDeep,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            border: Border.all(color: Colors.amber.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Order import is not supported — orders are created by customers '
                  'through the app and cannot be bulk-imported.',
                  style: GoogleFonts.nunito(fontSize: 13, color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _ShopifyFormatNote(
          headers: const [
            'Order ID', 'Created At', 'Status', 'Payment Method',
            'Total', 'Delivery Fee', 'Service Fee',
            'Loyalty Discount', 'Promo Discount', 'Promo Code',
            'Delivery Address', 'Notes', 'Driver',
            'Item Name', 'Item Qty', 'Item Unit Price', 'Item Subtotal',
          ],
        ),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.isLoading,
    required this.isSuccess,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final bool isLoading;
  final bool isSuccess;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.nunito(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : isSuccess
                            ? const Icon(Icons.check_rounded, size: 18)
                            : Icon(icon, size: 18),
                    label: Text(
                      isLoading ? 'Processing…' : actionLabel,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportPreviewCard extends StatelessWidget {
  const _ImportPreviewCard({
    required this.title,
    required this.rowCount,
    required this.rowLabels,
    required this.onCommit,
    required this.onCancel,
    required this.isLoading,
  });

  final String title;
  final int rowCount;
  final List<String> rowLabels;
  final VoidCallback onCommit;
  final VoidCallback onCancel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final visible = rowLabels.take(8).toList();
    final extra = rowCount - visible.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$rowCount rows',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...visible.map(
            (label) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right_rounded, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.blue.shade900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (extra > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '… and $extra more',
                style: GoogleFonts.nunito(fontSize: 12, color: Colors.blue.shade600),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onCommit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Import $rowCount rows',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShopifyFormatNote extends StatelessWidget {
  const _ShopifyFormatNote({required this.headers});
  final List<String> headers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.table_chart_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Expected CSV columns',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: headers
                .map(
                  (h) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      h,
                      style: GoogleFonts.robotoMono(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
