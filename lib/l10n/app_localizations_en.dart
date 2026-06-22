// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authAppTitle => 'Sabeh Dashboard';

  @override
  String get authSubtitle => 'Staff portal — sign in to continue';

  @override
  String get authPhoneLabel => 'Phone Number';

  @override
  String get authPhoneError => 'Enter a valid phone number';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordError => 'Enter your password';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get navHome => 'Home';

  @override
  String get navOrders => 'Orders';

  @override
  String get navDelivery => 'Delivery';

  @override
  String get navDispatch => 'Dispatch';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navProducts => 'Products';

  @override
  String get navCategories => 'Categories';

  @override
  String get navBranches => 'Branches';

  @override
  String get navZones => 'Zones';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLoyalty => 'Loyalty';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navStaff => 'Staff';

  @override
  String get navPromos => 'Promos';

  @override
  String get navBanners => 'Banners';

  @override
  String get navAds => 'Ads';

  @override
  String get navCsv => 'CSV';

  @override
  String get navMyRoutes => 'My Routes';

  @override
  String get navSignOut => 'Sign Out';

  @override
  String get navStaffFallback => 'Staff';

  @override
  String get homeGlance => 'Today at a glance';

  @override
  String get homeTotalOrders => 'Total Orders';

  @override
  String get homePending => 'Pending';

  @override
  String get homeInProgress => 'In Progress';

  @override
  String get homeDelivered => 'Delivered';

  @override
  String get homeActiveOrders => 'Active orders';

  @override
  String get homeAllCaughtUp => 'All caught up!';

  @override
  String get homeNoActiveOrders => 'No active orders right now';

  @override
  String get homeGoodMorning => 'Good morning ☀️';

  @override
  String get homeGoodAfternoon => 'Good afternoon 🌤';

  @override
  String get homeGoodEvening => 'Good evening 🌙';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsRefresh => 'Refresh';

  @override
  String get analyticsFilters => 'Filters';

  @override
  String get analyticsToday => 'Today';

  @override
  String get analytics7Days => '7 Days';

  @override
  String get analytics30Days => '30 Days';

  @override
  String get analyticsThisMonth => 'This Month';

  @override
  String get analyticsCustom => 'Custom';

  @override
  String get analyticsAllBranches => 'All Branches';

  @override
  String get analyticsOnlineNow => 'Online Now';

  @override
  String get analyticsLive => 'Live';

  @override
  String analyticsActiveInLast(int minutes) {
    return 'Active in last $minutes min';
  }

  @override
  String get analyticsTotalSales => 'Total Sales';

  @override
  String get analyticsOrders => 'Orders';

  @override
  String get analyticsTotalCogs => 'Total COGS';

  @override
  String get analyticsGrossProfit => 'Gross Profit';

  @override
  String get analyticsAvgOrderValue => 'Avg Order Value';

  @override
  String get analyticsDiscountsFreeItems => 'Discounts & Free Items';

  @override
  String get analyticsDeliveryCharges => 'Delivery Charges';

  @override
  String get analyticsTotalDiscounts => 'Total Discounts';

  @override
  String get analyticsLoyaltyDiscounts => 'Loyalty Discounts';

  @override
  String get analyticsPromoDiscounts => 'Promo Discounts';

  @override
  String get analyticsFreeDeliveryValue => 'Free Delivery Value';

  @override
  String get analyticsFreeDelivery => 'Free Delivery';

  @override
  String get analyticsFreeItems => 'Free Items';

  @override
  String get analyticsFulfillment => 'Fulfillment';

  @override
  String get analyticsCancellation => 'Cancellation';

  @override
  String get analyticsReturning => 'Returning';

  @override
  String get analyticsCustomerMetrics => 'Customer Metrics';

  @override
  String get analyticsUniqueCustomers => 'Unique Customers';

  @override
  String get analyticsDailySales => 'Daily Sales';

  @override
  String get analyticsSalesByZone => 'Sales by Delivery Zone';

  @override
  String get analyticsOrdersByStatus => 'Orders by Status';

  @override
  String get analyticsByRevenue => 'By Revenue';

  @override
  String get analyticsByQuantity => 'By Quantity';

  @override
  String get analyticsByViews => 'By Views';

  @override
  String get analyticsByAddToCart => 'By Add-to-Cart';

  @override
  String get analyticsShowLess => 'Show less';

  @override
  String get analyticsNoData => 'No data';

  @override
  String get analyticsDeviceType => 'Sessions by Device Type';

  @override
  String get analyticsAbandonedCarts => 'Abandoned Checkouts';

  @override
  String get analyticsCartItems => 'CART ITEMS';

  @override
  String get analyticsProduct => 'Product';

  @override
  String get analyticsViews => 'Views';

  @override
  String get analyticsCarts => 'Carts';

  @override
  String get analyticsEventTracking => 'Event Tracking';

  @override
  String get analyticsFailedLoad => 'Failed to load analytics';

  @override
  String get analyticsRetry => 'Retry';

  @override
  String get analyticsGuest => 'Guest';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersNewOrder => 'New Order';

  @override
  String get ordersTabAll => 'All';

  @override
  String get ordersTabPending => 'Pending';

  @override
  String get ordersTabConfirmed => 'Confirmed';

  @override
  String get ordersTabPreparing => 'Preparing';

  @override
  String get ordersTabDelivery => 'Delivery';

  @override
  String get ordersTabDone => 'Done';

  @override
  String get ordersTabCancelled => 'Cancelled';

  @override
  String get ordersFailedLoad => 'Failed to load orders';

  @override
  String get ordersRetry => 'Retry';

  @override
  String get ordersEmpty => 'No orders here';

  @override
  String get orderDetailsOrderInfo => 'Order Info';

  @override
  String get orderDetailsCreated => 'Created';

  @override
  String get orderDetailsPayment => 'Payment';

  @override
  String get orderDetailsStatus => 'Status';

  @override
  String get orderDetailsAddress => 'Address';

  @override
  String get orderDetailsNotes => 'Notes';

  @override
  String get orderDetailsPromoCode => 'Promo Code';

  @override
  String get orderDetailsDriver => 'Driver';

  @override
  String get orderDetailsSummary => 'Summary';

  @override
  String get orderDetailsDeliveryFee => 'Delivery Fee';

  @override
  String get orderDetailsServiceFee => 'Service Fee';

  @override
  String get orderDetailsDelivery => 'Delivery';

  @override
  String get orderDetailsTotal => 'Total';

  @override
  String get orderDetailsDeposit => 'Deposit (عربون)';

  @override
  String get orderDetailsAmountDue => 'Amount Due';

  @override
  String get orderDetailsRewardsApplied => 'Rewards Applied';

  @override
  String get orderDetailsSpendMilestone => 'Spend Milestone';

  @override
  String get orderDetailsPointsRedeemed => 'Points Redeemed';

  @override
  String get orderDetailsPointsEarned => 'Points Earned';

  @override
  String get orderDetailsFree => 'FREE';

  @override
  String get orderDetailsPrintInvoice => 'Print Invoice';

  @override
  String get orderDetailsCancelOrder => 'Cancel Order';

  @override
  String get orderDetailsCancelConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get orderDetailsNo => 'No';

  @override
  String get orderDetailsConfirmOrder => 'Confirm Order';

  @override
  String get orderDetailsStartPreparing => 'Start Preparing';

  @override
  String get orderDetailsSendForDelivery => 'Send for Delivery';

  @override
  String get orderDetailsMarkDelivered => 'Mark Delivered';

  @override
  String get createOrderTitle => 'New Order';

  @override
  String get createOrderStepCustomer => 'Customer';

  @override
  String get createOrderStepProducts => 'Products';

  @override
  String get createOrderStepDetails => 'Details';

  @override
  String get createOrderStepConfirm => 'Confirm';

  @override
  String get createOrderBack => 'Back';

  @override
  String get createOrderNext => 'Next';

  @override
  String get createOrderPlace => 'Place Order';

  @override
  String get createOrderSuccess => 'Order placed successfully!';

  @override
  String get createOrderFailed => 'Failed to place order';

  @override
  String get createOrderSearchCustomer => 'Search Existing Customer';

  @override
  String get createOrderSearchHint => 'Name, phone, or email…';

  @override
  String get createOrderNewCustomer => 'Or Create New Customer';

  @override
  String get createOrderFullName => 'Full Name';

  @override
  String get createOrderFullNameHint => 'Customer full name';

  @override
  String get createOrderPhone => 'Phone (optional)';

  @override
  String get createOrderUseAsCustomer => 'Use as Customer';

  @override
  String get createOrderAddCustomItem => 'Add Custom Item';

  @override
  String get createOrderItemName => 'Item Name *';

  @override
  String get createOrderItemPrice => 'Price (EGP) *';

  @override
  String get createOrderAddToOrder => 'Add to Order';

  @override
  String get createOrderSearchProducts => 'Search products…';

  @override
  String get createOrderSelectedItems => 'Selected Items';

  @override
  String get createOrderCustomItem => 'Custom Item';

  @override
  String get createOrderAllProducts => 'All Products';

  @override
  String get createOrderBranch => 'Branch *';

  @override
  String get createOrderSelectBranch => 'Select branch';

  @override
  String get createOrderDeliveryAddress => 'Delivery Address';

  @override
  String get createOrderNewAddress => 'New Address';

  @override
  String get createOrderSaveAddress => 'Save & Use Address';

  @override
  String get createOrderDeliveryZone => 'Delivery Zone';

  @override
  String get createOrderSelectZone => 'Select delivery zone';

  @override
  String get createOrderNoZone => 'No delivery zone';

  @override
  String get createOrderAddressLabel => 'Label';

  @override
  String get createOrderAddressLabelHint => 'e.g. Home, Work';

  @override
  String get createOrderStreet => 'Street *';

  @override
  String get createOrderStreetHint => 'Street name / area';

  @override
  String get createOrderBuilding => 'Building';

  @override
  String get createOrderBuildingHint => 'No.';

  @override
  String get createOrderFloor => 'Floor';

  @override
  String get createOrderFloorHint => 'No.';

  @override
  String get createOrderApt => 'Apt';

  @override
  String get createOrderAptHint => 'No.';

  @override
  String get createOrderLandmark => 'Landmark';

  @override
  String get createOrderLandmarkHint => 'Near…';

  @override
  String get createOrderDiscount => 'Discount (EGP)';

  @override
  String get createOrderOrderNotes => 'Order Notes';

  @override
  String get createOrderNotesHint => 'Any special instructions…';

  @override
  String get createOrderPaymentMethod => 'Payment Method';

  @override
  String get createOrderCash => 'Cash';

  @override
  String get createOrderInstapay => 'Instapay';

  @override
  String createOrderCartSummary(int count) {
    return 'Cart: $count item(s)';
  }

  @override
  String createOrderSubtotal(String amount) {
    return 'Subtotal: EGP $amount';
  }

  @override
  String get createOrderSummaryTitle => 'Order Summary';

  @override
  String get createOrderSummaryCustomer => 'Customer';

  @override
  String get createOrderSummaryDeliveryInfo => 'Delivery Info';

  @override
  String createOrderSummaryItems(int count) {
    return 'Items ($count)';
  }

  @override
  String get createOrderSummaryPayment => 'Payment';

  @override
  String get createOrderSummaryNotes => 'Notes';

  @override
  String get createOrderSummaryBranch => 'Branch';

  @override
  String get createOrderSummaryZone => 'Zone';

  @override
  String get createOrderSummaryAddress => 'Address';

  @override
  String get createOrderSummaryMethod => 'Method';

  @override
  String get createOrderSummarySubtotal => 'Subtotal';

  @override
  String get createOrderSummaryDelivery => 'Delivery';

  @override
  String get createOrderSummaryDiscount => 'Discount';

  @override
  String get createOrderSummaryTotal => 'Total';

  @override
  String get productsTitle => 'Products';

  @override
  String get productsAddProduct => 'Add Product';

  @override
  String get productsSearchHint => 'Search products...';

  @override
  String get productFormEditTitle => 'Edit Product';

  @override
  String get productFormNewTitle => 'New Product';

  @override
  String get productFormSave => 'Save';

  @override
  String get productFormActive => 'Active';

  @override
  String get productFormActiveSubtitle => 'Visible to customers';

  @override
  String get productFormBestSeller => 'Best Seller 🔥';

  @override
  String get productFormBestSellerSubtitle =>
      'Show in Top Sellers section on home screen';

  @override
  String get productFormAddOption => 'Add Option';

  @override
  String get productFormStock => 'Stock:';

  @override
  String get productFormPricePreview => 'Price Preview';

  @override
  String get productFormRelatedProducts => 'Related Products';

  @override
  String get productFormAdd => 'Add';

  @override
  String get productFormNoRelated => 'No related products added yet.';

  @override
  String get productFormSelectRelated => 'Select Related Product';

  @override
  String get productFormNoBranches => 'No branches found.';

  @override
  String get productFormNone => 'None';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesAddCategory => 'Add Category';

  @override
  String get categoriesSearchHint => 'Search categories...';

  @override
  String get categoriesDragReorder => 'Drag to reorder';

  @override
  String get categoriesEmpty => 'No categories yet';

  @override
  String get categoriesEmptyHint => 'Tap + to add your first category';

  @override
  String get categoriesDeleteTitle => 'Delete Category';

  @override
  String categoriesDeleteConfirm(String name) {
    return 'Remove \"$name\"? This will deactivate it.';
  }

  @override
  String get categoriesCancel => 'Cancel';

  @override
  String get categoriesDelete => 'Delete';

  @override
  String get categoriesInactive => 'Inactive';

  @override
  String get categoryFormEditTitle => 'Edit Category';

  @override
  String get categoryFormNewTitle => 'New Category';

  @override
  String get categoryFormSave => 'Save';

  @override
  String get categoryFormBranches => 'Branches';

  @override
  String get categoryFormName => 'Name';

  @override
  String get categoryFormMedia => 'Media';

  @override
  String get categoryFormVisibility => 'Visibility';

  @override
  String get categoryFormNameEn => 'Category Name (English)';

  @override
  String get categoryFormNameAr => 'Category Name (Arabic)';

  @override
  String get categoryFormCoverUrl => 'Cover Image URL';

  @override
  String get categoryFormActive => 'Active';

  @override
  String get categoryFormActiveSubtitle => 'Visible to customers';

  @override
  String get categoryFormAllBranches => 'All Branches';

  @override
  String get categoryFormSelectBranch => 'Select at least one branch.';

  @override
  String get categoryFormNoBranches => 'No branches found.';

  @override
  String get categoryFormRequired => 'Required';

  @override
  String get customersTitle => 'Customers';

  @override
  String get customersSearchHint => 'Search by name, email, or phone…';

  @override
  String get customersEmpty => 'No customers yet';

  @override
  String customersNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get customersFailedLoad => 'Failed to load customers';

  @override
  String get customersRetry => 'Retry';

  @override
  String get customersColCustomer => 'Customer';

  @override
  String get customersColEmail => 'Email';

  @override
  String get customersColPhone => 'Phone';

  @override
  String get customersColOrders => 'Orders';

  @override
  String get customersColLoyalty => 'Loyalty';

  @override
  String get customersColTotalSpent => 'Total Spent';

  @override
  String get customerDetailCreateOrder => 'Create Order';

  @override
  String get customerDetailLoyaltyPoints => 'Loyalty Points';

  @override
  String get customerDetailPoints => 'points';

  @override
  String get customerDetailAdjust => 'Adjust';

  @override
  String get customerDetailAdjustTitle => 'Adjust Loyalty Points';

  @override
  String get customerDetailAddPoints => '+ Add Points';

  @override
  String get customerDetailDeductPoints => '- Deduct Points';

  @override
  String get customerDetailAmount => 'Amount';

  @override
  String get customerDetailReason => 'Reason / Description';

  @override
  String get customerDetailConfirm => 'Confirm';

  @override
  String get customerDetailInternalNotes => 'Internal Notes';

  @override
  String get customerDetailNotesHint =>
      'Add internal notes about this customer…';

  @override
  String get customerDetailSaveNotes => 'Save Notes';

  @override
  String get customerDetailNoNotes => 'No notes yet';

  @override
  String get customerDetailBlocked => 'Blocked';

  @override
  String customerDetailJoined(String date) {
    return 'Joined $date';
  }

  @override
  String customerDetailRef(String code) {
    return 'Ref: $code';
  }

  @override
  String get customerDetailPastOrders => 'Past Orders';

  @override
  String get customerDetailNoOrders => 'No orders yet';

  @override
  String get branchesTitle => 'Branches';

  @override
  String get branchesAddTooltip => 'Add Branch';

  @override
  String get branchesEmpty => 'No branches yet';

  @override
  String get branchesEmptyHint => 'Tap + to add the first branch';

  @override
  String get branchesFailedLoad => 'Failed to load branches';

  @override
  String get branchesRetry => 'Retry';

  @override
  String get branchesMutationFailed => 'Operation failed';

  @override
  String get branchFormEditTitle => 'Edit Branch';

  @override
  String get branchFormNewTitle => 'New Branch';

  @override
  String get branchFormSave => 'Save';

  @override
  String get branchFormBranchName => 'Branch Name';

  @override
  String get branchFormLatitude => 'Latitude';

  @override
  String get branchFormLongitude => 'Longitude';

  @override
  String get branchFormRadius => 'Coverage Radius (km)';

  @override
  String get branchFormActive => 'Active';

  @override
  String get branchFormDelete => 'Delete Branch';

  @override
  String get branchFormDeleteTitle => 'Delete Branch?';

  @override
  String get branchFormCancel => 'Cancel';

  @override
  String get branchFormDeleteConfirm => 'Delete';

  @override
  String get branchFormNameRequired => 'Name is required';

  @override
  String get branchFormLatInvalid => 'Enter a valid latitude';

  @override
  String get branchFormLatRange => 'Latitude must be between -90 and 90';

  @override
  String get branchFormLonInvalid => 'Enter a valid longitude';

  @override
  String get branchFormLonRange => 'Longitude must be between -180 and 180';

  @override
  String get branchFormRadiusInvalid => 'Enter a valid radius > 0';

  @override
  String get staffTitle => 'Staff';

  @override
  String get staffAddTooltip => 'Add Staff';

  @override
  String get staffFilterAll => 'All';

  @override
  String get staffEmpty => 'No staff members';

  @override
  String get staffEmptyHint => 'Tap + to add the first member';

  @override
  String get staffFailedLoad => 'Failed to load staff';

  @override
  String get staffRetry => 'Retry';

  @override
  String get staffMutationFailed => 'Operation failed';

  @override
  String get staffRemoveTitle => 'Remove Staff Member';

  @override
  String staffRemoveConfirm(String name) {
    return 'Remove $name from staff?';
  }

  @override
  String get staffCancel => 'Cancel';

  @override
  String get staffRemove => 'Remove';

  @override
  String get staffBranchScoped => 'Branch scoped';

  @override
  String get staffFormEditTitle => 'Edit Staff Member';

  @override
  String get staffFormNewTitle => 'Add Staff Member';

  @override
  String get staffFormFullName => 'Full Name';

  @override
  String get staffFormPhoneOptional => 'Phone (optional)';

  @override
  String get staffFormPhone => 'Phone Number';

  @override
  String get staffFormTempPassword => 'Temporary Password';

  @override
  String get staffFormRole => 'Role';

  @override
  String get staffFormBranches => 'Branches';

  @override
  String get staffFormActive => 'Active';

  @override
  String get staffFormSaveChanges => 'Save Changes';

  @override
  String get staffFormCreate => 'Create Staff Account';

  @override
  String get staffFormNameRequired => 'Name is required';

  @override
  String get staffFormPhoneRequired => 'Phone number is required';

  @override
  String get staffFormPasswordLength =>
      'Password must be at least 6 characters';

  @override
  String get staffFormBranchRequired => 'Select at least one branch';

  @override
  String get staffFormNoBranches => 'No branches available';

  @override
  String get zonesTitle => 'Delivery Zones';

  @override
  String get zonesAddTooltip => 'Add Zone';

  @override
  String get zonesFailedLoad => 'Failed to load zones';

  @override
  String get zonesRetry => 'Retry';

  @override
  String get zonesEmpty => 'No delivery zones';

  @override
  String get zonesEmptyHint => 'Tap + to add the first zone';

  @override
  String get zonesMutationFailed => 'Operation failed';

  @override
  String get zonesInactive => 'Inactive';

  @override
  String get zoneFormEditTitle => 'Edit Zone';

  @override
  String get zoneFormNewTitle => 'New Zone';

  @override
  String get zoneFormSave => 'Save';

  @override
  String get zoneFormNameEn => 'Zone Name (English)';

  @override
  String get zoneFormNameAr => 'Zone Name (Arabic) — optional';

  @override
  String get zoneFormDeliveryFee => 'Delivery Fee (EGP)';

  @override
  String get zoneFormMinOrder => 'Minimum Order Value (EGP)';

  @override
  String get zoneFormMinItems => 'Minimum Items (Rider Quantity)';

  @override
  String get zoneFormMinOrderHint =>
      'Set to 0 to disable minimum order requirement.';

  @override
  String get zoneFormMinItemsHint =>
      'Minimum total number of items the customer must order. Set to 0 to disable.';

  @override
  String get zoneFormActive => 'Active';

  @override
  String get zoneFormDelete => 'Delete Zone';

  @override
  String get zoneFormDeleteTitle => 'Delete Zone?';

  @override
  String get zoneFormCancel => 'Cancel';

  @override
  String get zoneFormDeleteConfirm => 'Delete';

  @override
  String get zoneFormNameRequired => 'Name is required';

  @override
  String get zoneFormFeeInvalid => 'Enter a valid fee (0 or more)';

  @override
  String get zoneFormMinInvalid => 'Enter 0 or more';

  @override
  String get deliveryTitle => 'Delivery';

  @override
  String get deliveryEmpty => 'No active deliveries';

  @override
  String get deliveryAllSettled => 'All orders are settled';

  @override
  String deliveryActive(int count) {
    return 'Active ($count)';
  }

  @override
  String get deliveryRecentlyDelivered => 'Recently Delivered';

  @override
  String get deliveryPrepare => 'Prepare';

  @override
  String get deliveryDispatch => 'Dispatch';

  @override
  String get deliveryDelivered => 'Delivered';

  @override
  String get dispatchTitle => 'Dispatch Board';

  @override
  String get dispatchReports => 'Reports';

  @override
  String get dispatchToday => 'Today';

  @override
  String get dispatchSearchHint => 'Search orders…';

  @override
  String get dispatchFailedLoad => 'Failed to load orders';

  @override
  String get dispatchRetry => 'Retry';

  @override
  String get dispatchDropHere => 'Drop here';

  @override
  String get dispatchNoOrders => 'No orders';

  @override
  String get dispatchCardPaid => 'Paid';

  @override
  String get dispatchCardUnpaid => 'Unpaid';

  @override
  String get dispatchCardCall => 'Call';

  @override
  String get dispatchCardWhatsapp => 'WhatsApp';

  @override
  String get dispatchCardMaps => 'Maps';

  @override
  String get dispatchCardMarkPaid => 'Mark Paid';

  @override
  String get dispatchCardDetails => 'Details';

  @override
  String get dispatchCardHistory => 'History';

  @override
  String get dispatchCardNoHistory => 'No history yet';

  @override
  String get dispatchCardPayment => 'Payment';

  @override
  String get dispatchCardTotal => 'Total';

  @override
  String get dispatchCardDeliveryFee => 'Delivery Fee';

  @override
  String get dispatchCardCustomer => 'Customer';

  @override
  String get dispatchCardAddress => 'Address';

  @override
  String get dispatchCardNotes => 'Notes';

  @override
  String get dispatchCardDriver => 'Driver';

  @override
  String get dispatchCardItems => 'Items';

  @override
  String get dispatchCardPrintInvoice => 'Print Invoice';

  @override
  String get dispatchCardCopyInvoice => 'Copy Invoice Text';

  @override
  String get dispatchCardInvoiceCopied => 'Invoice copied to clipboard';

  @override
  String get dispatchCardAssignDriver => 'Assign Driver';

  @override
  String get dispatchCardChangeDriver => 'Change Driver';

  @override
  String get dispatchCardUnassignDriver => 'Unassign Driver';

  @override
  String get dispatchCardNoDrivers => 'No delivery staff found.';

  @override
  String get dispatchCardDeposit => 'Deposit amount';

  @override
  String get dispatchCardDepositLabel => 'Deposit';

  @override
  String get dispatchCardDepositEdit => 'Edit';

  @override
  String get dispatchCardSetDeposit => 'Set Deposit';

  @override
  String get dispatchCardSave => 'Save';

  @override
  String get dispatchCardCancel => 'Cancel';

  @override
  String get dailyReportTitle => 'Daily Report';

  @override
  String get dailyReportSingleDay => 'Single Day';

  @override
  String get dailyReportDateRange => 'Date Range';

  @override
  String get dailyReportToday => 'Today';

  @override
  String get dailyReportChange => 'Change';

  @override
  String get dailyReportNoAssigned => 'No assigned orders';

  @override
  String dailyReportUnassigned(int count) {
    return 'Unassigned Orders ($count)';
  }

  @override
  String get dailyReportAdd => 'Add';

  @override
  String get dailyReportAddExpense => 'Add Expense';

  @override
  String get dailyReportEditExpense => 'Edit Expense';

  @override
  String get dailyReportCancel => 'Cancel';

  @override
  String get dailyReportSave => 'Save';

  @override
  String get dailyReportDeleteExpense => 'Delete Expense';

  @override
  String get driverReportTitle => 'Driver Report';

  @override
  String get driverReportFilterRange => 'Range';

  @override
  String get driverReportFilterAll => 'All';

  @override
  String get driverReportFilterByDate => 'By Date';

  @override
  String get driverReportAllDates => 'All Dates';

  @override
  String get driverReportClear => 'Clear';

  @override
  String get driverReportDrivers => 'Drivers';

  @override
  String get driverReportNoDrivers => 'No drivers';

  @override
  String get driverReportCollected => 'Collected';

  @override
  String get driverReportCustomShipping => 'Custom shipping fee';

  @override
  String get driverReportTotalOrders => 'Total Orders';

  @override
  String get driverReportCashOrders => 'Cash Orders';

  @override
  String get driverReportInstapay => 'Instapay';

  @override
  String get reportsTabSummary => 'Summary';

  @override
  String get reportsTabDrivers => 'Drivers';

  @override
  String get reportsTabExpenses => 'Expenses';

  @override
  String get reportsRetry => 'Retry';

  @override
  String get reportsNoDrivers => 'No drivers found';

  @override
  String get reportsSelectDriver => 'Select a driver';

  @override
  String get reportsToday => 'Today';

  @override
  String get reportsAdd => 'Add';

  @override
  String get reportsNoExpenses => 'No expenses in this period';

  @override
  String get reportsChangeRange => 'Change range';

  @override
  String get reportsTotal => 'Total';

  @override
  String get reportsTypes => 'Types';

  @override
  String get reportsDays => 'Days';

  @override
  String get reportsSetDeposit => 'Set deposit';

  @override
  String get reportsAmount => 'Amount';

  @override
  String get reportsSave => 'Save';

  @override
  String get reportsCancel => 'Cancel';

  @override
  String get reportsDeleteExpense => 'Delete Expense';

  @override
  String get reportsModeSingleDay => 'Single Day';

  @override
  String get reportsModeDateRange => 'Date Range';

  @override
  String get reportsIncomeTitle => 'Income';

  @override
  String get reportsTotalSales => 'Total Sales';

  @override
  String get reportsDeliveryFees => 'Delivery Fees';

  @override
  String get reportsDeliveryCost => 'Actual Delivery Cost';

  @override
  String get reportsNetSales => 'Net Sales';

  @override
  String get reportsTotalCogs => 'Total COGS';

  @override
  String get reportsGrossProfit => 'Gross Profit';

  @override
  String get reportsLoss => 'Loss';

  @override
  String get reportsCashFlowTitle => 'Cash Flow';

  @override
  String get reportsCashSales => 'Cash Sales';

  @override
  String get reportsInstapay => 'Instapay';

  @override
  String get reportsDepositsPaid => 'Deposits Paid';

  @override
  String get reportsDriversOwe => 'Drivers Owe';

  @override
  String get reportsTotalExpenses => 'Total Expenses';

  @override
  String get reportsNetCash => 'Net Cash';

  @override
  String get reportsDeficit => 'Deficit';

  @override
  String get reportsDriverAccountsTitle => 'Driver Accounts';

  @override
  String get reportsNoAssignedOrders => 'No assigned orders';

  @override
  String get reportsZoneAccountsTitle => 'Zone Accounts';

  @override
  String get reportsNoZoneData => 'No zone data';

  @override
  String get reportsAllOrdersTitle => 'All Orders';

  @override
  String get reportsNoOrders => 'No orders';

  @override
  String get reportsCustomerFee => 'Customer Fee';

  @override
  String get reportsZoneLabel => 'Zone';

  @override
  String get reportsOrdersLabel => 'Orders';

  @override
  String get reportsCustFeeLabel => 'Cust. Fee';

  @override
  String get reportsActualCostLabel => 'Actual Cost';

  @override
  String get reportsEditLabel => 'Edit';

  @override
  String get reportsSetCost => 'Set cost';

  @override
  String get reportsTotalOrders => 'Total Orders';

  @override
  String get reportsCashLabel => 'Cash';

  @override
  String get reportsInstapayLabel => 'Instapay';

  @override
  String get reportsDepositsLabel => 'Deposits';

  @override
  String get reportsDriverOwesLabel => 'Driver Owes';

  @override
  String get reportsOwed => 'Owed';

  @override
  String get reportsOrdersTitle => 'Orders';

  @override
  String get reportsDue => 'Due';

  @override
  String get reportsAddExpense => 'Add Expense';

  @override
  String get reportsEditExpense => 'Edit Expense';

  @override
  String get reportsTypeLabel => 'Type';

  @override
  String get reportsTotalHeader => 'Total';

  @override
  String get reportsDeleteConfirm => 'Delete expense';

  @override
  String get reportsDelete => 'Delete';

  @override
  String get reportsShippingLabel => 'Shipping';

  @override
  String get bannersTitle => 'Banners';

  @override
  String get bannersRetry => 'Retry';

  @override
  String get bannersFailedLoad => 'Failed to load';

  @override
  String get bannersEmpty => 'No banners yet';

  @override
  String get bannersEmptyHint => 'Tap + to add the first banner';

  @override
  String get bannersDeleteTitle => 'Delete Banner';

  @override
  String get bannersCancel => 'Cancel';

  @override
  String get bannersDelete => 'Delete';

  @override
  String get bannersMutationFailed => 'Operation failed';

  @override
  String get bannerFormEditTitle => 'Edit Banner';

  @override
  String get bannerFormNewTitle => 'New Banner';

  @override
  String get bannerFormImageUrl => 'Image URL';

  @override
  String get bannerFormImageRequired => 'Image URL is required';

  @override
  String get bannerFormTitleField => 'Title (optional)';

  @override
  String get bannerFormSortOrder => 'Sort Order';

  @override
  String get bannerFormActive => 'Active';

  @override
  String get bannerFormOnTapAction => 'On Tap Action';

  @override
  String get bannerFormUrlToOpen => 'URL to Open';

  @override
  String get bannerFormUrlRequired => 'URL is required';

  @override
  String get bannerFormSelectProduct => 'Select Product';

  @override
  String get bannerFormSelectCategory => 'Select Category';

  @override
  String get bannerFormTapProduct => 'Tap to choose a product';

  @override
  String get bannerFormTapCategory => 'Tap to choose a category';

  @override
  String get bannerFormStartDate => 'Start Date (optional)';

  @override
  String get bannerFormEndDate => 'End Date (optional)';

  @override
  String get bannerFormSaveChanges => 'Save Changes';

  @override
  String get bannerFormCreate => 'Create Banner';

  @override
  String get bannerFormInvalidImage => 'Invalid image URL';

  @override
  String get popupAdsTitle => 'Popup Ads';

  @override
  String get popupAdsEmpty => 'No popup ads yet';

  @override
  String get popupAdsCreate => 'Create Popup Ad';

  @override
  String popupAdsEnds(String date) {
    return 'Ends $date';
  }

  @override
  String get popupAdsEdit => 'Edit';

  @override
  String get popupAdsDelete => 'Delete';

  @override
  String get popupAdsDeleteTitle => 'Delete Popup Ad?';

  @override
  String get popupAdsCancel => 'Cancel';

  @override
  String get popupAdFormEditTitle => 'Edit Popup Ad';

  @override
  String get popupAdFormNewTitle => 'New Popup Ad';

  @override
  String get popupAdFormSave => 'Save';

  @override
  String get popupAdFormBasicInfo => 'Basic Info';

  @override
  String get popupAdFormImage => 'Image';

  @override
  String get popupAdFormButton => 'Button (optional)';

  @override
  String get popupAdFormSchedule => 'Schedule (optional)';

  @override
  String get popupAdFormTitleField => 'Title *';

  @override
  String get popupAdFormTitleRequired => 'Title required';

  @override
  String get popupAdFormBody => 'Body text (optional)';

  @override
  String get popupAdFormImageUrl => 'Image URL';

  @override
  String get popupAdFormUpload => 'Upload';

  @override
  String get popupAdFormButtonLabel => 'Button label';

  @override
  String get popupAdFormButtonUrl => 'Button URL';

  @override
  String get popupAdFormStartDate => 'Start date';

  @override
  String get popupAdFormEndDate => 'End date';

  @override
  String get popupAdFormActive => 'Active';

  @override
  String popupAdFormUploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get popupAdFormFrequency => 'Show frequency';

  @override
  String get popupAdFreqEverySession => 'Every session';

  @override
  String get popupAdFreqOncePerDay => 'Once per day';

  @override
  String get popupAdFreqOnceEver => 'Once ever';

  @override
  String get popupAdFormCountdown => 'Countdown Timer (optional)';

  @override
  String get popupAdFormCountdownAt => 'Countdown ends at';

  @override
  String get promoCodesTitle => 'Promo Codes';

  @override
  String get promoCodesRetry => 'Retry';

  @override
  String get promoCodesFailedLoad => 'Failed to load';

  @override
  String get promoCodesEmpty => 'No promo codes';

  @override
  String get promoCodesEmptyHint => 'Tap + to create one';

  @override
  String get promoCodesFilterAll => 'All';

  @override
  String get promoCodesFilterActive => 'Active';

  @override
  String get promoCodesFilterExpired => 'Expired';

  @override
  String get promoCodesFilterInactive => 'Inactive';

  @override
  String get promoCodesDeleteTitle => 'Delete Promo Code';

  @override
  String get promoCodesCancel => 'Cancel';

  @override
  String get promoCodesDelete => 'Delete';

  @override
  String get promoCodes_mutationFailed => 'Operation failed';

  @override
  String promoCodesCopied(String code) {
    return 'Copied $code';
  }

  @override
  String get promoCodeFormEditTitle => 'Edit Promo Code';

  @override
  String get promoCodeFormNewTitle => 'New Promo Code';

  @override
  String get promoCodeFormCodeField => 'Promo Code';

  @override
  String get promoCodeFormCodeRequired => 'Code is required';

  @override
  String get promoCodeFormDiscountType => 'Discount Type';

  @override
  String get promoCodeFormDiscountPct => 'Discount Percentage';

  @override
  String get promoCodeFormDiscountAmount => 'Discount Amount (EGP)';

  @override
  String get promoCodeFormInvalidValue => 'Enter a valid value';

  @override
  String get promoCodeFormPctMax => 'Percentage cannot exceed 100%';

  @override
  String get promoCodeFormDescription => 'Description (optional)';

  @override
  String get promoCodeFormMinOrder => 'Minimum Order Value (EGP)';

  @override
  String get promoCodeFormMaxUses => 'Max Total Uses';

  @override
  String get promoCodeFormPerUser => 'Per User Limit';

  @override
  String get promoCodeFormMin1 => 'Min 1';

  @override
  String get promoCodeFormStartDate => 'Start Date (optional)';

  @override
  String get promoCodeFormExpiryDate => 'Expiry Date (optional)';

  @override
  String get promoCodeFormActive => 'Active';

  @override
  String get promoCodeFormSaveChanges => 'Save Changes';

  @override
  String get promoCodeFormCreate => 'Create Promo Code';

  @override
  String get promoCodeFormGenerate => 'Generate random code';

  @override
  String get loyaltyTitle => 'Loyalty Management';

  @override
  String get loyaltyTabRules => 'Rules';

  @override
  String get loyaltyTabSpend => 'Spend Milestones';

  @override
  String get loyaltyTabPoints => 'Points Rewards';

  @override
  String get loyaltyTabTransactions => 'Transactions';

  @override
  String get loyaltyFilterCustomer => 'Filter by customer ID…';

  @override
  String get loyaltyNoTransactions => 'No transactions';

  @override
  String get loyaltyTransactionsHint => 'Loyalty transactions will appear here';

  @override
  String get loyaltyTypeCashback => 'Cashback Event';

  @override
  String get loyaltyTypeBaseEarn => 'Base Earn';

  @override
  String get loyaltyTypeFreeProduct => 'Free Product';

  @override
  String get loyaltyTypeFreeDelivery => 'Free Delivery';

  @override
  String get loyaltyGoalFormEditTitle => 'Edit Points Reward';

  @override
  String get loyaltyGoalFormNewTitle => 'New Points Reward';

  @override
  String get loyaltyGoalFormSave => 'Save';

  @override
  String get loyaltyGoalFormIcon => 'Icon (emoji)';

  @override
  String get loyaltyGoalFormTitle => 'Title';

  @override
  String get loyaltyGoalFormTitleRequired => 'Title is required';

  @override
  String get loyaltyGoalFormPointsRequired => 'Points Required';

  @override
  String get loyaltyGoalFormPointsInvalid => 'Enter points greater than 0';

  @override
  String get loyaltyGoalFormRewardType => 'Reward Type';

  @override
  String get loyaltyGoalFormFreeDelivery => 'Free Delivery';

  @override
  String get loyaltyGoalFormFreeProduct => 'Free Product';

  @override
  String get loyaltyGoalFormSelectProduct => 'Select Free Product';

  @override
  String get loyaltyGoalFormTapProduct => 'Tap to choose a product';

  @override
  String get loyaltyGoalFormDescription => 'Description — optional';

  @override
  String get loyaltyGoalFormSortOrder => 'Sort Order';

  @override
  String get loyaltyGoalFormSortInvalid => 'Enter 0 or more';

  @override
  String get loyaltyGoalFormActive => 'Active';

  @override
  String get loyaltyGoalFormDelete => 'Delete Reward';

  @override
  String get loyaltyGoalFormDeleteTitle => 'Delete Reward?';

  @override
  String get loyaltyGoalFormCancel => 'Cancel';

  @override
  String get loyaltyGoalFormDeleteConfirm => 'Delete';

  @override
  String get loyaltyRuleFormEditTitle => 'Edit Rule';

  @override
  String get loyaltyRuleFormNewTitle => 'New Rule';

  @override
  String get loyaltyRuleFormSave => 'Save';

  @override
  String get loyaltyRuleFormName => 'Rule Name';

  @override
  String get loyaltyRuleFormNameRequired => 'Name is required';

  @override
  String get loyaltyRuleFormType => 'Rule Type';

  @override
  String get loyaltyRuleFormBaseEarn => 'Base Earn';

  @override
  String get loyaltyRuleFormCashback => 'Cashback Event';

  @override
  String get loyaltyRuleFormPointsPerEgp => 'Points per EGP Spent';

  @override
  String get loyaltyRuleFormPointsInvalid => 'Enter a value greater than 0';

  @override
  String get loyaltyRuleFormMinOrder => 'Minimum Order Value (EGP) — optional';

  @override
  String get loyaltyRuleFormValidFrom => 'Valid From — optional';

  @override
  String get loyaltyRuleFormValidUntil => 'Valid Until — optional';

  @override
  String get loyaltyRuleFormDailyStart => 'Daily Start Time — optional';

  @override
  String get loyaltyRuleFormDailyEnd => 'Daily End Time — optional';

  @override
  String get loyaltyRuleFormSelectDate => 'Select date';

  @override
  String get loyaltyRuleFormSelectTime => 'Select time';

  @override
  String get loyaltyRuleFormActive => 'Active';

  @override
  String get loyaltyRuleFormDelete => 'Delete Rule';

  @override
  String get loyaltyRuleFormDeleteTitle => 'Delete Rule?';

  @override
  String get loyaltyRuleFormCancel => 'Cancel';

  @override
  String get loyaltyRuleFormDeleteConfirm => 'Delete';

  @override
  String get spendGoalFormEditTitle => 'Edit Spend Milestone';

  @override
  String get spendGoalFormNewTitle => 'New Spend Milestone';

  @override
  String get spendGoalFormSave => 'Save';

  @override
  String get spendGoalFormIcon => 'Icon (emoji)';

  @override
  String get spendGoalFormTitle => 'Title';

  @override
  String get spendGoalFormTitleRequired => 'Title is required';

  @override
  String get spendGoalFormSpendRequired => 'Spend Required (EGP)';

  @override
  String get spendGoalFormSpendInvalid => 'Enter a spend amount greater than 0';

  @override
  String get spendGoalFormRewardType => 'Reward Type';

  @override
  String get spendGoalFormFreeDelivery => 'Free Delivery';

  @override
  String get spendGoalFormFreeProduct => 'Free Product';

  @override
  String get spendGoalFormDiscount => 'Discount (%)';

  @override
  String get spendGoalFormDiscountInvalid =>
      'Enter a discount between 1 and 100';

  @override
  String get spendGoalFormDescription => 'Description — optional';

  @override
  String get spendGoalFormSortOrder => 'Sort Order';

  @override
  String get spendGoalFormActive => 'Active';

  @override
  String get spendGoalFormDelete => 'Delete Milestone';

  @override
  String get spendGoalFormDeleteTitle => 'Delete Milestone?';

  @override
  String get spendGoalFormCancel => 'Cancel';

  @override
  String get spendGoalFormDeleteConfirm => 'Delete';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsServiceFee => 'Service Fee';

  @override
  String get settingsShowInCheckout => 'Show in checkout';

  @override
  String get settingsShowInCheckoutSubtitle =>
      'Appears as a line item on the order summary';

  @override
  String get settingsFeeAmount => 'Fee Amount (EGP)';

  @override
  String get settingsMaxPoints => 'Max Points Per Order (0 = unlimited)';

  @override
  String get settingsOnlineWindow => 'Online User Window (minutes)';

  @override
  String get settingsOnlineWindowDesc =>
      'A user is counted as \"online\" if active within this window';

  @override
  String get settingsReferralBonusReferrer => 'Referral Bonus — Referrer (pts)';

  @override
  String get settingsReferralRewardNew => 'Referral Reward — New User (pts)';

  @override
  String get settingsSaveChanges => 'Save Changes';

  @override
  String get settingsSaveFailed => 'Failed to save';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'Arabic';

  @override
  String get csvTitle => 'Import / Export';

  @override
  String get csvTabProducts => 'Products';

  @override
  String get csvTabCustomers => 'Customers';

  @override
  String get csvTabOrders => 'Orders';

  @override
  String get csvExportProducts => 'Export Products';

  @override
  String get csvImportProducts => 'Import Products';

  @override
  String get csvExportCustomers => 'Export Customers';

  @override
  String get csvImportCustomers => 'Import Customers';

  @override
  String get csvExportOrders => 'Export Orders';

  @override
  String get csvExportCsv => 'Export CSV';

  @override
  String get csvPickFile => 'Pick CSV File';

  @override
  String get csvProcessing => 'Processing…';

  @override
  String get csvOrderImportWarning => 'Order import is not supported';

  @override
  String get csvProductImportPreview => 'Product Import Preview';

  @override
  String get csvCustomerImportPreview => 'Customer Import Preview';

  @override
  String csvRows(int count) {
    return '$count rows';
  }

  @override
  String csvAndMore(int count) {
    return '… and $count more';
  }

  @override
  String get csvCancel => 'Cancel';

  @override
  String csvImportRows(int count) {
    return 'Import $count rows';
  }

  @override
  String get csvExpectedColumns => 'Expected CSV columns';

  @override
  String get stubComingSoon => 'Coming soon';
}
