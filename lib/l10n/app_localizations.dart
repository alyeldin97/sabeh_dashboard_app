import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App title shown on login screen
  ///
  /// In en, this message translates to:
  /// **'Sabeh Dashboard'**
  String get authAppTitle;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Staff portal — sign in to continue'**
  String get authSubtitle;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneLabel;

  /// Phone field validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get authPhoneError;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Password field validation error
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordError;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get navDelivery;

  /// No description provided for @navDispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get navDispatch;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get navBranches;

  /// No description provided for @navZones.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get navZones;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get navLoyalty;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get navStaff;

  /// No description provided for @navPromos.
  ///
  /// In en, this message translates to:
  /// **'Promos'**
  String get navPromos;

  /// No description provided for @navBanners.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get navBanners;

  /// No description provided for @navAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get navAds;

  /// No description provided for @navCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get navCsv;

  /// No description provided for @navMyRoutes.
  ///
  /// In en, this message translates to:
  /// **'My Routes'**
  String get navMyRoutes;

  /// No description provided for @navSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get navSignOut;

  /// No description provided for @navStaffFallback.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get navStaffFallback;

  /// No description provided for @homeGlance.
  ///
  /// In en, this message translates to:
  /// **'Today at a glance'**
  String get homeGlance;

  /// No description provided for @homeTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get homeTotalOrders;

  /// No description provided for @homePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get homePending;

  /// No description provided for @homeInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get homeInProgress;

  /// No description provided for @homeDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get homeDelivered;

  /// No description provided for @homeActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get homeActiveOrders;

  /// No description provided for @homeAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get homeAllCaughtUp;

  /// No description provided for @homeNoActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders right now'**
  String get homeNoActiveOrders;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning ☀️'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 🌤'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening 🌙'**
  String get homeGoodEvening;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get analyticsRefresh;

  /// No description provided for @analyticsFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get analyticsFilters;

  /// No description provided for @analyticsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get analyticsToday;

  /// No description provided for @analytics7Days.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get analytics7Days;

  /// No description provided for @analytics30Days.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get analytics30Days;

  /// No description provided for @analyticsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get analyticsThisMonth;

  /// No description provided for @analyticsCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get analyticsCustom;

  /// No description provided for @analyticsAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get analyticsAllBranches;

  /// No description provided for @analyticsOnlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online Now'**
  String get analyticsOnlineNow;

  /// No description provided for @analyticsLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get analyticsLive;

  /// No description provided for @analyticsActiveInLast.
  ///
  /// In en, this message translates to:
  /// **'Active in last {minutes} min'**
  String analyticsActiveInLast(int minutes);

  /// No description provided for @analyticsTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get analyticsTotalSales;

  /// No description provided for @analyticsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get analyticsOrders;

  /// No description provided for @analyticsTotalCogs.
  ///
  /// In en, this message translates to:
  /// **'Total COGS'**
  String get analyticsTotalCogs;

  /// No description provided for @analyticsGrossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get analyticsGrossProfit;

  /// No description provided for @analyticsAvgOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Avg Order Value'**
  String get analyticsAvgOrderValue;

  /// No description provided for @analyticsDiscountsFreeItems.
  ///
  /// In en, this message translates to:
  /// **'Discounts & Free Items'**
  String get analyticsDiscountsFreeItems;

  /// No description provided for @analyticsDeliveryCharges.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charges'**
  String get analyticsDeliveryCharges;

  /// No description provided for @analyticsTotalDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Total Discounts'**
  String get analyticsTotalDiscounts;

  /// No description provided for @analyticsLoyaltyDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Discounts'**
  String get analyticsLoyaltyDiscounts;

  /// No description provided for @analyticsPromoDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Promo Discounts'**
  String get analyticsPromoDiscounts;

  /// No description provided for @analyticsFreeDeliveryValue.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery Value'**
  String get analyticsFreeDeliveryValue;

  /// No description provided for @analyticsFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get analyticsFreeDelivery;

  /// No description provided for @analyticsFreeItems.
  ///
  /// In en, this message translates to:
  /// **'Free Items'**
  String get analyticsFreeItems;

  /// No description provided for @analyticsFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment'**
  String get analyticsFulfillment;

  /// No description provided for @analyticsCancellation.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get analyticsCancellation;

  /// No description provided for @analyticsReturning.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get analyticsReturning;

  /// No description provided for @analyticsCustomerMetrics.
  ///
  /// In en, this message translates to:
  /// **'Customer Metrics'**
  String get analyticsCustomerMetrics;

  /// No description provided for @analyticsUniqueCustomers.
  ///
  /// In en, this message translates to:
  /// **'Unique Customers'**
  String get analyticsUniqueCustomers;

  /// No description provided for @analyticsDailySales.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get analyticsDailySales;

  /// No description provided for @analyticsSalesByZone.
  ///
  /// In en, this message translates to:
  /// **'Sales by Delivery Zone'**
  String get analyticsSalesByZone;

  /// No description provided for @analyticsOrdersByStatus.
  ///
  /// In en, this message translates to:
  /// **'Orders by Status'**
  String get analyticsOrdersByStatus;

  /// No description provided for @analyticsByRevenue.
  ///
  /// In en, this message translates to:
  /// **'By Revenue'**
  String get analyticsByRevenue;

  /// No description provided for @analyticsByQuantity.
  ///
  /// In en, this message translates to:
  /// **'By Quantity'**
  String get analyticsByQuantity;

  /// No description provided for @analyticsByViews.
  ///
  /// In en, this message translates to:
  /// **'By Views'**
  String get analyticsByViews;

  /// No description provided for @analyticsByAddToCart.
  ///
  /// In en, this message translates to:
  /// **'By Add-to-Cart'**
  String get analyticsByAddToCart;

  /// No description provided for @analyticsShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get analyticsShowLess;

  /// No description provided for @analyticsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get analyticsNoData;

  /// No description provided for @analyticsDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Sessions by Device Type'**
  String get analyticsDeviceType;

  /// No description provided for @analyticsAbandonedCarts.
  ///
  /// In en, this message translates to:
  /// **'Abandoned Checkouts'**
  String get analyticsAbandonedCarts;

  /// No description provided for @analyticsCartItems.
  ///
  /// In en, this message translates to:
  /// **'CART ITEMS'**
  String get analyticsCartItems;

  /// No description provided for @analyticsProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get analyticsProduct;

  /// No description provided for @analyticsViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get analyticsViews;

  /// No description provided for @analyticsCarts.
  ///
  /// In en, this message translates to:
  /// **'Carts'**
  String get analyticsCarts;

  /// No description provided for @analyticsEventTracking.
  ///
  /// In en, this message translates to:
  /// **'Event Tracking'**
  String get analyticsEventTracking;

  /// No description provided for @analyticsFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics'**
  String get analyticsFailedLoad;

  /// No description provided for @analyticsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get analyticsRetry;

  /// No description provided for @analyticsGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get analyticsGuest;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get ordersNewOrder;

  /// No description provided for @ordersTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersTabAll;

  /// No description provided for @ordersTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersTabPending;

  /// No description provided for @ordersTabConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get ordersTabConfirmed;

  /// No description provided for @ordersTabPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get ordersTabPreparing;

  /// No description provided for @ordersTabDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get ordersTabDelivery;

  /// No description provided for @ordersTabDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ordersTabDone;

  /// No description provided for @ordersTabCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersTabCancelled;

  /// No description provided for @ordersFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get ordersFailedLoad;

  /// No description provided for @ordersRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get ordersRetry;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders here'**
  String get ordersEmpty;

  /// No description provided for @orderDetailsOrderInfo.
  ///
  /// In en, this message translates to:
  /// **'Order Info'**
  String get orderDetailsOrderInfo;

  /// No description provided for @orderDetailsCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get orderDetailsCreated;

  /// No description provided for @orderDetailsPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get orderDetailsPayment;

  /// No description provided for @orderDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderDetailsStatus;

  /// No description provided for @orderDetailsAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get orderDetailsAddress;

  /// No description provided for @orderDetailsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get orderDetailsNotes;

  /// No description provided for @orderDetailsPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get orderDetailsPromoCode;

  /// No description provided for @orderDetailsDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get orderDetailsDriver;

  /// No description provided for @orderDetailsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get orderDetailsSummary;

  /// No description provided for @orderDetailsDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get orderDetailsDeliveryFee;

  /// No description provided for @orderDetailsServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get orderDetailsServiceFee;

  /// No description provided for @orderDetailsDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get orderDetailsDelivery;

  /// No description provided for @orderDetailsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderDetailsTotal;

  /// No description provided for @orderDetailsDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit (عربون)'**
  String get orderDetailsDeposit;

  /// No description provided for @orderDetailsAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get orderDetailsAmountDue;

  /// No description provided for @orderDetailsRewardsApplied.
  ///
  /// In en, this message translates to:
  /// **'Rewards Applied'**
  String get orderDetailsRewardsApplied;

  /// No description provided for @orderDetailsSpendMilestone.
  ///
  /// In en, this message translates to:
  /// **'Spend Milestone'**
  String get orderDetailsSpendMilestone;

  /// No description provided for @orderDetailsPointsRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Points Redeemed'**
  String get orderDetailsPointsRedeemed;

  /// No description provided for @orderDetailsPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get orderDetailsPointsEarned;

  /// No description provided for @orderDetailsFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get orderDetailsFree;

  /// No description provided for @orderDetailsPrintInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get orderDetailsPrintInvoice;

  /// No description provided for @orderDetailsCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get orderDetailsCancelOrder;

  /// No description provided for @orderDetailsCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get orderDetailsCancelConfirm;

  /// No description provided for @orderDetailsNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get orderDetailsNo;

  /// No description provided for @orderDetailsConfirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get orderDetailsConfirmOrder;

  /// No description provided for @orderDetailsStartPreparing.
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get orderDetailsStartPreparing;

  /// No description provided for @orderDetailsSendForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Send for Delivery'**
  String get orderDetailsSendForDelivery;

  /// No description provided for @orderDetailsMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark Delivered'**
  String get orderDetailsMarkDelivered;

  /// No description provided for @createOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get createOrderTitle;

  /// No description provided for @createOrderStepCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get createOrderStepCustomer;

  /// No description provided for @createOrderStepProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get createOrderStepProducts;

  /// No description provided for @createOrderStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get createOrderStepDetails;

  /// No description provided for @createOrderStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get createOrderStepConfirm;

  /// No description provided for @createOrderBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get createOrderBack;

  /// No description provided for @createOrderNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get createOrderNext;

  /// No description provided for @createOrderPlace.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get createOrderPlace;

  /// No description provided for @createOrderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get createOrderSuccess;

  /// No description provided for @createOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order'**
  String get createOrderFailed;

  /// No description provided for @createOrderSearchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search Existing Customer'**
  String get createOrderSearchCustomer;

  /// No description provided for @createOrderSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, phone, or email…'**
  String get createOrderSearchHint;

  /// No description provided for @createOrderNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Or Create New Customer'**
  String get createOrderNewCustomer;

  /// No description provided for @createOrderFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get createOrderFullName;

  /// No description provided for @createOrderFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Customer full name'**
  String get createOrderFullNameHint;

  /// No description provided for @createOrderPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get createOrderPhone;

  /// No description provided for @createOrderUseAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Use as Customer'**
  String get createOrderUseAsCustomer;

  /// No description provided for @createOrderAddCustomItem.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Item'**
  String get createOrderAddCustomItem;

  /// No description provided for @createOrderItemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name *'**
  String get createOrderItemName;

  /// No description provided for @createOrderItemPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (EGP) *'**
  String get createOrderItemPrice;

  /// No description provided for @createOrderAddToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add to Order'**
  String get createOrderAddToOrder;

  /// No description provided for @createOrderSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get createOrderSearchProducts;

  /// No description provided for @createOrderSelectedItems.
  ///
  /// In en, this message translates to:
  /// **'Selected Items'**
  String get createOrderSelectedItems;

  /// No description provided for @createOrderCustomItem.
  ///
  /// In en, this message translates to:
  /// **'Custom Item'**
  String get createOrderCustomItem;

  /// No description provided for @createOrderAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get createOrderAllProducts;

  /// No description provided for @createOrderBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch *'**
  String get createOrderBranch;

  /// No description provided for @createOrderSelectBranch.
  ///
  /// In en, this message translates to:
  /// **'Select branch'**
  String get createOrderSelectBranch;

  /// No description provided for @createOrderDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get createOrderDeliveryAddress;

  /// No description provided for @createOrderNewAddress.
  ///
  /// In en, this message translates to:
  /// **'New Address'**
  String get createOrderNewAddress;

  /// No description provided for @createOrderSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save & Use Address'**
  String get createOrderSaveAddress;

  /// No description provided for @createOrderDeliveryZone.
  ///
  /// In en, this message translates to:
  /// **'Delivery Zone'**
  String get createOrderDeliveryZone;

  /// No description provided for @createOrderSelectZone.
  ///
  /// In en, this message translates to:
  /// **'Select delivery zone'**
  String get createOrderSelectZone;

  /// No description provided for @createOrderNoZone.
  ///
  /// In en, this message translates to:
  /// **'No delivery zone'**
  String get createOrderNoZone;

  /// No description provided for @createOrderAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get createOrderAddressLabel;

  /// No description provided for @createOrderAddressLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Work'**
  String get createOrderAddressLabelHint;

  /// No description provided for @createOrderStreet.
  ///
  /// In en, this message translates to:
  /// **'Street *'**
  String get createOrderStreet;

  /// No description provided for @createOrderStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Street name / area'**
  String get createOrderStreetHint;

  /// No description provided for @createOrderBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get createOrderBuilding;

  /// No description provided for @createOrderBuildingHint.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get createOrderBuildingHint;

  /// No description provided for @createOrderFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get createOrderFloor;

  /// No description provided for @createOrderFloorHint.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get createOrderFloorHint;

  /// No description provided for @createOrderApt.
  ///
  /// In en, this message translates to:
  /// **'Apt'**
  String get createOrderApt;

  /// No description provided for @createOrderAptHint.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get createOrderAptHint;

  /// No description provided for @createOrderLandmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get createOrderLandmark;

  /// No description provided for @createOrderLandmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Near…'**
  String get createOrderLandmarkHint;

  /// No description provided for @createOrderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount (EGP)'**
  String get createOrderDiscount;

  /// No description provided for @createOrderOrderNotes.
  ///
  /// In en, this message translates to:
  /// **'Order Notes'**
  String get createOrderOrderNotes;

  /// No description provided for @createOrderNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any special instructions…'**
  String get createOrderNotesHint;

  /// No description provided for @createOrderPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get createOrderPaymentMethod;

  /// No description provided for @createOrderCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get createOrderCash;

  /// No description provided for @createOrderInstapay.
  ///
  /// In en, this message translates to:
  /// **'Instapay'**
  String get createOrderInstapay;

  /// No description provided for @createOrderCartSummary.
  ///
  /// In en, this message translates to:
  /// **'Cart: {count} item(s)'**
  String createOrderCartSummary(int count);

  /// No description provided for @createOrderSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: EGP {amount}'**
  String createOrderSubtotal(String amount);

  /// No description provided for @createOrderSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get createOrderSummaryTitle;

  /// No description provided for @createOrderSummaryCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get createOrderSummaryCustomer;

  /// No description provided for @createOrderSummaryDeliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'Delivery Info'**
  String get createOrderSummaryDeliveryInfo;

  /// No description provided for @createOrderSummaryItems.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String createOrderSummaryItems(int count);

  /// No description provided for @createOrderSummaryPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get createOrderSummaryPayment;

  /// No description provided for @createOrderSummaryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get createOrderSummaryNotes;

  /// No description provided for @createOrderSummaryBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get createOrderSummaryBranch;

  /// No description provided for @createOrderSummaryZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get createOrderSummaryZone;

  /// No description provided for @createOrderSummaryAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get createOrderSummaryAddress;

  /// No description provided for @createOrderSummaryMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get createOrderSummaryMethod;

  /// No description provided for @createOrderSummarySubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get createOrderSummarySubtotal;

  /// No description provided for @createOrderSummaryDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get createOrderSummaryDelivery;

  /// No description provided for @createOrderSummaryDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get createOrderSummaryDiscount;

  /// No description provided for @createOrderSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get createOrderSummaryTotal;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @productsAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get productsAddProduct;

  /// No description provided for @productsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get productsSearchHint;

  /// No description provided for @productFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get productFormEditTitle;

  /// No description provided for @productFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get productFormNewTitle;

  /// No description provided for @productFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get productFormSave;

  /// No description provided for @productFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get productFormActive;

  /// No description provided for @productFormActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visible to customers'**
  String get productFormActiveSubtitle;

  /// No description provided for @productFormBestSeller.
  ///
  /// In en, this message translates to:
  /// **'Best Seller 🔥'**
  String get productFormBestSeller;

  /// No description provided for @productFormBestSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show in Top Sellers section on home screen'**
  String get productFormBestSellerSubtitle;

  /// No description provided for @productFormAddOption.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get productFormAddOption;

  /// No description provided for @productFormStock.
  ///
  /// In en, this message translates to:
  /// **'Stock:'**
  String get productFormStock;

  /// No description provided for @productFormPricePreview.
  ///
  /// In en, this message translates to:
  /// **'Price Preview'**
  String get productFormPricePreview;

  /// No description provided for @productFormRelatedProducts.
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get productFormRelatedProducts;

  /// No description provided for @productFormAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get productFormAdd;

  /// No description provided for @productFormNoRelated.
  ///
  /// In en, this message translates to:
  /// **'No related products added yet.'**
  String get productFormNoRelated;

  /// No description provided for @productFormSelectRelated.
  ///
  /// In en, this message translates to:
  /// **'Select Related Product'**
  String get productFormSelectRelated;

  /// No description provided for @productFormNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches found.'**
  String get productFormNoBranches;

  /// No description provided for @productFormNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get productFormNone;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoriesAddCategory;

  /// No description provided for @categoriesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get categoriesSearchHint;

  /// No description provided for @categoriesDragReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get categoriesDragReorder;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmpty;

  /// No description provided for @categoriesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first category'**
  String get categoriesEmptyHint;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? This will deactivate it.'**
  String categoriesDeleteConfirm(String name);

  /// No description provided for @categoriesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get categoriesCancel;

  /// No description provided for @categoriesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoriesDelete;

  /// No description provided for @categoriesInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get categoriesInactive;

  /// No description provided for @categoryFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoryFormEditTitle;

  /// No description provided for @categoryFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get categoryFormNewTitle;

  /// No description provided for @categoryFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get categoryFormSave;

  /// No description provided for @categoryFormBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get categoryFormBranches;

  /// No description provided for @categoryFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryFormName;

  /// No description provided for @categoryFormMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get categoryFormMedia;

  /// No description provided for @categoryFormVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get categoryFormVisibility;

  /// No description provided for @categoryFormNameEn.
  ///
  /// In en, this message translates to:
  /// **'Category Name (English)'**
  String get categoryFormNameEn;

  /// No description provided for @categoryFormNameAr.
  ///
  /// In en, this message translates to:
  /// **'Category Name (Arabic)'**
  String get categoryFormNameAr;

  /// No description provided for @categoryFormCoverUrl.
  ///
  /// In en, this message translates to:
  /// **'Cover Image URL'**
  String get categoryFormCoverUrl;

  /// No description provided for @categoryFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get categoryFormActive;

  /// No description provided for @categoryFormActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visible to customers'**
  String get categoryFormActiveSubtitle;

  /// No description provided for @categoryFormAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get categoryFormAllBranches;

  /// No description provided for @categoryFormSelectBranch.
  ///
  /// In en, this message translates to:
  /// **'Select at least one branch.'**
  String get categoryFormSelectBranch;

  /// No description provided for @categoryFormNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches found.'**
  String get categoryFormNoBranches;

  /// No description provided for @categoryFormRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get categoryFormRequired;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @customersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, or phone…'**
  String get customersSearchHint;

  /// No description provided for @customersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get customersEmpty;

  /// No description provided for @customersNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String customersNoResults(String query);

  /// No description provided for @customersFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customers'**
  String get customersFailedLoad;

  /// No description provided for @customersRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get customersRetry;

  /// No description provided for @customersColCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customersColCustomer;

  /// No description provided for @customersColEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get customersColEmail;

  /// No description provided for @customersColPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customersColPhone;

  /// No description provided for @customersColOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get customersColOrders;

  /// No description provided for @customersColLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get customersColLoyalty;

  /// No description provided for @customersColTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get customersColTotalSpent;

  /// No description provided for @customerDetailCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get customerDetailCreateOrder;

  /// No description provided for @customerDetailLoyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get customerDetailLoyaltyPoints;

  /// No description provided for @customerDetailPoints.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get customerDetailPoints;

  /// No description provided for @customerDetailAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get customerDetailAdjust;

  /// No description provided for @customerDetailAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Loyalty Points'**
  String get customerDetailAdjustTitle;

  /// No description provided for @customerDetailAddPoints.
  ///
  /// In en, this message translates to:
  /// **'+ Add Points'**
  String get customerDetailAddPoints;

  /// No description provided for @customerDetailDeductPoints.
  ///
  /// In en, this message translates to:
  /// **'- Deduct Points'**
  String get customerDetailDeductPoints;

  /// No description provided for @customerDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get customerDetailAmount;

  /// No description provided for @customerDetailReason.
  ///
  /// In en, this message translates to:
  /// **'Reason / Description'**
  String get customerDetailReason;

  /// No description provided for @customerDetailConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get customerDetailConfirm;

  /// No description provided for @customerDetailInternalNotes.
  ///
  /// In en, this message translates to:
  /// **'Internal Notes'**
  String get customerDetailInternalNotes;

  /// No description provided for @customerDetailNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add internal notes about this customer…'**
  String get customerDetailNotesHint;

  /// No description provided for @customerDetailSaveNotes.
  ///
  /// In en, this message translates to:
  /// **'Save Notes'**
  String get customerDetailSaveNotes;

  /// No description provided for @customerDetailNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get customerDetailNoNotes;

  /// No description provided for @customerDetailBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get customerDetailBlocked;

  /// No description provided for @customerDetailJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String customerDetailJoined(String date);

  /// No description provided for @customerDetailRef.
  ///
  /// In en, this message translates to:
  /// **'Ref: {code}'**
  String customerDetailRef(String code);

  /// No description provided for @customerDetailPastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past Orders'**
  String get customerDetailPastOrders;

  /// No description provided for @customerDetailNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get customerDetailNoOrders;

  /// No description provided for @branchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branchesTitle;

  /// No description provided for @branchesAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Branch'**
  String get branchesAddTooltip;

  /// No description provided for @branchesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No branches yet'**
  String get branchesEmpty;

  /// No description provided for @branchesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first branch'**
  String get branchesEmptyHint;

  /// No description provided for @branchesFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load branches'**
  String get branchesFailedLoad;

  /// No description provided for @branchesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get branchesRetry;

  /// No description provided for @branchesMutationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get branchesMutationFailed;

  /// No description provided for @branchFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Branch'**
  String get branchFormEditTitle;

  /// No description provided for @branchFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Branch'**
  String get branchFormNewTitle;

  /// No description provided for @branchFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get branchFormSave;

  /// No description provided for @branchFormBranchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchFormBranchName;

  /// No description provided for @branchFormLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get branchFormLatitude;

  /// No description provided for @branchFormLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get branchFormLongitude;

  /// No description provided for @branchFormRadius.
  ///
  /// In en, this message translates to:
  /// **'Coverage Radius (km)'**
  String get branchFormRadius;

  /// No description provided for @branchFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get branchFormActive;

  /// No description provided for @branchFormDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Branch'**
  String get branchFormDelete;

  /// No description provided for @branchFormDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Branch?'**
  String get branchFormDeleteTitle;

  /// No description provided for @branchFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get branchFormCancel;

  /// No description provided for @branchFormDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get branchFormDeleteConfirm;

  /// No description provided for @branchFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get branchFormNameRequired;

  /// No description provided for @branchFormLatInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid latitude'**
  String get branchFormLatInvalid;

  /// No description provided for @branchFormLatRange.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get branchFormLatRange;

  /// No description provided for @branchFormLonInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid longitude'**
  String get branchFormLonInvalid;

  /// No description provided for @branchFormLonRange.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get branchFormLonRange;

  /// No description provided for @branchFormRadiusInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid radius > 0'**
  String get branchFormRadiusInvalid;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTitle;

  /// No description provided for @staffAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Staff'**
  String get staffAddTooltip;

  /// No description provided for @staffFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get staffFilterAll;

  /// No description provided for @staffEmpty.
  ///
  /// In en, this message translates to:
  /// **'No staff members'**
  String get staffEmpty;

  /// No description provided for @staffEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first member'**
  String get staffEmptyHint;

  /// No description provided for @staffFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load staff'**
  String get staffFailedLoad;

  /// No description provided for @staffRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get staffRetry;

  /// No description provided for @staffMutationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get staffMutationFailed;

  /// No description provided for @staffRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Staff Member'**
  String get staffRemoveTitle;

  /// No description provided for @staffRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from staff?'**
  String staffRemoveConfirm(String name);

  /// No description provided for @staffCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get staffCancel;

  /// No description provided for @staffRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get staffRemove;

  /// No description provided for @staffBranchScoped.
  ///
  /// In en, this message translates to:
  /// **'Branch scoped'**
  String get staffBranchScoped;

  /// No description provided for @staffFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Staff Member'**
  String get staffFormEditTitle;

  /// No description provided for @staffFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Staff Member'**
  String get staffFormNewTitle;

  /// No description provided for @staffFormFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get staffFormFullName;

  /// No description provided for @staffFormPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get staffFormPhoneOptional;

  /// No description provided for @staffFormPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get staffFormPhone;

  /// No description provided for @staffFormTempPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary Password'**
  String get staffFormTempPassword;

  /// No description provided for @staffFormRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffFormRole;

  /// No description provided for @staffFormBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get staffFormBranches;

  /// No description provided for @staffFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get staffFormActive;

  /// No description provided for @staffFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get staffFormSaveChanges;

  /// No description provided for @staffFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Staff Account'**
  String get staffFormCreate;

  /// No description provided for @staffFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get staffFormNameRequired;

  /// No description provided for @staffFormPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get staffFormPhoneRequired;

  /// No description provided for @staffFormPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get staffFormPasswordLength;

  /// No description provided for @staffFormBranchRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one branch'**
  String get staffFormBranchRequired;

  /// No description provided for @staffFormNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches available'**
  String get staffFormNoBranches;

  /// No description provided for @zonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Zones'**
  String get zonesTitle;

  /// No description provided for @zonesAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Zone'**
  String get zonesAddTooltip;

  /// No description provided for @zonesFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load zones'**
  String get zonesFailedLoad;

  /// No description provided for @zonesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get zonesRetry;

  /// No description provided for @zonesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No delivery zones'**
  String get zonesEmpty;

  /// No description provided for @zonesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first zone'**
  String get zonesEmptyHint;

  /// No description provided for @zonesMutationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get zonesMutationFailed;

  /// No description provided for @zonesInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get zonesInactive;

  /// No description provided for @zoneFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Zone'**
  String get zoneFormEditTitle;

  /// No description provided for @zoneFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Zone'**
  String get zoneFormNewTitle;

  /// No description provided for @zoneFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get zoneFormSave;

  /// No description provided for @zoneFormNameEn.
  ///
  /// In en, this message translates to:
  /// **'Zone Name (English)'**
  String get zoneFormNameEn;

  /// No description provided for @zoneFormNameAr.
  ///
  /// In en, this message translates to:
  /// **'Zone Name (Arabic) — optional'**
  String get zoneFormNameAr;

  /// No description provided for @zoneFormDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee (EGP)'**
  String get zoneFormDeliveryFee;

  /// No description provided for @zoneFormMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Value (EGP)'**
  String get zoneFormMinOrder;

  /// No description provided for @zoneFormMinItems.
  ///
  /// In en, this message translates to:
  /// **'Minimum Items (Rider Quantity)'**
  String get zoneFormMinItems;

  /// No description provided for @zoneFormMinOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Set to 0 to disable minimum order requirement.'**
  String get zoneFormMinOrderHint;

  /// No description provided for @zoneFormMinItemsHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum total number of items the customer must order. Set to 0 to disable.'**
  String get zoneFormMinItemsHint;

  /// No description provided for @zoneFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get zoneFormActive;

  /// No description provided for @zoneFormDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Zone'**
  String get zoneFormDelete;

  /// No description provided for @zoneFormDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Zone?'**
  String get zoneFormDeleteTitle;

  /// No description provided for @zoneFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get zoneFormCancel;

  /// No description provided for @zoneFormDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get zoneFormDeleteConfirm;

  /// No description provided for @zoneFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get zoneFormNameRequired;

  /// No description provided for @zoneFormFeeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid fee (0 or more)'**
  String get zoneFormFeeInvalid;

  /// No description provided for @zoneFormMinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 or more'**
  String get zoneFormMinInvalid;

  /// No description provided for @deliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryTitle;

  /// No description provided for @deliveryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active deliveries'**
  String get deliveryEmpty;

  /// No description provided for @deliveryAllSettled.
  ///
  /// In en, this message translates to:
  /// **'All orders are settled'**
  String get deliveryAllSettled;

  /// No description provided for @deliveryActive.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String deliveryActive(int count);

  /// No description provided for @deliveryRecentlyDelivered.
  ///
  /// In en, this message translates to:
  /// **'Recently Delivered'**
  String get deliveryRecentlyDelivered;

  /// No description provided for @deliveryPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get deliveryPrepare;

  /// No description provided for @deliveryDispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get deliveryDispatch;

  /// No description provided for @deliveryDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryDelivered;

  /// No description provided for @dispatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Board'**
  String get dispatchTitle;

  /// No description provided for @dispatchReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get dispatchReports;

  /// No description provided for @dispatchToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dispatchToday;

  /// No description provided for @dispatchSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search orders…'**
  String get dispatchSearchHint;

  /// No description provided for @dispatchFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get dispatchFailedLoad;

  /// No description provided for @dispatchRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dispatchRetry;

  /// No description provided for @dispatchDropHere.
  ///
  /// In en, this message translates to:
  /// **'Drop here'**
  String get dispatchDropHere;

  /// No description provided for @dispatchNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get dispatchNoOrders;

  /// No description provided for @dispatchCardPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get dispatchCardPaid;

  /// No description provided for @dispatchCardUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get dispatchCardUnpaid;

  /// No description provided for @dispatchCardCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get dispatchCardCall;

  /// No description provided for @dispatchCardWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get dispatchCardWhatsapp;

  /// No description provided for @dispatchCardMaps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get dispatchCardMaps;

  /// No description provided for @dispatchCardMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark Paid'**
  String get dispatchCardMarkPaid;

  /// No description provided for @dispatchCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get dispatchCardDetails;

  /// No description provided for @dispatchCardHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dispatchCardHistory;

  /// No description provided for @dispatchCardNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get dispatchCardNoHistory;

  /// No description provided for @dispatchCardPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get dispatchCardPayment;

  /// No description provided for @dispatchCardTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dispatchCardTotal;

  /// No description provided for @dispatchCardDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get dispatchCardDeliveryFee;

  /// No description provided for @dispatchCardCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get dispatchCardCustomer;

  /// No description provided for @dispatchCardAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get dispatchCardAddress;

  /// No description provided for @dispatchCardNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get dispatchCardNotes;

  /// No description provided for @dispatchCardDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get dispatchCardDriver;

  /// No description provided for @dispatchCardItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get dispatchCardItems;

  /// No description provided for @dispatchCardPrintInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get dispatchCardPrintInvoice;

  /// No description provided for @dispatchCardCopyInvoice.
  ///
  /// In en, this message translates to:
  /// **'Copy Invoice Text'**
  String get dispatchCardCopyInvoice;

  /// No description provided for @dispatchCardInvoiceCopied.
  ///
  /// In en, this message translates to:
  /// **'Invoice copied to clipboard'**
  String get dispatchCardInvoiceCopied;

  /// No description provided for @dispatchCardAssignDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get dispatchCardAssignDriver;

  /// No description provided for @dispatchCardChangeDriver.
  ///
  /// In en, this message translates to:
  /// **'Change Driver'**
  String get dispatchCardChangeDriver;

  /// No description provided for @dispatchCardUnassignDriver.
  ///
  /// In en, this message translates to:
  /// **'Unassign Driver'**
  String get dispatchCardUnassignDriver;

  /// No description provided for @dispatchCardNoDrivers.
  ///
  /// In en, this message translates to:
  /// **'No delivery staff found.'**
  String get dispatchCardNoDrivers;

  /// No description provided for @dispatchCardDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit amount'**
  String get dispatchCardDeposit;

  /// No description provided for @dispatchCardDepositLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get dispatchCardDepositLabel;

  /// No description provided for @dispatchCardDepositEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dispatchCardDepositEdit;

  /// No description provided for @dispatchCardSetDeposit.
  ///
  /// In en, this message translates to:
  /// **'Set Deposit'**
  String get dispatchCardSetDeposit;

  /// No description provided for @dispatchCardSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dispatchCardSave;

  /// No description provided for @dispatchCardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dispatchCardCancel;

  /// No description provided for @dailyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Report'**
  String get dailyReportTitle;

  /// No description provided for @dailyReportSingleDay.
  ///
  /// In en, this message translates to:
  /// **'Single Day'**
  String get dailyReportSingleDay;

  /// No description provided for @dailyReportDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dailyReportDateRange;

  /// No description provided for @dailyReportToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dailyReportToday;

  /// No description provided for @dailyReportChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get dailyReportChange;

  /// No description provided for @dailyReportNoAssigned.
  ///
  /// In en, this message translates to:
  /// **'No assigned orders'**
  String get dailyReportNoAssigned;

  /// No description provided for @dailyReportUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned Orders ({count})'**
  String dailyReportUnassigned(int count);

  /// No description provided for @dailyReportAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dailyReportAdd;

  /// No description provided for @dailyReportAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get dailyReportAddExpense;

  /// No description provided for @dailyReportEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get dailyReportEditExpense;

  /// No description provided for @dailyReportCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dailyReportCancel;

  /// No description provided for @dailyReportSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dailyReportSave;

  /// No description provided for @dailyReportDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get dailyReportDeleteExpense;

  /// No description provided for @driverReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Report'**
  String get driverReportTitle;

  /// No description provided for @driverReportFilterRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get driverReportFilterRange;

  /// No description provided for @driverReportFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get driverReportFilterAll;

  /// No description provided for @driverReportFilterByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get driverReportFilterByDate;

  /// No description provided for @driverReportAllDates.
  ///
  /// In en, this message translates to:
  /// **'All Dates'**
  String get driverReportAllDates;

  /// No description provided for @driverReportClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get driverReportClear;

  /// No description provided for @driverReportDrivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get driverReportDrivers;

  /// No description provided for @driverReportNoDrivers.
  ///
  /// In en, this message translates to:
  /// **'No drivers'**
  String get driverReportNoDrivers;

  /// No description provided for @driverReportCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get driverReportCollected;

  /// No description provided for @driverReportCustomShipping.
  ///
  /// In en, this message translates to:
  /// **'Custom shipping fee'**
  String get driverReportCustomShipping;

  /// No description provided for @driverReportTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get driverReportTotalOrders;

  /// No description provided for @driverReportCashOrders.
  ///
  /// In en, this message translates to:
  /// **'Cash Orders'**
  String get driverReportCashOrders;

  /// No description provided for @driverReportInstapay.
  ///
  /// In en, this message translates to:
  /// **'Instapay'**
  String get driverReportInstapay;

  /// No description provided for @reportsTabSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get reportsTabSummary;

  /// No description provided for @reportsTabDrivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get reportsTabDrivers;

  /// No description provided for @reportsTabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportsTabExpenses;

  /// No description provided for @reportsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get reportsRetry;

  /// No description provided for @reportsNoDrivers.
  ///
  /// In en, this message translates to:
  /// **'No drivers found'**
  String get reportsNoDrivers;

  /// No description provided for @reportsSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Select a driver'**
  String get reportsSelectDriver;

  /// No description provided for @reportsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reportsToday;

  /// No description provided for @reportsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get reportsAdd;

  /// No description provided for @reportsNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get reportsNoExpenses;

  /// No description provided for @reportsChangeRange.
  ///
  /// In en, this message translates to:
  /// **'Change range'**
  String get reportsChangeRange;

  /// No description provided for @reportsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reportsTotal;

  /// No description provided for @reportsTypes.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get reportsTypes;

  /// No description provided for @reportsDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get reportsDays;

  /// No description provided for @reportsSetDeposit.
  ///
  /// In en, this message translates to:
  /// **'Set deposit'**
  String get reportsSetDeposit;

  /// No description provided for @reportsAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get reportsAmount;

  /// No description provided for @reportsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get reportsSave;

  /// No description provided for @reportsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reportsCancel;

  /// No description provided for @reportsDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get reportsDeleteExpense;

  /// No description provided for @reportsModeSingleDay.
  ///
  /// In en, this message translates to:
  /// **'Single Day'**
  String get reportsModeSingleDay;

  /// No description provided for @reportsModeDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get reportsModeDateRange;

  /// No description provided for @reportsIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get reportsIncomeTitle;

  /// No description provided for @reportsTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get reportsTotalSales;

  /// No description provided for @reportsDeliveryFees.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fees'**
  String get reportsDeliveryFees;

  /// No description provided for @reportsDeliveryCost.
  ///
  /// In en, this message translates to:
  /// **'Actual Delivery Cost'**
  String get reportsDeliveryCost;

  /// No description provided for @reportsNetSales.
  ///
  /// In en, this message translates to:
  /// **'Net Sales'**
  String get reportsNetSales;

  /// No description provided for @reportsTotalCogs.
  ///
  /// In en, this message translates to:
  /// **'Total COGS'**
  String get reportsTotalCogs;

  /// No description provided for @reportsGrossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get reportsGrossProfit;

  /// No description provided for @reportsLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get reportsLoss;

  /// No description provided for @reportsCashFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get reportsCashFlowTitle;

  /// No description provided for @reportsCashSales.
  ///
  /// In en, this message translates to:
  /// **'Cash Sales'**
  String get reportsCashSales;

  /// No description provided for @reportsInstapay.
  ///
  /// In en, this message translates to:
  /// **'Instapay'**
  String get reportsInstapay;

  /// No description provided for @reportsDepositsPaid.
  ///
  /// In en, this message translates to:
  /// **'Deposits Paid'**
  String get reportsDepositsPaid;

  /// No description provided for @reportsDriversOwe.
  ///
  /// In en, this message translates to:
  /// **'Drivers Owe'**
  String get reportsDriversOwe;

  /// No description provided for @reportsTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get reportsTotalExpenses;

  /// No description provided for @reportsNetCash.
  ///
  /// In en, this message translates to:
  /// **'Net Cash'**
  String get reportsNetCash;

  /// No description provided for @reportsDeficit.
  ///
  /// In en, this message translates to:
  /// **'Deficit'**
  String get reportsDeficit;

  /// No description provided for @reportsDriverAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Accounts'**
  String get reportsDriverAccountsTitle;

  /// No description provided for @reportsNoAssignedOrders.
  ///
  /// In en, this message translates to:
  /// **'No assigned orders'**
  String get reportsNoAssignedOrders;

  /// No description provided for @reportsZoneAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Zone Accounts'**
  String get reportsZoneAccountsTitle;

  /// No description provided for @reportsNoZoneData.
  ///
  /// In en, this message translates to:
  /// **'No zone data'**
  String get reportsNoZoneData;

  /// No description provided for @reportsAllOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get reportsAllOrdersTitle;

  /// No description provided for @reportsNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get reportsNoOrders;

  /// No description provided for @reportsCustomerFee.
  ///
  /// In en, this message translates to:
  /// **'Customer Fee'**
  String get reportsCustomerFee;

  /// No description provided for @reportsZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get reportsZoneLabel;

  /// No description provided for @reportsOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get reportsOrdersLabel;

  /// No description provided for @reportsCustFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cust. Fee'**
  String get reportsCustFeeLabel;

  /// No description provided for @reportsActualCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Actual Cost'**
  String get reportsActualCostLabel;

  /// No description provided for @reportsEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reportsEditLabel;

  /// No description provided for @reportsSetCost.
  ///
  /// In en, this message translates to:
  /// **'Set cost'**
  String get reportsSetCost;

  /// No description provided for @reportsTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get reportsTotalOrders;

  /// No description provided for @reportsCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get reportsCashLabel;

  /// No description provided for @reportsInstapayLabel.
  ///
  /// In en, this message translates to:
  /// **'Instapay'**
  String get reportsInstapayLabel;

  /// No description provided for @reportsDepositsLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get reportsDepositsLabel;

  /// No description provided for @reportsDriverOwesLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver Owes'**
  String get reportsDriverOwesLabel;

  /// No description provided for @reportsOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get reportsOwed;

  /// No description provided for @reportsOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get reportsOrdersTitle;

  /// No description provided for @reportsDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get reportsDue;

  /// No description provided for @reportsAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get reportsAddExpense;

  /// No description provided for @reportsEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get reportsEditExpense;

  /// No description provided for @reportsTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reportsTypeLabel;

  /// No description provided for @reportsTotalHeader.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reportsTotalHeader;

  /// No description provided for @reportsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get reportsDeleteConfirm;

  /// No description provided for @reportsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get reportsDelete;

  /// No description provided for @reportsShippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get reportsShippingLabel;

  /// No description provided for @bannersTitle.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get bannersTitle;

  /// No description provided for @bannersRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bannersRetry;

  /// No description provided for @bannersFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get bannersFailedLoad;

  /// No description provided for @bannersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No banners yet'**
  String get bannersEmpty;

  /// No description provided for @bannersEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first banner'**
  String get bannersEmptyHint;

  /// No description provided for @bannersDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Banner'**
  String get bannersDeleteTitle;

  /// No description provided for @bannersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bannersCancel;

  /// No description provided for @bannersDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get bannersDelete;

  /// No description provided for @bannersMutationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get bannersMutationFailed;

  /// No description provided for @bannerFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Banner'**
  String get bannerFormEditTitle;

  /// No description provided for @bannerFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Banner'**
  String get bannerFormNewTitle;

  /// No description provided for @bannerFormImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get bannerFormImageUrl;

  /// No description provided for @bannerFormImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Image URL is required'**
  String get bannerFormImageRequired;

  /// No description provided for @bannerFormTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get bannerFormTitleField;

  /// No description provided for @bannerFormSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get bannerFormSortOrder;

  /// No description provided for @bannerFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bannerFormActive;

  /// No description provided for @bannerFormOnTapAction.
  ///
  /// In en, this message translates to:
  /// **'On Tap Action'**
  String get bannerFormOnTapAction;

  /// No description provided for @bannerFormUrlToOpen.
  ///
  /// In en, this message translates to:
  /// **'URL to Open'**
  String get bannerFormUrlToOpen;

  /// No description provided for @bannerFormUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get bannerFormUrlRequired;

  /// No description provided for @bannerFormSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get bannerFormSelectProduct;

  /// No description provided for @bannerFormSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get bannerFormSelectCategory;

  /// No description provided for @bannerFormTapProduct.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a product'**
  String get bannerFormTapProduct;

  /// No description provided for @bannerFormTapCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a category'**
  String get bannerFormTapCategory;

  /// No description provided for @bannerFormStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date (optional)'**
  String get bannerFormStartDate;

  /// No description provided for @bannerFormEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date (optional)'**
  String get bannerFormEndDate;

  /// No description provided for @bannerFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get bannerFormSaveChanges;

  /// No description provided for @bannerFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Banner'**
  String get bannerFormCreate;

  /// No description provided for @bannerFormInvalidImage.
  ///
  /// In en, this message translates to:
  /// **'Invalid image URL'**
  String get bannerFormInvalidImage;

  /// No description provided for @popupAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popup Ads'**
  String get popupAdsTitle;

  /// No description provided for @popupAdsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No popup ads yet'**
  String get popupAdsEmpty;

  /// No description provided for @popupAdsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Popup Ad'**
  String get popupAdsCreate;

  /// No description provided for @popupAdsEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String popupAdsEnds(String date);

  /// No description provided for @popupAdsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get popupAdsEdit;

  /// No description provided for @popupAdsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get popupAdsDelete;

  /// No description provided for @popupAdsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Popup Ad?'**
  String get popupAdsDeleteTitle;

  /// No description provided for @popupAdsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get popupAdsCancel;

  /// No description provided for @popupAdFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Popup Ad'**
  String get popupAdFormEditTitle;

  /// No description provided for @popupAdFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Popup Ad'**
  String get popupAdFormNewTitle;

  /// No description provided for @popupAdFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get popupAdFormSave;

  /// No description provided for @popupAdFormBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get popupAdFormBasicInfo;

  /// No description provided for @popupAdFormImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get popupAdFormImage;

  /// No description provided for @popupAdFormButton.
  ///
  /// In en, this message translates to:
  /// **'Button (optional)'**
  String get popupAdFormButton;

  /// No description provided for @popupAdFormSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule (optional)'**
  String get popupAdFormSchedule;

  /// No description provided for @popupAdFormTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get popupAdFormTitleField;

  /// No description provided for @popupAdFormTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title required'**
  String get popupAdFormTitleRequired;

  /// No description provided for @popupAdFormBody.
  ///
  /// In en, this message translates to:
  /// **'Body text (optional)'**
  String get popupAdFormBody;

  /// No description provided for @popupAdFormImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get popupAdFormImageUrl;

  /// No description provided for @popupAdFormUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get popupAdFormUpload;

  /// No description provided for @popupAdFormButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Button label'**
  String get popupAdFormButtonLabel;

  /// No description provided for @popupAdFormButtonUrl.
  ///
  /// In en, this message translates to:
  /// **'Button URL'**
  String get popupAdFormButtonUrl;

  /// No description provided for @popupAdFormStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get popupAdFormStartDate;

  /// No description provided for @popupAdFormEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get popupAdFormEndDate;

  /// No description provided for @popupAdFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get popupAdFormActive;

  /// No description provided for @popupAdFormUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String popupAdFormUploadFailed(String error);

  /// No description provided for @popupAdFormFrequency.
  ///
  /// In en, this message translates to:
  /// **'Show frequency'**
  String get popupAdFormFrequency;

  /// No description provided for @popupAdFreqEverySession.
  ///
  /// In en, this message translates to:
  /// **'Every session'**
  String get popupAdFreqEverySession;

  /// No description provided for @popupAdFreqOncePerDay.
  ///
  /// In en, this message translates to:
  /// **'Once per day'**
  String get popupAdFreqOncePerDay;

  /// No description provided for @popupAdFreqOnceEver.
  ///
  /// In en, this message translates to:
  /// **'Once ever'**
  String get popupAdFreqOnceEver;

  /// No description provided for @popupAdFormCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown Timer (optional)'**
  String get popupAdFormCountdown;

  /// No description provided for @popupAdFormCountdownAt.
  ///
  /// In en, this message translates to:
  /// **'Countdown ends at'**
  String get popupAdFormCountdownAt;

  /// No description provided for @promoCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo Codes'**
  String get promoCodesTitle;

  /// No description provided for @promoCodesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get promoCodesRetry;

  /// No description provided for @promoCodesFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get promoCodesFailedLoad;

  /// No description provided for @promoCodesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No promo codes'**
  String get promoCodesEmpty;

  /// No description provided for @promoCodesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create one'**
  String get promoCodesEmptyHint;

  /// No description provided for @promoCodesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get promoCodesFilterAll;

  /// No description provided for @promoCodesFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get promoCodesFilterActive;

  /// No description provided for @promoCodesFilterExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get promoCodesFilterExpired;

  /// No description provided for @promoCodesFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get promoCodesFilterInactive;

  /// No description provided for @promoCodesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Promo Code'**
  String get promoCodesDeleteTitle;

  /// No description provided for @promoCodesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get promoCodesCancel;

  /// No description provided for @promoCodesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get promoCodesDelete;

  /// No description provided for @promoCodes_mutationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get promoCodes_mutationFailed;

  /// No description provided for @promoCodesCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied {code}'**
  String promoCodesCopied(String code);

  /// No description provided for @promoCodeFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Promo Code'**
  String get promoCodeFormEditTitle;

  /// No description provided for @promoCodeFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Promo Code'**
  String get promoCodeFormNewTitle;

  /// No description provided for @promoCodeFormCodeField.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCodeFormCodeField;

  /// No description provided for @promoCodeFormCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Code is required'**
  String get promoCodeFormCodeRequired;

  /// No description provided for @promoCodeFormDiscountType.
  ///
  /// In en, this message translates to:
  /// **'Discount Type'**
  String get promoCodeFormDiscountType;

  /// No description provided for @promoCodeFormDiscountPct.
  ///
  /// In en, this message translates to:
  /// **'Discount Percentage'**
  String get promoCodeFormDiscountPct;

  /// No description provided for @promoCodeFormDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount Amount (EGP)'**
  String get promoCodeFormDiscountAmount;

  /// No description provided for @promoCodeFormInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid value'**
  String get promoCodeFormInvalidValue;

  /// No description provided for @promoCodeFormPctMax.
  ///
  /// In en, this message translates to:
  /// **'Percentage cannot exceed 100%'**
  String get promoCodeFormPctMax;

  /// No description provided for @promoCodeFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get promoCodeFormDescription;

  /// No description provided for @promoCodeFormMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Value (EGP)'**
  String get promoCodeFormMinOrder;

  /// No description provided for @promoCodeFormMaxUses.
  ///
  /// In en, this message translates to:
  /// **'Max Total Uses'**
  String get promoCodeFormMaxUses;

  /// No description provided for @promoCodeFormPerUser.
  ///
  /// In en, this message translates to:
  /// **'Per User Limit'**
  String get promoCodeFormPerUser;

  /// No description provided for @promoCodeFormMin1.
  ///
  /// In en, this message translates to:
  /// **'Min 1'**
  String get promoCodeFormMin1;

  /// No description provided for @promoCodeFormStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date (optional)'**
  String get promoCodeFormStartDate;

  /// No description provided for @promoCodeFormExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date (optional)'**
  String get promoCodeFormExpiryDate;

  /// No description provided for @promoCodeFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get promoCodeFormActive;

  /// No description provided for @promoCodeFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get promoCodeFormSaveChanges;

  /// No description provided for @promoCodeFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Promo Code'**
  String get promoCodeFormCreate;

  /// No description provided for @promoCodeFormGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate random code'**
  String get promoCodeFormGenerate;

  /// No description provided for @loyaltyTitle.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Management'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyTabRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get loyaltyTabRules;

  /// No description provided for @loyaltyTabSpend.
  ///
  /// In en, this message translates to:
  /// **'Spend Milestones'**
  String get loyaltyTabSpend;

  /// No description provided for @loyaltyTabPoints.
  ///
  /// In en, this message translates to:
  /// **'Points Rewards'**
  String get loyaltyTabPoints;

  /// No description provided for @loyaltyTabTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get loyaltyTabTransactions;

  /// No description provided for @loyaltyFilterCustomer.
  ///
  /// In en, this message translates to:
  /// **'Filter by customer ID…'**
  String get loyaltyFilterCustomer;

  /// No description provided for @loyaltyNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get loyaltyNoTransactions;

  /// No description provided for @loyaltyTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Loyalty transactions will appear here'**
  String get loyaltyTransactionsHint;

  /// No description provided for @loyaltyTypeCashback.
  ///
  /// In en, this message translates to:
  /// **'Cashback Event'**
  String get loyaltyTypeCashback;

  /// No description provided for @loyaltyTypeBaseEarn.
  ///
  /// In en, this message translates to:
  /// **'Base Earn'**
  String get loyaltyTypeBaseEarn;

  /// No description provided for @loyaltyTypeFreeProduct.
  ///
  /// In en, this message translates to:
  /// **'Free Product'**
  String get loyaltyTypeFreeProduct;

  /// No description provided for @loyaltyTypeFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get loyaltyTypeFreeDelivery;

  /// No description provided for @loyaltyGoalFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Points Reward'**
  String get loyaltyGoalFormEditTitle;

  /// No description provided for @loyaltyGoalFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Points Reward'**
  String get loyaltyGoalFormNewTitle;

  /// No description provided for @loyaltyGoalFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get loyaltyGoalFormSave;

  /// No description provided for @loyaltyGoalFormIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon (emoji)'**
  String get loyaltyGoalFormIcon;

  /// No description provided for @loyaltyGoalFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get loyaltyGoalFormTitle;

  /// No description provided for @loyaltyGoalFormTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get loyaltyGoalFormTitleRequired;

  /// No description provided for @loyaltyGoalFormPointsRequired.
  ///
  /// In en, this message translates to:
  /// **'Points Required'**
  String get loyaltyGoalFormPointsRequired;

  /// No description provided for @loyaltyGoalFormPointsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter points greater than 0'**
  String get loyaltyGoalFormPointsInvalid;

  /// No description provided for @loyaltyGoalFormRewardType.
  ///
  /// In en, this message translates to:
  /// **'Reward Type'**
  String get loyaltyGoalFormRewardType;

  /// No description provided for @loyaltyGoalFormFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get loyaltyGoalFormFreeDelivery;

  /// No description provided for @loyaltyGoalFormFreeProduct.
  ///
  /// In en, this message translates to:
  /// **'Free Product'**
  String get loyaltyGoalFormFreeProduct;

  /// No description provided for @loyaltyGoalFormSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Free Product'**
  String get loyaltyGoalFormSelectProduct;

  /// No description provided for @loyaltyGoalFormTapProduct.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a product'**
  String get loyaltyGoalFormTapProduct;

  /// No description provided for @loyaltyGoalFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description — optional'**
  String get loyaltyGoalFormDescription;

  /// No description provided for @loyaltyGoalFormSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get loyaltyGoalFormSortOrder;

  /// No description provided for @loyaltyGoalFormSortInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 or more'**
  String get loyaltyGoalFormSortInvalid;

  /// No description provided for @loyaltyGoalFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loyaltyGoalFormActive;

  /// No description provided for @loyaltyGoalFormDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Reward'**
  String get loyaltyGoalFormDelete;

  /// No description provided for @loyaltyGoalFormDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Reward?'**
  String get loyaltyGoalFormDeleteTitle;

  /// No description provided for @loyaltyGoalFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get loyaltyGoalFormCancel;

  /// No description provided for @loyaltyGoalFormDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get loyaltyGoalFormDeleteConfirm;

  /// No description provided for @loyaltyRuleFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Rule'**
  String get loyaltyRuleFormEditTitle;

  /// No description provided for @loyaltyRuleFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Rule'**
  String get loyaltyRuleFormNewTitle;

  /// No description provided for @loyaltyRuleFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get loyaltyRuleFormSave;

  /// No description provided for @loyaltyRuleFormName.
  ///
  /// In en, this message translates to:
  /// **'Rule Name'**
  String get loyaltyRuleFormName;

  /// No description provided for @loyaltyRuleFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get loyaltyRuleFormNameRequired;

  /// No description provided for @loyaltyRuleFormType.
  ///
  /// In en, this message translates to:
  /// **'Rule Type'**
  String get loyaltyRuleFormType;

  /// No description provided for @loyaltyRuleFormBaseEarn.
  ///
  /// In en, this message translates to:
  /// **'Base Earn'**
  String get loyaltyRuleFormBaseEarn;

  /// No description provided for @loyaltyRuleFormCashback.
  ///
  /// In en, this message translates to:
  /// **'Cashback Event'**
  String get loyaltyRuleFormCashback;

  /// No description provided for @loyaltyRuleFormPointsPerEgp.
  ///
  /// In en, this message translates to:
  /// **'Points per EGP Spent'**
  String get loyaltyRuleFormPointsPerEgp;

  /// No description provided for @loyaltyRuleFormPointsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a value greater than 0'**
  String get loyaltyRuleFormPointsInvalid;

  /// No description provided for @loyaltyRuleFormMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Value (EGP) — optional'**
  String get loyaltyRuleFormMinOrder;

  /// No description provided for @loyaltyRuleFormValidFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid From — optional'**
  String get loyaltyRuleFormValidFrom;

  /// No description provided for @loyaltyRuleFormValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid Until — optional'**
  String get loyaltyRuleFormValidUntil;

  /// No description provided for @loyaltyRuleFormDailyStart.
  ///
  /// In en, this message translates to:
  /// **'Daily Start Time — optional'**
  String get loyaltyRuleFormDailyStart;

  /// No description provided for @loyaltyRuleFormDailyEnd.
  ///
  /// In en, this message translates to:
  /// **'Daily End Time — optional'**
  String get loyaltyRuleFormDailyEnd;

  /// No description provided for @loyaltyRuleFormSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get loyaltyRuleFormSelectDate;

  /// No description provided for @loyaltyRuleFormSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get loyaltyRuleFormSelectTime;

  /// No description provided for @loyaltyRuleFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loyaltyRuleFormActive;

  /// No description provided for @loyaltyRuleFormDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Rule'**
  String get loyaltyRuleFormDelete;

  /// No description provided for @loyaltyRuleFormDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Rule?'**
  String get loyaltyRuleFormDeleteTitle;

  /// No description provided for @loyaltyRuleFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get loyaltyRuleFormCancel;

  /// No description provided for @loyaltyRuleFormDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get loyaltyRuleFormDeleteConfirm;

  /// No description provided for @spendGoalFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Spend Milestone'**
  String get spendGoalFormEditTitle;

  /// No description provided for @spendGoalFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Spend Milestone'**
  String get spendGoalFormNewTitle;

  /// No description provided for @spendGoalFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get spendGoalFormSave;

  /// No description provided for @spendGoalFormIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon (emoji)'**
  String get spendGoalFormIcon;

  /// No description provided for @spendGoalFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get spendGoalFormTitle;

  /// No description provided for @spendGoalFormTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get spendGoalFormTitleRequired;

  /// No description provided for @spendGoalFormSpendRequired.
  ///
  /// In en, this message translates to:
  /// **'Spend Required (EGP)'**
  String get spendGoalFormSpendRequired;

  /// No description provided for @spendGoalFormSpendInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a spend amount greater than 0'**
  String get spendGoalFormSpendInvalid;

  /// No description provided for @spendGoalFormRewardType.
  ///
  /// In en, this message translates to:
  /// **'Reward Type'**
  String get spendGoalFormRewardType;

  /// No description provided for @spendGoalFormFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get spendGoalFormFreeDelivery;

  /// No description provided for @spendGoalFormFreeProduct.
  ///
  /// In en, this message translates to:
  /// **'Free Product'**
  String get spendGoalFormFreeProduct;

  /// No description provided for @spendGoalFormDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get spendGoalFormDiscount;

  /// No description provided for @spendGoalFormDiscountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a discount between 1 and 100'**
  String get spendGoalFormDiscountInvalid;

  /// No description provided for @spendGoalFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description — optional'**
  String get spendGoalFormDescription;

  /// No description provided for @spendGoalFormSortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get spendGoalFormSortOrder;

  /// No description provided for @spendGoalFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get spendGoalFormActive;

  /// No description provided for @spendGoalFormDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Milestone'**
  String get spendGoalFormDelete;

  /// No description provided for @spendGoalFormDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Milestone?'**
  String get spendGoalFormDeleteTitle;

  /// No description provided for @spendGoalFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get spendGoalFormCancel;

  /// No description provided for @spendGoalFormDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get spendGoalFormDeleteConfirm;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get settingsServiceFee;

  /// No description provided for @settingsShowInCheckout.
  ///
  /// In en, this message translates to:
  /// **'Show in checkout'**
  String get settingsShowInCheckout;

  /// No description provided for @settingsShowInCheckoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appears as a line item on the order summary'**
  String get settingsShowInCheckoutSubtitle;

  /// No description provided for @settingsFeeAmount.
  ///
  /// In en, this message translates to:
  /// **'Fee Amount (EGP)'**
  String get settingsFeeAmount;

  /// No description provided for @settingsMaxPoints.
  ///
  /// In en, this message translates to:
  /// **'Max Points Per Order (0 = unlimited)'**
  String get settingsMaxPoints;

  /// No description provided for @settingsOnlineWindow.
  ///
  /// In en, this message translates to:
  /// **'Online User Window (minutes)'**
  String get settingsOnlineWindow;

  /// No description provided for @settingsOnlineWindowDesc.
  ///
  /// In en, this message translates to:
  /// **'A user is counted as \"online\" if active within this window'**
  String get settingsOnlineWindowDesc;

  /// No description provided for @settingsReferralBonusReferrer.
  ///
  /// In en, this message translates to:
  /// **'Referral Bonus — Referrer (pts)'**
  String get settingsReferralBonusReferrer;

  /// No description provided for @settingsReferralRewardNew.
  ///
  /// In en, this message translates to:
  /// **'Referral Reward — New User (pts)'**
  String get settingsReferralRewardNew;

  /// No description provided for @settingsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get settingsSaveChanges;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get settingsSaveFailed;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageArabic;

  /// No description provided for @csvTitle.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get csvTitle;

  /// No description provided for @csvTabProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get csvTabProducts;

  /// No description provided for @csvTabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get csvTabCustomers;

  /// No description provided for @csvTabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get csvTabOrders;

  /// No description provided for @csvExportProducts.
  ///
  /// In en, this message translates to:
  /// **'Export Products'**
  String get csvExportProducts;

  /// No description provided for @csvImportProducts.
  ///
  /// In en, this message translates to:
  /// **'Import Products'**
  String get csvImportProducts;

  /// No description provided for @csvExportCustomers.
  ///
  /// In en, this message translates to:
  /// **'Export Customers'**
  String get csvExportCustomers;

  /// No description provided for @csvImportCustomers.
  ///
  /// In en, this message translates to:
  /// **'Import Customers'**
  String get csvImportCustomers;

  /// No description provided for @csvExportOrders.
  ///
  /// In en, this message translates to:
  /// **'Export Orders'**
  String get csvExportOrders;

  /// No description provided for @csvExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get csvExportCsv;

  /// No description provided for @csvPickFile.
  ///
  /// In en, this message translates to:
  /// **'Pick CSV File'**
  String get csvPickFile;

  /// No description provided for @csvProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get csvProcessing;

  /// No description provided for @csvOrderImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Order import is not supported'**
  String get csvOrderImportWarning;

  /// No description provided for @csvProductImportPreview.
  ///
  /// In en, this message translates to:
  /// **'Product Import Preview'**
  String get csvProductImportPreview;

  /// No description provided for @csvCustomerImportPreview.
  ///
  /// In en, this message translates to:
  /// **'Customer Import Preview'**
  String get csvCustomerImportPreview;

  /// No description provided for @csvRows.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String csvRows(int count);

  /// No description provided for @csvAndMore.
  ///
  /// In en, this message translates to:
  /// **'… and {count} more'**
  String csvAndMore(int count);

  /// No description provided for @csvCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get csvCancel;

  /// No description provided for @csvImportRows.
  ///
  /// In en, this message translates to:
  /// **'Import {count} rows'**
  String csvImportRows(int count);

  /// No description provided for @csvExpectedColumns.
  ///
  /// In en, this message translates to:
  /// **'Expected CSV columns'**
  String get csvExpectedColumns;

  /// No description provided for @stubComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get stubComingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
