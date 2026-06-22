// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get authAppTitle => 'لوحة تحكم صبح';

  @override
  String get authSubtitle => 'بوابة الموظفين — سجّل دخولك للمتابعة';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authPhoneError => 'أدخل رقم هاتف صحيح';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordError => 'أدخل كلمة المرور';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navDelivery => 'التوصيل';

  @override
  String get navDispatch => 'الإرسال';

  @override
  String get navAnalytics => 'التحليلات';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navBranches => 'الفروع';

  @override
  String get navZones => 'المناطق';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navLoyalty => 'الولاء';

  @override
  String get navCustomers => 'العملاء';

  @override
  String get navStaff => 'الموظفون';

  @override
  String get navPromos => 'العروض';

  @override
  String get navBanners => 'البانرات';

  @override
  String get navAds => 'الإعلانات';

  @override
  String get navCsv => 'ملفات CSV';

  @override
  String get navMyRoutes => 'مساراتي';

  @override
  String get navSignOut => 'تسجيل الخروج';

  @override
  String get navStaffFallback => 'موظف';

  @override
  String get homeGlance => 'نظرة سريعة على اليوم';

  @override
  String get homeTotalOrders => 'إجمالي الطلبات';

  @override
  String get homePending => 'قيد الانتظار';

  @override
  String get homeInProgress => 'قيد التنفيذ';

  @override
  String get homeDelivered => 'تم التسليم';

  @override
  String get homeActiveOrders => 'الطلبات النشطة';

  @override
  String get homeAllCaughtUp => 'كل شيء على ما يرام!';

  @override
  String get homeNoActiveOrders => 'لا توجد طلبات نشطة الآن';

  @override
  String get homeGoodMorning => 'صباح الخير ☀️';

  @override
  String get homeGoodAfternoon => 'مساء الخير 🌤';

  @override
  String get homeGoodEvening => 'مساء النور 🌙';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get analyticsRefresh => 'تحديث';

  @override
  String get analyticsFilters => 'التصفية';

  @override
  String get analyticsToday => 'اليوم';

  @override
  String get analytics7Days => '7 أيام';

  @override
  String get analytics30Days => '30 يوم';

  @override
  String get analyticsThisMonth => 'هذا الشهر';

  @override
  String get analyticsCustom => 'مخصص';

  @override
  String get analyticsAllBranches => 'كل الفروع';

  @override
  String get analyticsOnlineNow => 'متصل الآن';

  @override
  String get analyticsLive => 'مباشر';

  @override
  String analyticsActiveInLast(int minutes) {
    return 'نشط خلال آخر $minutes دقيقة';
  }

  @override
  String get analyticsTotalSales => 'إجمالي المبيعات';

  @override
  String get analyticsOrders => 'الطلبات';

  @override
  String get analyticsTotalCogs => 'إجمالي التكلفة';

  @override
  String get analyticsGrossProfit => 'الربح الإجمالي';

  @override
  String get analyticsAvgOrderValue => 'متوسط قيمة الطلب';

  @override
  String get analyticsDiscountsFreeItems => 'الخصومات والعناصر المجانية';

  @override
  String get analyticsDeliveryCharges => 'رسوم التوصيل';

  @override
  String get analyticsTotalDiscounts => 'إجمالي الخصومات';

  @override
  String get analyticsLoyaltyDiscounts => 'خصومات الولاء';

  @override
  String get analyticsPromoDiscounts => 'خصومات العروض';

  @override
  String get analyticsFreeDeliveryValue => 'قيمة التوصيل المجاني';

  @override
  String get analyticsFreeDelivery => 'توصيل مجاني';

  @override
  String get analyticsFreeItems => 'عناصر مجانية';

  @override
  String get analyticsFulfillment => 'معدل التنفيذ';

  @override
  String get analyticsCancellation => 'الإلغاء';

  @override
  String get analyticsReturning => 'عملاء عائدون';

  @override
  String get analyticsCustomerMetrics => 'مقاييس العملاء';

  @override
  String get analyticsUniqueCustomers => 'عملاء جدد';

  @override
  String get analyticsDailySales => 'مبيعات يومية';

  @override
  String get analyticsSalesByZone => 'المبيعات حسب منطقة التوصيل';

  @override
  String get analyticsOrdersByStatus => 'الطلبات حسب الحالة';

  @override
  String get analyticsByRevenue => 'حسب الإيراد';

  @override
  String get analyticsByQuantity => 'حسب الكمية';

  @override
  String get analyticsByViews => 'حسب المشاهدات';

  @override
  String get analyticsByAddToCart => 'حسب الإضافة للسلة';

  @override
  String get analyticsShowLess => 'عرض أقل';

  @override
  String get analyticsNoData => 'لا توجد بيانات';

  @override
  String get analyticsDeviceType => 'الجلسات حسب نوع الجهاز';

  @override
  String get analyticsAbandonedCarts => 'سلات التسوق المهجورة';

  @override
  String get analyticsCartItems => 'عناصر السلة';

  @override
  String get analyticsProduct => 'المنتج';

  @override
  String get analyticsViews => 'المشاهدات';

  @override
  String get analyticsCarts => 'السلات';

  @override
  String get analyticsEventTracking => 'تتبع الأحداث';

  @override
  String get analyticsFailedLoad => 'فشل تحميل التحليلات';

  @override
  String get analyticsRetry => 'إعادة المحاولة';

  @override
  String get analyticsGuest => 'زائر';

  @override
  String get ordersTitle => 'الطلبات';

  @override
  String get ordersNewOrder => 'طلب جديد';

  @override
  String get ordersTabAll => 'الكل';

  @override
  String get ordersTabPending => 'قيد الانتظار';

  @override
  String get ordersTabConfirmed => 'مؤكد';

  @override
  String get ordersTabPreparing => 'قيد التحضير';

  @override
  String get ordersTabDelivery => 'توصيل';

  @override
  String get ordersTabDone => 'منتهي';

  @override
  String get ordersTabCancelled => 'ملغى';

  @override
  String get ordersFailedLoad => 'فشل تحميل الطلبات';

  @override
  String get ordersRetry => 'إعادة المحاولة';

  @override
  String get ordersEmpty => 'لا توجد طلبات هنا';

  @override
  String get orderDetailsOrderInfo => 'معلومات الطلب';

  @override
  String get orderDetailsCreated => 'تاريخ الإنشاء';

  @override
  String get orderDetailsPayment => 'الدفع';

  @override
  String get orderDetailsStatus => 'الحالة';

  @override
  String get orderDetailsAddress => 'العنوان';

  @override
  String get orderDetailsNotes => 'ملاحظات';

  @override
  String get orderDetailsPromoCode => 'كود الخصم';

  @override
  String get orderDetailsDriver => 'السائق';

  @override
  String get orderDetailsSummary => 'الملخص';

  @override
  String get orderDetailsDeliveryFee => 'رسوم التوصيل';

  @override
  String get orderDetailsServiceFee => 'رسوم الخدمة';

  @override
  String get orderDetailsDelivery => 'التوصيل';

  @override
  String get orderDetailsTotal => 'الإجمالي';

  @override
  String get orderDetailsDeposit => 'Deposit (عربون)';

  @override
  String get orderDetailsAmountDue => 'المبلغ المستحق';

  @override
  String get orderDetailsRewardsApplied => 'المكافآت المطبقة';

  @override
  String get orderDetailsSpendMilestone => 'مرحلة الإنفاق';

  @override
  String get orderDetailsPointsRedeemed => 'نقاط مستردة';

  @override
  String get orderDetailsPointsEarned => 'نقاط مكتسبة';

  @override
  String get orderDetailsFree => 'مجاني';

  @override
  String get orderDetailsPrintInvoice => 'طباعة الفاتورة';

  @override
  String get orderDetailsCancelOrder => 'إلغاء الطلب';

  @override
  String get orderDetailsCancelConfirm => 'هل أنت متأكد من إلغاء هذا الطلب؟';

  @override
  String get orderDetailsNo => 'لا';

  @override
  String get orderDetailsConfirmOrder => 'تأكيد الطلب';

  @override
  String get orderDetailsStartPreparing => 'بدء التحضير';

  @override
  String get orderDetailsSendForDelivery => 'إرسال للتوصيل';

  @override
  String get orderDetailsMarkDelivered => 'تحديد كمُسلَّم';

  @override
  String get createOrderTitle => 'طلب جديد';

  @override
  String get createOrderStepCustomer => 'العميل';

  @override
  String get createOrderStepProducts => 'المنتجات';

  @override
  String get createOrderStepDetails => 'التفاصيل';

  @override
  String get createOrderStepConfirm => 'تأكيد';

  @override
  String get createOrderBack => 'رجوع';

  @override
  String get createOrderNext => 'التالي';

  @override
  String get createOrderPlace => 'تقديم الطلب';

  @override
  String get createOrderSuccess => 'تم تقديم الطلب بنجاح!';

  @override
  String get createOrderFailed => 'فشل تقديم الطلب';

  @override
  String get createOrderSearchCustomer => 'البحث عن عميل موجود';

  @override
  String get createOrderSearchHint => 'الاسم أو رقم الهاتف أو البريد…';

  @override
  String get createOrderNewCustomer => 'أو إنشاء عميل جديد';

  @override
  String get createOrderFullName => 'الاسم الكامل';

  @override
  String get createOrderFullNameHint => 'اسم العميل الكامل';

  @override
  String get createOrderPhone => 'الهاتف (اختياري)';

  @override
  String get createOrderUseAsCustomer => 'استخدم كعميل';

  @override
  String get createOrderAddCustomItem => 'إضافة عنصر مخصص';

  @override
  String get createOrderItemName => 'اسم العنصر *';

  @override
  String get createOrderItemPrice => 'السعر (جنيه) *';

  @override
  String get createOrderAddToOrder => 'إضافة للطلب';

  @override
  String get createOrderSearchProducts => 'البحث في المنتجات…';

  @override
  String get createOrderSelectedItems => 'العناصر المحددة';

  @override
  String get createOrderCustomItem => 'عنصر مخصص';

  @override
  String get createOrderAllProducts => 'كل المنتجات';

  @override
  String get createOrderBranch => 'الفرع *';

  @override
  String get createOrderSelectBranch => 'اختر الفرع';

  @override
  String get createOrderDeliveryAddress => 'عنوان التوصيل';

  @override
  String get createOrderNewAddress => 'عنوان جديد';

  @override
  String get createOrderSaveAddress => 'حفظ واستخدام العنوان';

  @override
  String get createOrderDeliveryZone => 'منطقة التوصيل';

  @override
  String get createOrderSelectZone => 'اختر منطقة التوصيل';

  @override
  String get createOrderNoZone => 'بدون منطقة توصيل';

  @override
  String get createOrderAddressLabel => 'التسمية';

  @override
  String get createOrderAddressLabelHint => 'مثال: المنزل، العمل';

  @override
  String get createOrderStreet => 'الشارع *';

  @override
  String get createOrderStreetHint => 'اسم الشارع / المنطقة';

  @override
  String get createOrderBuilding => 'المبنى';

  @override
  String get createOrderBuildingHint => 'رقم';

  @override
  String get createOrderFloor => 'الطابق';

  @override
  String get createOrderFloorHint => 'رقم';

  @override
  String get createOrderApt => 'الشقة';

  @override
  String get createOrderAptHint => 'رقم';

  @override
  String get createOrderLandmark => 'علامة مميزة';

  @override
  String get createOrderLandmarkHint => 'بالقرب من…';

  @override
  String get createOrderDiscount => 'خصم (جنيه)';

  @override
  String get createOrderOrderNotes => 'ملاحظات الطلب';

  @override
  String get createOrderNotesHint => 'أي تعليمات خاصة…';

  @override
  String get createOrderPaymentMethod => 'طريقة الدفع';

  @override
  String get createOrderCash => 'نقدي';

  @override
  String get createOrderInstapay => 'انستاباي';

  @override
  String createOrderCartSummary(int count) {
    return 'السلة: $count عنصر';
  }

  @override
  String createOrderSubtotal(String amount) {
    return 'المجموع: $amount جنيه';
  }

  @override
  String get createOrderSummaryTitle => 'ملخص الطلب';

  @override
  String get createOrderSummaryCustomer => 'العميل';

  @override
  String get createOrderSummaryDeliveryInfo => 'معلومات التوصيل';

  @override
  String createOrderSummaryItems(int count) {
    return 'العناصر ($count)';
  }

  @override
  String get createOrderSummaryPayment => 'الدفع';

  @override
  String get createOrderSummaryNotes => 'ملاحظات';

  @override
  String get createOrderSummaryBranch => 'الفرع';

  @override
  String get createOrderSummaryZone => 'المنطقة';

  @override
  String get createOrderSummaryAddress => 'العنوان';

  @override
  String get createOrderSummaryMethod => 'الطريقة';

  @override
  String get createOrderSummarySubtotal => 'المجموع الفرعي';

  @override
  String get createOrderSummaryDelivery => 'التوصيل';

  @override
  String get createOrderSummaryDiscount => 'الخصم';

  @override
  String get createOrderSummaryTotal => 'الإجمالي';

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get productsAddProduct => 'إضافة منتج';

  @override
  String get productsSearchHint => 'البحث في المنتجات...';

  @override
  String get productFormEditTitle => 'تعديل المنتج';

  @override
  String get productFormNewTitle => 'منتج جديد';

  @override
  String get productFormSave => 'حفظ';

  @override
  String get productFormActive => 'نشط';

  @override
  String get productFormActiveSubtitle => 'مرئي للعملاء';

  @override
  String get productFormBestSeller => 'الأكثر مبيعاً 🔥';

  @override
  String get productFormBestSellerSubtitle =>
      'عرض في قسم الأكثر مبيعاً في الشاشة الرئيسية';

  @override
  String get productFormAddOption => 'إضافة خيار';

  @override
  String get productFormStock => 'المخزون:';

  @override
  String get productFormPricePreview => 'معاينة السعر';

  @override
  String get productFormRelatedProducts => 'المنتجات ذات الصلة';

  @override
  String get productFormAdd => 'إضافة';

  @override
  String get productFormNoRelated => 'لا توجد منتجات ذات صلة بعد.';

  @override
  String get productFormSelectRelated => 'اختر منتجاً ذا صلة';

  @override
  String get productFormNoBranches => 'لا توجد فروع.';

  @override
  String get productFormNone => 'بلا';

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String get categoriesAddCategory => 'إضافة فئة';

  @override
  String get categoriesSearchHint => 'البحث في الفئات...';

  @override
  String get categoriesDragReorder => 'اسحب لإعادة الترتيب';

  @override
  String get categoriesEmpty => 'لا توجد فئات بعد';

  @override
  String get categoriesEmptyHint => 'اضغط + لإضافة أول فئة';

  @override
  String get categoriesDeleteTitle => 'حذف الفئة';

  @override
  String categoriesDeleteConfirm(String name) {
    return 'إزالة \"$name\"؟ سيتم تعطيلها.';
  }

  @override
  String get categoriesCancel => 'إلغاء';

  @override
  String get categoriesDelete => 'حذف';

  @override
  String get categoriesInactive => 'غير نشط';

  @override
  String get categoryFormEditTitle => 'تعديل الفئة';

  @override
  String get categoryFormNewTitle => 'فئة جديدة';

  @override
  String get categoryFormSave => 'حفظ';

  @override
  String get categoryFormBranches => 'الفروع';

  @override
  String get categoryFormName => 'الاسم';

  @override
  String get categoryFormMedia => 'الوسائط';

  @override
  String get categoryFormVisibility => 'الظهور';

  @override
  String get categoryFormNameEn => 'اسم الفئة (إنجليزي)';

  @override
  String get categoryFormNameAr => 'اسم الفئة (عربي)';

  @override
  String get categoryFormCoverUrl => 'رابط صورة الغلاف';

  @override
  String get categoryFormActive => 'نشط';

  @override
  String get categoryFormActiveSubtitle => 'مرئي للعملاء';

  @override
  String get categoryFormAllBranches => 'كل الفروع';

  @override
  String get categoryFormSelectBranch => 'اختر فرعاً واحداً على الأقل.';

  @override
  String get categoryFormNoBranches => 'لا توجد فروع.';

  @override
  String get categoryFormRequired => 'مطلوب';

  @override
  String get customersTitle => 'العملاء';

  @override
  String get customersSearchHint => 'البحث بالاسم أو البريد أو الهاتف…';

  @override
  String get customersEmpty => 'لا يوجد عملاء بعد';

  @override
  String customersNoResults(String query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String get customersFailedLoad => 'فشل تحميل العملاء';

  @override
  String get customersRetry => 'إعادة المحاولة';

  @override
  String get customersColCustomer => 'العميل';

  @override
  String get customersColEmail => 'البريد الإلكتروني';

  @override
  String get customersColPhone => 'الهاتف';

  @override
  String get customersColOrders => 'الطلبات';

  @override
  String get customersColLoyalty => 'الولاء';

  @override
  String get customersColTotalSpent => 'إجمالي الإنفاق';

  @override
  String get customerDetailCreateOrder => 'إنشاء طلب';

  @override
  String get customerDetailLoyaltyPoints => 'نقاط الولاء';

  @override
  String get customerDetailPoints => 'نقاط';

  @override
  String get customerDetailAdjust => 'تعديل';

  @override
  String get customerDetailAdjustTitle => 'تعديل نقاط الولاء';

  @override
  String get customerDetailAddPoints => '+ إضافة نقاط';

  @override
  String get customerDetailDeductPoints => '- خصم نقاط';

  @override
  String get customerDetailAmount => 'المبلغ';

  @override
  String get customerDetailReason => 'السبب / الوصف';

  @override
  String get customerDetailConfirm => 'تأكيد';

  @override
  String get customerDetailInternalNotes => 'ملاحظات داخلية';

  @override
  String get customerDetailNotesHint => 'إضافة ملاحظات داخلية عن هذا العميل…';

  @override
  String get customerDetailSaveNotes => 'حفظ الملاحظات';

  @override
  String get customerDetailNoNotes => 'لا توجد ملاحظات بعد';

  @override
  String get customerDetailBlocked => 'محظور';

  @override
  String customerDetailJoined(String date) {
    return 'انضم $date';
  }

  @override
  String customerDetailRef(String code) {
    return 'مرجع: $code';
  }

  @override
  String get customerDetailPastOrders => 'الطلبات السابقة';

  @override
  String get customerDetailNoOrders => 'لا توجد طلبات بعد';

  @override
  String get branchesTitle => 'الفروع';

  @override
  String get branchesAddTooltip => 'إضافة فرع';

  @override
  String get branchesEmpty => 'لا توجد فروع بعد';

  @override
  String get branchesEmptyHint => 'اضغط + لإضافة أول فرع';

  @override
  String get branchesFailedLoad => 'فشل تحميل الفروع';

  @override
  String get branchesRetry => 'إعادة المحاولة';

  @override
  String get branchesMutationFailed => 'فشلت العملية';

  @override
  String get branchFormEditTitle => 'تعديل الفرع';

  @override
  String get branchFormNewTitle => 'فرع جديد';

  @override
  String get branchFormSave => 'حفظ';

  @override
  String get branchFormBranchName => 'اسم الفرع';

  @override
  String get branchFormLatitude => 'خط العرض';

  @override
  String get branchFormLongitude => 'خط الطول';

  @override
  String get branchFormRadius => 'نطاق التغطية (كم)';

  @override
  String get branchFormActive => 'نشط';

  @override
  String get branchFormDelete => 'حذف الفرع';

  @override
  String get branchFormDeleteTitle => 'حذف الفرع؟';

  @override
  String get branchFormCancel => 'إلغاء';

  @override
  String get branchFormDeleteConfirm => 'حذف';

  @override
  String get branchFormNameRequired => 'الاسم مطلوب';

  @override
  String get branchFormLatInvalid => 'أدخل خط عرض صحيح';

  @override
  String get branchFormLatRange => 'يجب أن يكون خط العرض بين -90 و 90';

  @override
  String get branchFormLonInvalid => 'أدخل خط طول صحيح';

  @override
  String get branchFormLonRange => 'يجب أن يكون خط الطول بين -180 و 180';

  @override
  String get branchFormRadiusInvalid => 'أدخل نطاقاً صحيحاً > 0';

  @override
  String get staffTitle => 'الموظفون';

  @override
  String get staffAddTooltip => 'إضافة موظف';

  @override
  String get staffFilterAll => 'الكل';

  @override
  String get staffEmpty => 'لا يوجد موظفون';

  @override
  String get staffEmptyHint => 'اضغط + لإضافة أول موظف';

  @override
  String get staffFailedLoad => 'فشل تحميل الموظفين';

  @override
  String get staffRetry => 'إعادة المحاولة';

  @override
  String get staffMutationFailed => 'فشلت العملية';

  @override
  String get staffRemoveTitle => 'إزالة موظف';

  @override
  String staffRemoveConfirm(String name) {
    return 'إزالة $name من الموظفين؟';
  }

  @override
  String get staffCancel => 'إلغاء';

  @override
  String get staffRemove => 'إزالة';

  @override
  String get staffBranchScoped => 'مقيد بالفرع';

  @override
  String get staffFormEditTitle => 'تعديل بيانات الموظف';

  @override
  String get staffFormNewTitle => 'إضافة موظف';

  @override
  String get staffFormFullName => 'الاسم الكامل';

  @override
  String get staffFormPhoneOptional => 'الهاتف (اختياري)';

  @override
  String get staffFormPhone => 'رقم الهاتف';

  @override
  String get staffFormTempPassword => 'كلمة مرور مؤقتة';

  @override
  String get staffFormRole => 'الدور';

  @override
  String get staffFormBranches => 'الفروع';

  @override
  String get staffFormActive => 'نشط';

  @override
  String get staffFormSaveChanges => 'حفظ التغييرات';

  @override
  String get staffFormCreate => 'إنشاء حساب موظف';

  @override
  String get staffFormNameRequired => 'الاسم مطلوب';

  @override
  String get staffFormPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get staffFormPasswordLength =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get staffFormBranchRequired => 'اختر فرعاً واحداً على الأقل';

  @override
  String get staffFormNoBranches => 'لا توجد فروع متاحة';

  @override
  String get zonesTitle => 'مناطق التوصيل';

  @override
  String get zonesAddTooltip => 'إضافة منطقة';

  @override
  String get zonesFailedLoad => 'فشل تحميل المناطق';

  @override
  String get zonesRetry => 'إعادة المحاولة';

  @override
  String get zonesEmpty => 'لا توجد مناطق توصيل';

  @override
  String get zonesEmptyHint => 'اضغط + لإضافة أول منطقة';

  @override
  String get zonesMutationFailed => 'فشلت العملية';

  @override
  String get zonesInactive => 'غير نشط';

  @override
  String get zoneFormEditTitle => 'تعديل المنطقة';

  @override
  String get zoneFormNewTitle => 'منطقة جديدة';

  @override
  String get zoneFormSave => 'حفظ';

  @override
  String get zoneFormNameEn => 'اسم المنطقة (إنجليزي)';

  @override
  String get zoneFormNameAr => 'اسم المنطقة (عربي) — اختياري';

  @override
  String get zoneFormDeliveryFee => 'رسوم التوصيل (جنيه)';

  @override
  String get zoneFormMinOrder => 'الحد الأدنى للطلب (جنيه)';

  @override
  String get zoneFormMinItems => 'الحد الأدنى للعناصر (كمية المندوب)';

  @override
  String get zoneFormMinOrderHint => 'اضبط على 0 لتعطيل الحد الأدنى للطلب.';

  @override
  String get zoneFormMinItemsHint =>
      'الحد الأدنى لعدد العناصر التي يجب على العميل طلبها. اضبط على 0 لتعطيل.';

  @override
  String get zoneFormActive => 'نشط';

  @override
  String get zoneFormDelete => 'حذف المنطقة';

  @override
  String get zoneFormDeleteTitle => 'حذف المنطقة؟';

  @override
  String get zoneFormCancel => 'إلغاء';

  @override
  String get zoneFormDeleteConfirm => 'حذف';

  @override
  String get zoneFormNameRequired => 'الاسم مطلوب';

  @override
  String get zoneFormFeeInvalid => 'أدخل رسوماً صحيحة (0 أو أكثر)';

  @override
  String get zoneFormMinInvalid => 'أدخل 0 أو أكثر';

  @override
  String get deliveryTitle => 'التوصيل';

  @override
  String get deliveryEmpty => 'لا توجد توصيلات نشطة';

  @override
  String get deliveryAllSettled => 'جميع الطلبات منتهية';

  @override
  String deliveryActive(int count) {
    return 'نشط ($count)';
  }

  @override
  String get deliveryRecentlyDelivered => 'تم التسليم مؤخراً';

  @override
  String get deliveryPrepare => 'تحضير';

  @override
  String get deliveryDispatch => 'إرسال';

  @override
  String get deliveryDelivered => 'تم التسليم';

  @override
  String get dispatchTitle => 'لوحة الإرسال';

  @override
  String get dispatchReports => 'التقارير';

  @override
  String get dispatchToday => 'اليوم';

  @override
  String get dispatchSearchHint => 'البحث في الطلبات…';

  @override
  String get dispatchFailedLoad => 'فشل تحميل الطلبات';

  @override
  String get dispatchRetry => 'إعادة المحاولة';

  @override
  String get dispatchDropHere => 'أسقط هنا';

  @override
  String get dispatchNoOrders => 'لا توجد طلبات';

  @override
  String get dispatchCardPaid => 'مدفوع';

  @override
  String get dispatchCardUnpaid => 'غير مدفوع';

  @override
  String get dispatchCardCall => 'اتصال';

  @override
  String get dispatchCardWhatsapp => 'واتساب';

  @override
  String get dispatchCardMaps => 'خرائط';

  @override
  String get dispatchCardMarkPaid => 'تحديد كمدفوع';

  @override
  String get dispatchCardDetails => 'التفاصيل';

  @override
  String get dispatchCardHistory => 'السجل';

  @override
  String get dispatchCardNoHistory => 'لا يوجد سجل بعد';

  @override
  String get dispatchCardPayment => 'الدفع';

  @override
  String get dispatchCardTotal => 'الإجمالي';

  @override
  String get dispatchCardDeliveryFee => 'رسوم التوصيل';

  @override
  String get dispatchCardCustomer => 'العميل';

  @override
  String get dispatchCardAddress => 'العنوان';

  @override
  String get dispatchCardNotes => 'ملاحظات';

  @override
  String get dispatchCardDriver => 'السائق';

  @override
  String get dispatchCardItems => 'العناصر';

  @override
  String get dispatchCardPrintInvoice => 'طباعة الفاتورة';

  @override
  String get dispatchCardCopyInvoice => 'نسخ نص الفاتورة';

  @override
  String get dispatchCardInvoiceCopied => 'تم نسخ الفاتورة إلى الحافظة';

  @override
  String get dispatchCardAssignDriver => 'تعيين سائق';

  @override
  String get dispatchCardChangeDriver => 'تغيير السائق';

  @override
  String get dispatchCardUnassignDriver => 'إلغاء تعيين السائق';

  @override
  String get dispatchCardNoDrivers => 'لا يوجد موظفو توصيل.';

  @override
  String get dispatchCardDeposit => 'مبلغ العربون';

  @override
  String get dispatchCardDepositLabel => 'عربون';

  @override
  String get dispatchCardDepositEdit => 'تعديل';

  @override
  String get dispatchCardSetDeposit => 'تعيين العربون';

  @override
  String get dispatchCardSave => 'حفظ';

  @override
  String get dispatchCardCancel => 'إلغاء';

  @override
  String get dailyReportTitle => 'التقرير اليومي';

  @override
  String get dailyReportSingleDay => 'يوم واحد';

  @override
  String get dailyReportDateRange => 'نطاق تاريخ';

  @override
  String get dailyReportToday => 'اليوم';

  @override
  String get dailyReportChange => 'تغيير';

  @override
  String get dailyReportNoAssigned => 'لا توجد طلبات مُعيَّنة';

  @override
  String dailyReportUnassigned(int count) {
    return 'طلبات غير مُعيَّنة ($count)';
  }

  @override
  String get dailyReportAdd => 'إضافة';

  @override
  String get dailyReportAddExpense => 'إضافة مصروف';

  @override
  String get dailyReportEditExpense => 'تعديل المصروف';

  @override
  String get dailyReportCancel => 'إلغاء';

  @override
  String get dailyReportSave => 'حفظ';

  @override
  String get dailyReportDeleteExpense => 'حذف المصروف';

  @override
  String get driverReportTitle => 'تقرير السائق';

  @override
  String get driverReportFilterRange => 'نطاق';

  @override
  String get driverReportFilterAll => 'الكل';

  @override
  String get driverReportFilterByDate => 'حسب التاريخ';

  @override
  String get driverReportAllDates => 'كل التواريخ';

  @override
  String get driverReportClear => 'مسح';

  @override
  String get driverReportDrivers => 'السائقون';

  @override
  String get driverReportNoDrivers => 'لا يوجد سائقون';

  @override
  String get driverReportCollected => 'تم التحصيل';

  @override
  String get driverReportCustomShipping => 'رسوم شحن مخصصة';

  @override
  String get driverReportTotalOrders => 'إجمالي الطلبات';

  @override
  String get driverReportCashOrders => 'طلبات نقدية';

  @override
  String get driverReportInstapay => 'انستاباي';

  @override
  String get reportsTabSummary => 'الملخص';

  @override
  String get reportsTabDrivers => 'السائقون';

  @override
  String get reportsTabExpenses => 'المصروفات';

  @override
  String get reportsRetry => 'إعادة المحاولة';

  @override
  String get reportsNoDrivers => 'لا يوجد سائقون';

  @override
  String get reportsSelectDriver => 'اختر سائقاً';

  @override
  String get reportsToday => 'اليوم';

  @override
  String get reportsAdd => 'إضافة';

  @override
  String get reportsNoExpenses => 'لا توجد مصروفات في هذه الفترة';

  @override
  String get reportsChangeRange => 'تغيير النطاق';

  @override
  String get reportsTotal => 'الإجمالي';

  @override
  String get reportsTypes => 'الأنواع';

  @override
  String get reportsDays => 'الأيام';

  @override
  String get reportsSetDeposit => 'تعيين العربون';

  @override
  String get reportsAmount => 'المبلغ';

  @override
  String get reportsSave => 'حفظ';

  @override
  String get reportsCancel => 'إلغاء';

  @override
  String get reportsDeleteExpense => 'حذف المصروف';

  @override
  String get reportsModeSingleDay => 'يوم واحد';

  @override
  String get reportsModeDateRange => 'نطاق تاريخ';

  @override
  String get reportsIncomeTitle => 'الإيرادات';

  @override
  String get reportsTotalSales => 'إجمالي المبيعات';

  @override
  String get reportsDeliveryFees => 'رسوم التوصيل';

  @override
  String get reportsDeliveryCost => 'تكلفة التوصيل الفعلية';

  @override
  String get reportsNetSales => 'صافي المبيعات';

  @override
  String get reportsTotalCogs => 'إجمالي التكلفة';

  @override
  String get reportsGrossProfit => 'إجمالي الربح';

  @override
  String get reportsLoss => 'خسارة';

  @override
  String get reportsCashFlowTitle => 'التدفق النقدي';

  @override
  String get reportsCashSales => 'مبيعات كاش';

  @override
  String get reportsInstapay => 'إنستاباي';

  @override
  String get reportsDepositsPaid => 'العربونات المدفوعة';

  @override
  String get reportsDriversOwe => 'مستحقات السائقين';

  @override
  String get reportsTotalExpenses => 'إجمالي المصروفات';

  @override
  String get reportsNetCash => 'صافي الكاش';

  @override
  String get reportsDeficit => 'عجز';

  @override
  String get reportsDriverAccountsTitle => 'حسابات السائقين';

  @override
  String get reportsNoAssignedOrders => 'لا توجد طلبات مُسندة';

  @override
  String get reportsZoneAccountsTitle => 'حسابات المناطق';

  @override
  String get reportsNoZoneData => 'لا توجد بيانات مناطق';

  @override
  String get reportsAllOrdersTitle => 'جميع الطلبات';

  @override
  String get reportsNoOrders => 'لا توجد طلبات';

  @override
  String get reportsCustomerFee => 'رسوم العميل';

  @override
  String get reportsZoneLabel => 'المنطقة';

  @override
  String get reportsOrdersLabel => 'الطلبات';

  @override
  String get reportsCustFeeLabel => 'رسوم العميل';

  @override
  String get reportsActualCostLabel => 'التكلفة الفعلية';

  @override
  String get reportsEditLabel => 'تعديل';

  @override
  String get reportsSetCost => 'تعيين التكلفة';

  @override
  String get reportsTotalOrders => 'إجمالي الطلبات';

  @override
  String get reportsCashLabel => 'كاش';

  @override
  String get reportsInstapayLabel => 'إنستاباي';

  @override
  String get reportsDepositsLabel => 'العربونات';

  @override
  String get reportsDriverOwesLabel => 'مستحق السائق';

  @override
  String get reportsOwed => 'مدين';

  @override
  String get reportsOrdersTitle => 'الطلبات';

  @override
  String get reportsDue => 'المستحق';

  @override
  String get reportsAddExpense => 'إضافة مصروف';

  @override
  String get reportsEditExpense => 'تعديل مصروف';

  @override
  String get reportsTypeLabel => 'النوع';

  @override
  String get reportsTotalHeader => 'الإجمالي';

  @override
  String get reportsDeleteConfirm => 'حذف المصروف';

  @override
  String get reportsDelete => 'حذف';

  @override
  String get reportsShippingLabel => 'الشحن';

  @override
  String get bannersTitle => 'البانرات';

  @override
  String get bannersRetry => 'إعادة المحاولة';

  @override
  String get bannersFailedLoad => 'فشل التحميل';

  @override
  String get bannersEmpty => 'لا توجد بانرات بعد';

  @override
  String get bannersEmptyHint => 'اضغط + لإضافة أول بانر';

  @override
  String get bannersDeleteTitle => 'حذف البانر';

  @override
  String get bannersCancel => 'إلغاء';

  @override
  String get bannersDelete => 'حذف';

  @override
  String get bannersMutationFailed => 'فشلت العملية';

  @override
  String get bannerFormEditTitle => 'تعديل البانر';

  @override
  String get bannerFormNewTitle => 'بانر جديد';

  @override
  String get bannerFormImageUrl => 'رابط الصورة';

  @override
  String get bannerFormImageRequired => 'رابط الصورة مطلوب';

  @override
  String get bannerFormTitleField => 'العنوان (اختياري)';

  @override
  String get bannerFormSortOrder => 'ترتيب العرض';

  @override
  String get bannerFormActive => 'نشط';

  @override
  String get bannerFormOnTapAction => 'الإجراء عند الضغط';

  @override
  String get bannerFormUrlToOpen => 'رابط لفتحه';

  @override
  String get bannerFormUrlRequired => 'الرابط مطلوب';

  @override
  String get bannerFormSelectProduct => 'اختر منتجاً';

  @override
  String get bannerFormSelectCategory => 'اختر فئة';

  @override
  String get bannerFormTapProduct => 'اضغط لاختيار منتج';

  @override
  String get bannerFormTapCategory => 'اضغط لاختيار فئة';

  @override
  String get bannerFormStartDate => 'تاريخ البدء (اختياري)';

  @override
  String get bannerFormEndDate => 'تاريخ الانتهاء (اختياري)';

  @override
  String get bannerFormSaveChanges => 'حفظ التغييرات';

  @override
  String get bannerFormCreate => 'إنشاء بانر';

  @override
  String get bannerFormInvalidImage => 'رابط الصورة غير صحيح';

  @override
  String get popupAdsTitle => 'الإعلانات المنبثقة';

  @override
  String get popupAdsEmpty => 'لا توجد إعلانات منبثقة بعد';

  @override
  String get popupAdsCreate => 'إنشاء إعلان منبثق';

  @override
  String popupAdsEnds(String date) {
    return 'ينتهي $date';
  }

  @override
  String get popupAdsEdit => 'تعديل';

  @override
  String get popupAdsDelete => 'حذف';

  @override
  String get popupAdsDeleteTitle => 'حذف الإعلان المنبثق؟';

  @override
  String get popupAdsCancel => 'إلغاء';

  @override
  String get popupAdFormEditTitle => 'تعديل الإعلان المنبثق';

  @override
  String get popupAdFormNewTitle => 'إعلان منبثق جديد';

  @override
  String get popupAdFormSave => 'حفظ';

  @override
  String get popupAdFormBasicInfo => 'المعلومات الأساسية';

  @override
  String get popupAdFormImage => 'الصورة';

  @override
  String get popupAdFormButton => 'الزر (اختياري)';

  @override
  String get popupAdFormSchedule => 'الجدولة (اختياري)';

  @override
  String get popupAdFormTitleField => 'العنوان *';

  @override
  String get popupAdFormTitleRequired => 'العنوان مطلوب';

  @override
  String get popupAdFormBody => 'نص الجسم (اختياري)';

  @override
  String get popupAdFormImageUrl => 'رابط الصورة';

  @override
  String get popupAdFormUpload => 'رفع';

  @override
  String get popupAdFormButtonLabel => 'نص الزر';

  @override
  String get popupAdFormButtonUrl => 'رابط الزر';

  @override
  String get popupAdFormStartDate => 'تاريخ البدء';

  @override
  String get popupAdFormEndDate => 'تاريخ الانتهاء';

  @override
  String get popupAdFormActive => 'نشط';

  @override
  String popupAdFormUploadFailed(String error) {
    return 'فشل الرفع: $error';
  }

  @override
  String get popupAdFormFrequency => 'تكرار العرض';

  @override
  String get popupAdFreqEverySession => 'كل جلسة';

  @override
  String get popupAdFreqOncePerDay => 'مرة يومياً';

  @override
  String get popupAdFreqOnceEver => 'مرة واحدة فقط';

  @override
  String get popupAdFormCountdown => 'مؤقت العد التنازلي (اختياري)';

  @override
  String get popupAdFormCountdownAt => 'ينتهي العد في';

  @override
  String get promoCodesTitle => 'أكواد الخصم';

  @override
  String get promoCodesRetry => 'إعادة المحاولة';

  @override
  String get promoCodesFailedLoad => 'فشل التحميل';

  @override
  String get promoCodesEmpty => 'لا توجد أكواد خصم';

  @override
  String get promoCodesEmptyHint => 'اضغط + لإنشاء كود';

  @override
  String get promoCodesFilterAll => 'الكل';

  @override
  String get promoCodesFilterActive => 'نشط';

  @override
  String get promoCodesFilterExpired => 'منتهي';

  @override
  String get promoCodesFilterInactive => 'غير نشط';

  @override
  String get promoCodesDeleteTitle => 'حذف كود الخصم';

  @override
  String get promoCodesCancel => 'إلغاء';

  @override
  String get promoCodesDelete => 'حذف';

  @override
  String get promoCodes_mutationFailed => 'فشلت العملية';

  @override
  String promoCodesCopied(String code) {
    return 'تم نسخ $code';
  }

  @override
  String get promoCodeFormEditTitle => 'تعديل كود الخصم';

  @override
  String get promoCodeFormNewTitle => 'كود خصم جديد';

  @override
  String get promoCodeFormCodeField => 'كود الخصم';

  @override
  String get promoCodeFormCodeRequired => 'الكود مطلوب';

  @override
  String get promoCodeFormDiscountType => 'نوع الخصم';

  @override
  String get promoCodeFormDiscountPct => 'نسبة الخصم';

  @override
  String get promoCodeFormDiscountAmount => 'مبلغ الخصم (جنيه)';

  @override
  String get promoCodeFormInvalidValue => 'أدخل قيمة صحيحة';

  @override
  String get promoCodeFormPctMax => 'لا يمكن أن تتجاوز النسبة 100%';

  @override
  String get promoCodeFormDescription => 'الوصف (اختياري)';

  @override
  String get promoCodeFormMinOrder => 'الحد الأدنى للطلب (جنيه)';

  @override
  String get promoCodeFormMaxUses => 'الحد الأقصى للاستخدام';

  @override
  String get promoCodeFormPerUser => 'حد الاستخدام للمستخدم';

  @override
  String get promoCodeFormMin1 => 'الحد الأدنى 1';

  @override
  String get promoCodeFormStartDate => 'تاريخ البدء (اختياري)';

  @override
  String get promoCodeFormExpiryDate => 'تاريخ الانتهاء (اختياري)';

  @override
  String get promoCodeFormActive => 'نشط';

  @override
  String get promoCodeFormSaveChanges => 'حفظ التغييرات';

  @override
  String get promoCodeFormCreate => 'إنشاء كود خصم';

  @override
  String get promoCodeFormGenerate => 'توليد كود عشوائي';

  @override
  String get loyaltyTitle => 'إدارة الولاء';

  @override
  String get loyaltyTabRules => 'القواعد';

  @override
  String get loyaltyTabSpend => 'مراحل الإنفاق';

  @override
  String get loyaltyTabPoints => 'مكافآت النقاط';

  @override
  String get loyaltyTabTransactions => 'المعاملات';

  @override
  String get loyaltyFilterCustomer => 'تصفية برقم العميل…';

  @override
  String get loyaltyNoTransactions => 'لا توجد معاملات';

  @override
  String get loyaltyTransactionsHint => 'ستظهر معاملات الولاء هنا';

  @override
  String get loyaltyTypeCashback => 'حدث استرداد نقدي';

  @override
  String get loyaltyTypeBaseEarn => 'كسب أساسي';

  @override
  String get loyaltyTypeFreeProduct => 'منتج مجاني';

  @override
  String get loyaltyTypeFreeDelivery => 'توصيل مجاني';

  @override
  String get loyaltyGoalFormEditTitle => 'تعديل مكافأة النقاط';

  @override
  String get loyaltyGoalFormNewTitle => 'مكافأة نقاط جديدة';

  @override
  String get loyaltyGoalFormSave => 'حفظ';

  @override
  String get loyaltyGoalFormIcon => 'أيقونة (إيموجي)';

  @override
  String get loyaltyGoalFormTitle => 'العنوان';

  @override
  String get loyaltyGoalFormTitleRequired => 'العنوان مطلوب';

  @override
  String get loyaltyGoalFormPointsRequired => 'النقاط المطلوبة';

  @override
  String get loyaltyGoalFormPointsInvalid => 'أدخل نقاطاً أكثر من 0';

  @override
  String get loyaltyGoalFormRewardType => 'نوع المكافأة';

  @override
  String get loyaltyGoalFormFreeDelivery => 'توصيل مجاني';

  @override
  String get loyaltyGoalFormFreeProduct => 'منتج مجاني';

  @override
  String get loyaltyGoalFormSelectProduct => 'اختر منتجاً مجانياً';

  @override
  String get loyaltyGoalFormTapProduct => 'اضغط لاختيار منتج';

  @override
  String get loyaltyGoalFormDescription => 'الوصف — اختياري';

  @override
  String get loyaltyGoalFormSortOrder => 'ترتيب العرض';

  @override
  String get loyaltyGoalFormSortInvalid => 'أدخل 0 أو أكثر';

  @override
  String get loyaltyGoalFormActive => 'نشط';

  @override
  String get loyaltyGoalFormDelete => 'حذف المكافأة';

  @override
  String get loyaltyGoalFormDeleteTitle => 'حذف المكافأة؟';

  @override
  String get loyaltyGoalFormCancel => 'إلغاء';

  @override
  String get loyaltyGoalFormDeleteConfirm => 'حذف';

  @override
  String get loyaltyRuleFormEditTitle => 'تعديل القاعدة';

  @override
  String get loyaltyRuleFormNewTitle => 'قاعدة جديدة';

  @override
  String get loyaltyRuleFormSave => 'حفظ';

  @override
  String get loyaltyRuleFormName => 'اسم القاعدة';

  @override
  String get loyaltyRuleFormNameRequired => 'الاسم مطلوب';

  @override
  String get loyaltyRuleFormType => 'نوع القاعدة';

  @override
  String get loyaltyRuleFormBaseEarn => 'كسب أساسي';

  @override
  String get loyaltyRuleFormCashback => 'حدث استرداد نقدي';

  @override
  String get loyaltyRuleFormPointsPerEgp => 'نقاط لكل جنيه منفق';

  @override
  String get loyaltyRuleFormPointsInvalid => 'أدخل قيمة أكبر من 0';

  @override
  String get loyaltyRuleFormMinOrder => 'الحد الأدنى للطلب (جنيه) — اختياري';

  @override
  String get loyaltyRuleFormValidFrom => 'صالح من — اختياري';

  @override
  String get loyaltyRuleFormValidUntil => 'صالح حتى — اختياري';

  @override
  String get loyaltyRuleFormDailyStart => 'وقت البدء اليومي — اختياري';

  @override
  String get loyaltyRuleFormDailyEnd => 'وقت الانتهاء اليومي — اختياري';

  @override
  String get loyaltyRuleFormSelectDate => 'اختر تاريخاً';

  @override
  String get loyaltyRuleFormSelectTime => 'اختر وقتاً';

  @override
  String get loyaltyRuleFormActive => 'نشط';

  @override
  String get loyaltyRuleFormDelete => 'حذف القاعدة';

  @override
  String get loyaltyRuleFormDeleteTitle => 'حذف القاعدة؟';

  @override
  String get loyaltyRuleFormCancel => 'إلغاء';

  @override
  String get loyaltyRuleFormDeleteConfirm => 'حذف';

  @override
  String get spendGoalFormEditTitle => 'تعديل مرحلة الإنفاق';

  @override
  String get spendGoalFormNewTitle => 'مرحلة إنفاق جديدة';

  @override
  String get spendGoalFormSave => 'حفظ';

  @override
  String get spendGoalFormIcon => 'أيقونة (إيموجي)';

  @override
  String get spendGoalFormTitle => 'العنوان';

  @override
  String get spendGoalFormTitleRequired => 'العنوان مطلوب';

  @override
  String get spendGoalFormSpendRequired => 'الإنفاق المطلوب (جنيه)';

  @override
  String get spendGoalFormSpendInvalid => 'أدخل مبلغ إنفاق أكبر من 0';

  @override
  String get spendGoalFormRewardType => 'نوع المكافأة';

  @override
  String get spendGoalFormFreeDelivery => 'توصيل مجاني';

  @override
  String get spendGoalFormFreeProduct => 'منتج مجاني';

  @override
  String get spendGoalFormDiscount => 'خصم (%)';

  @override
  String get spendGoalFormDiscountInvalid => 'أدخل خصماً بين 1 و 100';

  @override
  String get spendGoalFormDescription => 'الوصف — اختياري';

  @override
  String get spendGoalFormSortOrder => 'ترتيب العرض';

  @override
  String get spendGoalFormActive => 'نشط';

  @override
  String get spendGoalFormDelete => 'حذف المرحلة';

  @override
  String get spendGoalFormDeleteTitle => 'حذف المرحلة؟';

  @override
  String get spendGoalFormCancel => 'إلغاء';

  @override
  String get spendGoalFormDeleteConfirm => 'حذف';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsServiceFee => 'رسوم الخدمة';

  @override
  String get settingsShowInCheckout => 'عرض في الدفع';

  @override
  String get settingsShowInCheckoutSubtitle => 'يظهر كسطر منفصل في ملخص الطلب';

  @override
  String get settingsFeeAmount => 'مبلغ الرسوم (جنيه)';

  @override
  String get settingsMaxPoints => 'أقصى نقاط لكل طلب (0 = غير محدود)';

  @override
  String get settingsOnlineWindow => 'نافذة المستخدم النشط (دقائق)';

  @override
  String get settingsOnlineWindowDesc =>
      'يُعدّ المستخدم \"نشطاً\" إذا كان فعّالاً خلال هذه النافذة الزمنية';

  @override
  String get settingsReferralBonusReferrer => 'مكافأة الإحالة — المُحيل (نقاط)';

  @override
  String get settingsReferralRewardNew =>
      'مكافأة الإحالة — المستخدم الجديد (نقاط)';

  @override
  String get settingsSaveChanges => 'حفظ التغييرات';

  @override
  String get settingsSaveFailed => 'فشل الحفظ';

  @override
  String get settingsSignOut => 'تسجيل الخروج';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageEnglish => 'الإنجليزية';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get csvTitle => 'استيراد / تصدير';

  @override
  String get csvTabProducts => 'المنتجات';

  @override
  String get csvTabCustomers => 'العملاء';

  @override
  String get csvTabOrders => 'الطلبات';

  @override
  String get csvExportProducts => 'تصدير المنتجات';

  @override
  String get csvImportProducts => 'استيراد المنتجات';

  @override
  String get csvExportCustomers => 'تصدير العملاء';

  @override
  String get csvImportCustomers => 'استيراد العملاء';

  @override
  String get csvExportOrders => 'تصدير الطلبات';

  @override
  String get csvExportCsv => 'تصدير CSV';

  @override
  String get csvPickFile => 'اختر ملف CSV';

  @override
  String get csvProcessing => 'جارٍ المعالجة…';

  @override
  String get csvOrderImportWarning => 'استيراد الطلبات غير مدعوم';

  @override
  String get csvProductImportPreview => 'معاينة استيراد المنتجات';

  @override
  String get csvCustomerImportPreview => 'معاينة استيراد العملاء';

  @override
  String csvRows(int count) {
    return '$count صف';
  }

  @override
  String csvAndMore(int count) {
    return '… و $count أخرى';
  }

  @override
  String get csvCancel => 'إلغاء';

  @override
  String csvImportRows(int count) {
    return 'استيراد $count صف';
  }

  @override
  String get csvExpectedColumns => 'أعمدة CSV المطلوبة';

  @override
  String get stubComingSoon => 'قريباً';
}
