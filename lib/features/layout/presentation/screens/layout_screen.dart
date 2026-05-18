import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/navigation/cubits/navigation_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../auth/data/model/staff_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../branches/presentation/screens/branches_mgmt_screen.dart';
import '../../../categories/presentation/screens/categories_mgmt_screen.dart';
import '../../../dashboard_home/presentation/screens/dashboard_home_screen.dart';
import '../../../delivery/presentation/screens/delivery_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../products/presentation/screens/products_mgmt_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../customers/presentation/screens/customers_screen.dart';

class LayoutScreen extends StatelessWidget {
  static const String routeName = '/layout';
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final role = user?.role ?? StaffRole.customerService;
    final branchId = user?.branchId;
    final tabs = _tabsForRole(role, branchId);
    final isWeb = Responsive.isWeb(context);

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        final safeIndex = currentIndex.clamp(0, tabs.length - 1);

        if (isWeb) {
          return Scaffold(
            body: Row(
              children: [
                _DashboardSidebar(
                  tabs: tabs,
                  currentIndex: safeIndex,
                  user: user,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: safeIndex,
                    children: tabs.map((t) => t.screen).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: safeIndex,
            children: tabs.map((t) => t.screen).toList(),
          ),
          bottomNavigationBar: _DashboardBottomNav(
            tabs: tabs,
            currentIndex: safeIndex,
          ),
        );
      },
    );
  }

  List<_TabDef> _tabsForRole(StaffRole role, String? branchId) {
    switch (role) {
      case StaffRole.admin:
      case StaffRole.manager:
        return [
          _TabDef(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Home',
            screen: DashboardHomeScreen(branchId: branchId),
          ),
          _TabDef(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'Orders',
            screen: OrdersScreen(branchId: branchId),
          ),
          _TabDef(
            icon: Icons.delivery_dining_outlined,
            activeIcon: Icons.delivery_dining_rounded,
            label: 'Delivery',
            screen: DeliveryScreen(branchId: branchId),
          ),
          _TabDef(
            icon: Icons.bar_chart_rounded,
            activeIcon: Icons.bar_chart_rounded,
            label: 'Analytics',
            screen: AnalyticsScreen(branchId: branchId),
          ),
          _TabDef(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: 'Products',
            screen: ProductsMgmtScreen(),
          ),
          _TabDef(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'Categories',
            screen: CategoriesMgmtScreen(),
          ),
          _TabDef(
            icon: Icons.store_outlined,
            activeIcon: Icons.store_rounded,
            label: 'Branches',
            screen: const BranchesMgmtScreen(),
          ),
          _TabDef(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'Settings',
            screen: const SettingsScreen(),
          ),
        ];

      case StaffRole.customerService:
        return [
          _TabDef(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'Orders',
            screen: OrdersScreen(branchId: branchId),
          ),
          _TabDef(
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: 'Customers',
            screen: const CustomersScreen(),
          ),
        ];

      case StaffRole.deliveryManager:
        return [
          _TabDef(
            icon: Icons.local_shipping_outlined,
            activeIcon: Icons.local_shipping_rounded,
            label: 'Deliveries',
            screen: OrdersScreen(branchId: branchId),
          ),
        ];

      case StaffRole.deliveryUser:
        return [
          _TabDef(
            icon: Icons.delivery_dining_outlined,
            activeIcon: Icons.delivery_dining_rounded,
            label: 'My Routes',
            screen: OrdersScreen(branchId: branchId),
          ),
        ];
    }
  }
}

class _TabDef {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;
  const _TabDef({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}

// ── Web Sidebar ──────────────────────────────────────────────────────────────

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.tabs,
    required this.currentIndex,
    required this.user,
  });
  final List<_TabDef> tabs;
  final int currentIndex;
  final StaffUser? user;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: isWide ? 220 : 72,
      color: AppColors.primaryDeep,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 24),
          _SidebarHeader(isWide: isWide, user: user),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: tabs.length,
              itemBuilder: (context, i) => _SidebarItem(
                tab: tabs[i],
                isSelected: i == currentIndex,
                isWide: isWide,
                onTap: () => context.read<NavigationCubit>().navigateTo(i),
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          _SidebarLogout(isWide: isWide),
          SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.isWide, required this.user});
  final bool isWide;
  final StaffUser? user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                (user != null && user!.name.isNotEmpty ? user!.name[0] : 'S').toUpperCase(),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Staff',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.role.label ?? '',
                    style: GoogleFonts.nunito(fontSize: 11, color: Colors.white60),
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.tab,
    required this.isSelected,
    required this.isWide,
    required this.onTap,
  });
  final _TabDef tab;
  final bool isSelected;
  final bool isWide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.white30 : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? tab.activeIcon : tab.icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              if (isWide) ...[
                const SizedBox(width: 12),
                Text(
                  tab.label,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarLogout extends StatelessWidget {
  const _SidebarLogout({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
      child: InkWell(
        onTap: () => context.read<AuthCubit>().signOut(),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 20, color: Colors.white54),
              if (isWide) ...[
                const SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white60,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile Bottom Nav ────────────────────────────────────────────────────────

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({required this.tabs, required this.currentIndex});
  final List<_TabDef> tabs;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (tabs.length == 1) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(8, 10, 8, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          tabs.length,
          (i) => _NavItem(
            tab: tabs[i],
            isSelected: i == currentIndex,
            showLabel: tabs.length <= 3,
            onTap: () => context.read<NavigationCubit>().navigateTo(i),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.isSelected, required this.onTap, required this.showLabel});
  final _TabDef tab;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 270),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected && showLabel ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMist : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                key: ValueKey(isSelected),
                size: 24.r,
                color: isSelected ? AppColors.primaryDeep : AppColors.textLight,
              ),
            ),
            if (showLabel)
              AnimatedSize(
                duration: const Duration(milliseconds: 270),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Row(
                        children: [
                          const SizedBox(width: 6),
                          Text(
                            tab.label,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
