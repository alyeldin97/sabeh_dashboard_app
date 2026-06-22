# Localization Plan — Sabeh Dashboard App

## Overview

**Approach**: Flutter `gen_l10n` (l10n.yaml + `.arb` files)  
**Languages**: English (`en`) + Arabic (`ar`)  
**intl package**: Already installed (`^0.20.2`)  
**Total screens**: 37 across 23 features

### Setup Steps (one-time, before feature work)
- [x] Create `l10n.yaml` config file
- [x] Create `lib/l10n/app_en.arb` (source of truth)
- [x] Create `lib/l10n/app_ar.arb` (Arabic translations)
- [x] Add `flutter_localizations` to `pubspec.yaml`
- [x] Wire `localizationsDelegates` and `supportedLocales` in `main.dart`
- [ ] Add locale toggle to settings screen (EN ↔ AR)

---

## Features

### 1. Auth
- **Screens**: `login_screen.dart`
- **Status**: ⬜ Not started

### 2. Splash
- **Screens**: `splash_screen.dart`
- **Status**: ⬜ Not started

### 3. Layout / Navigation
- **Screens**: `layout_screen.dart`
- **Status**: ⬜ Not started

### 4. Dashboard Home
- **Screens**: `dashboard_home_screen.dart`
- **Status**: ⬜ Not started

### 5. Analytics
- **Screens**: `analytics_screen.dart`
- **Status**: ⬜ Not started

### 6. Orders
- **Screens**: `orders_screen.dart`, `order_details_screen.dart`, `create_order_screen.dart`
- **Status**: ✅ Complete

### 7. Products
- **Screens**: `products_mgmt_screen.dart`, `product_form_screen.dart`
- **Status**: ⬜ Not started

### 8. Categories
- **Screens**: `categories_mgmt_screen.dart`, `category_form_screen.dart`
- **Status**: ⬜ Not started

### 9. Customers
- **Screens**: `customers_screen.dart`, `customer_detail_screen.dart`
- **Status**: ✅ Complete

### 10. Branches
- **Screens**: `branches_mgmt_screen.dart`, `branch_form_screen.dart`
- **Status**: ⬜ Not started

### 11. Staff Management
- **Screens**: `staff_mgmt_screen.dart`, `staff_form_screen.dart`
- **Status**: ⬜ Not started

### 12. Delivery Zones
- **Screens**: `delivery_zones_mgmt_screen.dart`, `delivery_zone_form_screen.dart`
- **Status**: ⬜ Not started

### 13. Delivery
- **Screens**: `delivery_screen.dart`
- **Status**: ⬜ Not started

### 14. Dispatch Board
- **Screens**: `dispatch_board_screen.dart`, `daily_report_screen.dart`, `driver_report_screen.dart`, `reports_screen.dart`
- **Status**: ✅ Complete

### 15. Expenses
- **Screens**: `expense_report_screen.dart`
- **Status**: ✅ Complete

### 16. Banners
- **Screens**: `banners_mgmt_screen.dart`, `banner_form_screen.dart`
- **Status**: ✅ Complete

### 17. Popup Ads
- **Screens**: `popup_ads_mgmt_screen.dart`, `popup_ad_form_screen.dart`
- **Status**: ✅ Complete

### 18. Promo Codes
- **Screens**: `promo_codes_screen.dart`, `promo_code_form_screen.dart`
- **Status**: ✅ Complete

### 19. Loyalty Management
- **Screens**: `loyalty_mgmt_screen.dart`, `loyalty_goal_form_screen.dart`, `loyalty_rule_form_screen.dart`, `spend_goal_form_screen.dart`
- **Status**: ✅ Complete

### 20. Settings
- **Screens**: `settings_screen.dart`
- **Status**: ✅ Complete

### 21. CSV Manager
- **Screens**: `csv_manager_screen.dart`
- **Status**: ✅ Complete

### 22. App Settings
- **Screens**: Part of settings flow (no dedicated screen, managed via cubits)
- **Status**: ⬜ Not started

### 23. Stub
- **Screens**: `customers_screen.dart`, `products_mgmt_screen.dart` (placeholder stubs)
- **Status**: ✅ Complete

---

## Progress Tracker

| # | Feature | Strings extracted | EN ARB | AR ARB | Wired in UI |
|---|---------|:-----------------:|:------:|:------:|:-----------:|
| — | **Setup** | — | ✅ | ✅ | ✅ |
| 1 | Auth | ✅ | ✅ | ✅ | ✅ |
| 2 | Splash | ⬜ | ⬜ | ⬜ | ⬜ |
| 3 | Layout / Nav | ⬜ | ⬜ | ⬜ | ⬜ |
| 4 | Dashboard Home | ⬜ | ⬜ | ⬜ | ⬜ |
| 5 | Analytics | ⬜ | ⬜ | ⬜ | ⬜ |
| 6 | Orders | ✅ | ✅ | ✅ | ✅ |
| 7 | Products | ⬜ | ⬜ | ⬜ | ⬜ |
| 8 | Categories | ⬜ | ⬜ | ⬜ | ⬜ |
| 9 | Customers | ✅ | ✅ | ✅ | ✅ |
| 10 | Branches | ⬜ | ⬜ | ⬜ | ⬜ |
| 11 | Staff Management | ⬜ | ⬜ | ⬜ | ⬜ |
| 12 | Delivery Zones | ⬜ | ⬜ | ⬜ | ⬜ |
| 13 | Delivery | ⬜ | ⬜ | ⬜ | ⬜ |
| 14 | Dispatch Board | ✅ | ✅ | ✅ | ✅ |
| 15 | Expenses | ✅ | ✅ | ✅ | ✅ |
| 16 | Banners | ✅ | ✅ | ✅ | ✅ |
| 17 | Popup Ads | ✅ | ✅ | ✅ | ✅ |
| 18 | Promo Codes | ✅ | ✅ | ✅ | ✅ |
| 19 | Loyalty Management | ✅ | ✅ | ✅ | ✅ |
| 20 | Settings | ✅ | ✅ | ✅ | ✅ |
| 21 | CSV Manager | ✅ | ✅ | ✅ | ✅ |
| 22 | App Settings | ⬜ | ⬜ | ⬜ | ⬜ |
| 23 | Stub | ✅ | ✅ | ✅ | ✅ |
