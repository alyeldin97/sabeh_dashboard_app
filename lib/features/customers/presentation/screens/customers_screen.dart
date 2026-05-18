import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/styling/colors.dart';
import '../../data/model/customer.dart';
import '../cubits/customers_cubit.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = Responsive.isWeb(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _Header(searchCtrl: _searchCtrl, isWeb: isWeb),
          Expanded(
            child: BlocBuilder<CustomersCubit, CustomersState>(
              builder: (context, state) {
                if (state.status == CustomersStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryDeep),
                  );
                }
                if (state.status == CustomersStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                        SizedBox(height: 12.h),
                        Text(
                          state.errorMessage ?? 'Failed to load customers',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 14),
                            color: AppColors.textLight,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: () =>
                              context.read<CustomersCubit>().load(search: state.query),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.nunito(
                              fontSize: Responsive.sp(context, 14),
                              color: AppColors.primaryMid,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 56.r, color: AppColors.primaryLight),
                        SizedBox(height: 16.h),
                        Text(
                          state.query.isEmpty
                              ? 'No customers yet'
                              : 'No results for "${state.query}"',
                          style: GoogleFonts.nunito(
                            fontSize: Responsive.sp(context, 16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (isWeb) {
                  return _CustomerTable(customers: state.customers);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.customers.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (_, i) => _CustomerCard(customer: state.customers[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.searchCtrl, required this.isWeb});
  final TextEditingController searchCtrl;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        isWeb ? 24 : MediaQuery.of(context).padding.top + 16,
        16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customers',
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 22),
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: searchCtrl,
            onChanged: (q) => context.read<CustomersCubit>().search(q),
            style: GoogleFonts.nunito(
              fontSize: Responsive.sp(context, 14),
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, email, or phone…',
              hintStyle: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textLight,
              ),
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppColors.textLight, size: 20.r),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        searchCtrl.clear();
                        context.read<CustomersCubit>().load();
                      },
                      child: Icon(Icons.close_rounded,
                          color: AppColors.textLight, size: 18.r),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.scaffoldBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: AppBorderRadius.r12,
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.r12,
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.r12,
                borderSide: BorderSide(color: AppColors.primaryMid, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile card ──────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _Avatar(initials: customer.initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.displayName,
                  style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (customer.email != null) ...[
                  Text(
                    customer.email!,
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 12),
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (customer.phone != null) ...[
                  Text(
                    customer.phone!,
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 12),
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${customer.orderCount} orders',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryMid,
                ),
              ),
              Text(
                'EGP ${customer.totalSpent.toStringAsFixed(0)}',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Web table ────────────────────────────────────────────────────────────────

class _CustomerTable extends StatelessWidget {
  const _CustomerTable({required this.customers});
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _TableHeader(),
          const Divider(height: 1),
          ...customers.map((c) => _TableRow(customer: c)),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.primaryMist,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Customer',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                )),
          ),
          Expanded(
            flex: 3,
            child: Text('Email',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                )),
          ),
          Expanded(
            flex: 2,
            child: Text('Phone',
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                )),
          ),
          SizedBox(
            width: 80,
            child: Text('Orders',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                )),
          ),
          SizedBox(
            width: 100,
            child: Text('Total Spent',
                textAlign: TextAlign.right,
                style: GoogleFonts.nunito(
                  fontSize: Responsive.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                )),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _Avatar(initials: customer.initials, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    customer.displayName,
                    style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              customer.email ?? '—',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textMid,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              customer.phone ?? '—',
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                color: AppColors.textMid,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${customer.orderCount}',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryMid,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'EGP ${customer.totalSpent.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: GoogleFonts.nunito(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.size = 40});
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryMist,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.nunito(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDeep,
          ),
        ),
      ),
    );
  }
}
