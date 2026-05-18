# Sabeh Platform — Build Status

> Last updated: 2026-05-13
> Two Flutter apps · Supabase backend · Feature-first clean architecture

---

## Codebase At a Glance

| | User App | Dashboard App |
|---|---|---|
| Dart files | 89 | 77 |
| `flutter analyze` | 0 issues | 0 issues |
| Path | `sabeh_user_app/` | `sabeh_dashboard_app/` |

---

## Accomplished

### Infrastructure (both apps)
- Feature-first clean architecture: `UI → Cubit → Repo (abstract) → DataSource (abstract) → impl/supabase/`
- `AppLogger` in both apps — `d/i/w/e/net/state` levels, zero-cost in release (`kDebugMode` guard)
- `DependencyInjector` singleton with `_deps[Type] ??=` pattern
- `ScreenUtil` (375×812 canvas), `GoogleFonts.nunito`, brand color tokens
- Supabase initialized in both `main.dart` files

---

### User App (`sabeh_user_app`)

#### Auth
- Email / password sign-in and registration
- Google Sign-In via Supabase OAuth
- Auth state stream → auto-redirect on token refresh
- `updateProfile(name, phone)` on `AuthCubit`

#### Home & Discovery
- Splash → Onboarding → Login flow
- Home screen: animated product grid, banner carousel, category filter chips
- Categories browse screen
- Product details screen (images, price, add to cart)
- Search screen — 400ms debounce, branch-scoped `ilike`, quick-add to cart

#### Cart & Checkout
- Cart (add / decrement / remove / clear), animated badge in bottom nav
- Checkout: address picker (flutter\_map + OpenStreetMap), notes, COD badge
- `BranchCubit.resolve()` after address pick → nearest branch by lat/lng
- No-coverage screen pushed from checkout when `BranchStatus.noCoverage` fires
- Order Confirmed screen

#### Orders
- Order history list (`UserOrdersScreen`)
- Order details with status timeline (5-step, colour-coded)
- Re-order — clears cart, rebuilds from order items, navigates to cart tab

#### Profile
- Profile screen (avatar, name, email, loyalty points chip)
- Edit Profile screen (name + phone editable, email read-only)

#### Logging
- AppLogger in all data sources: `auth`, `branch`, `categories`, `home`, `products`, `user_orders`
- AppLogger in all cubits: `auth`, `branch`, `cart`, `home`, `products`, `checkout`, `user_orders`, `search`

---

### Dashboard App (`sabeh_dashboard_app`)

#### Auth & Layout
- Email login for staff
- Role-aware tabs: Admin/Manager → all tabs; CS → Orders + Customers; DeliveryUser → Delivery
- Sidebar on web (collapsible), bottom nav on mobile

#### Orders
- Orders list with status filter tabs (All / Pending / Confirmed / Preparing / Out for Delivery / Delivered / Cancelled)
- Order details with inline status update
- `OrdersCubit.loadSingle()` for detail view

#### Products & Categories
- Products CRUD (list, create, edit, delete, image URLs, branch scoping)
- Categories CRUD

#### Customers
- Customer list (name, email, phone, loyalty points, blocked badge)

#### Analytics
- Revenue cards — today, this week, this month (delivered orders only)
- Order count per status — horizontal progress bars
- Top 5 products by revenue with quantity sold
- Refresh button; admin sees all, manager sees scoped branch

#### Branch Management
- Full CRUD — list, create, edit (name, lat, lng, coverage radius, active toggle), delete with confirmation
- `BranchesCubit → BranchesRepository → SupabaseBranchesDataSource`
- Toggle-active shortcut from list card

#### Delivery Management
- Active deliveries (Confirmed / Preparing / Out for Delivery)
- Recently delivered (last 10)
- Quick status buttons inline (Prepare → Dispatch → Delivered)
- Taps through to full `OrderDetailsScreen`

#### Logging
- AppLogger in all data sources and cubits: `auth`, `orders`, `categories`, `products`, `customers`, `branches`

---

## Not Yet Done

### User App

| Feature | Notes |
|---|---|
| My Addresses screen | Profile menu item is a stub. Needs address CRUD (save multiple delivery addresses per customer) |
| Loyalty earn/redeem | Points displayed in profile but never awarded on order completion or redeemable at checkout |
| Promo codes at checkout | No promo code field in checkout, no `promo_codes` table query |
| Push notifications | Order status change → push. Needs FCM + Supabase Edge Function trigger |
| Notifications settings screen | Profile menu item is a stub |
| Help & Support screen | Profile menu item is a stub |
| Forgot password | Login screen has no "forgot password" link |
| Real-time order status | Order details loads once; no Supabase channel subscription for live updates |

### Dashboard App

| Feature | Notes |
|---|---|
| Staff management screen | No UI to create / edit / deactivate staff or assign branch |
| Real-time order stream | Orders list refreshes on load only; no live `channel().on()` subscription |
| Promo code management | No promo CRUD screen |
| Product stock toggle | `is_in_stock` field on model but no UI toggle in the products list |
| Customer detail / block | Customer list exists but no tap-through to detail or block action |
| Export / download reports | Analytics is view-only; no CSV export |

### Database / Backend

| Item | Notes |
|---|---|
| Schema applied | `setup_supabase.sql` exists but DB was empty as of last check. Must be applied before anything works end-to-end |
| RLS policies | Not verified. Staff and customer scoping depends on RLS being correct in Supabase |
| Edge Functions | None deployed. Loyalty award on delivery and push notifications both need them |
| Google Sign-In native setup | Needs `GoogleService-Info.plist` (iOS) + `google-services.json` (Android) + OAuth redirect registered in Supabase |

---

## Suggested Next Priorities

1. **Apply database schema** — nothing works end-to-end until `setup_supabase.sql` is run
2. **Real-time subscriptions** — `OrdersCubit` and `UserOrdersCubit` should listen to Supabase channels
3. **Loyalty award on delivery** — when staff marks order delivered, add points to customer profile
4. **Staff management screen** — admin must be able to create delivery users and CS agents
5. **Forgot password** — basic user-facing gap, one-screen fix
6. **My Addresses** — reduces checkout friction for repeat customers
7. **Promo codes** — revenue feature, simple data model

---

## Key File Locations

### User App
```
lib/
  core/
    di/dependency_injection.dart      — all singletons
    utils/app_logger.dart             — debug logging
  features/
    auth/                             — login, register, Google, edit profile
    branch/                           — branch resolution + no-coverage screen
    cart/                             — cart cubit + screen
    checkout/                         — checkout + order confirmed
    home/                             — home, banners, category filter
    search/                           — debounced product search
    user_orders/                      — order list, details, re-order
    profile/                          — profile + edit profile
```

### Dashboard App
```
lib/
  core/
    di/dependency_injection.dart      — all singletons
    utils/app_logger.dart             — debug logging
  features/
    auth/                             — staff login
    orders/                           — order list + details + status update
    analytics/                        — revenue + status bars + top products
    branches/                         — branch CRUD
    delivery/                         — active deliveries + quick status actions
    products/                         — product CRUD
    categories/                       — category CRUD
    customers/                        — customer list
    settings/                         — placeholder
    layout/                           — role-aware sidebar + bottom nav
```
