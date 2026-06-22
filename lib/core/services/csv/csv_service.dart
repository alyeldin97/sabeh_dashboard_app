import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../../features/customers/data/model/customer.dart';
import '../../../features/orders/data/model/order_model.dart';
import '../../../features/products/data/model/product.dart';
import 'file_downloader.dart';

class CsvService {
  // ─── File picking ────────────────────────────────────────────────────────────

  Future<String?> pickCsvContent() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final bytes = result.files.first.bytes;
    if (bytes == null) return null;
    // Strip UTF-8 BOM if present
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return String.fromCharCodes(bytes.sublist(3));
    }
    return String.fromCharCodes(bytes);
  }

  // ─── Products ────────────────────────────────────────────────────────────────

  /// Exports products in Shopify-compatible CSV format.
  /// Multi-row per product when variants exist (one row per variant).
  Future<void> exportProducts(List<Product> products) async {
    final rows = <List<dynamic>>[_shopifyProductHeaders];

    for (final p in products) {
      final handle = _toHandle(p.name);
      final totalInventory = p.inventoryByBranch.values.fold(0, (a, b) => a + b);
      final status = p.isActive ? 'active' : 'draft';
      final imageUrl = p.primaryImage ?? '';

      if (p.options.isEmpty) {
        // Simple product — single row
        rows.add([
          handle,             // Handle
          p.name,             // Title
          p.description ?? '',// Body (HTML)
          '',                 // Vendor
          '',                 // Product Category
          p.type.value,       // Type
          '',                 // Tags
          p.isActive,         // Published
          '', '',             // Option1 Name/Value
          '', '',             // Option2 Name/Value
          '', '',             // Option3 Name/Value
          '',                 // Variant SKU
          '',                 // Variant Grams
          'shopify',          // Variant Inventory Tracker
          totalInventory,     // Variant Inventory Qty
          'deny',             // Variant Inventory Policy
          'manual',           // Variant Fulfillment Service
          p.price,            // Variant Price
          p.compareAtPrice ?? '', // Variant Compare At Price
          true,               // Variant Requires Shipping
          false,              // Variant Taxable
          '',                 // Variant Barcode
          imageUrl,           // Image Src
          1,                  // Image Position
          '',                 // Image Alt Text
          false,              // Gift Card
          '',                 // SEO Title
          '',                 // SEO Description
          status,             // Status
        ]);
      } else {
        // Product with variants — one row per variant
        final optionNames = p.options.map((o) => o.name).toList();

        bool isFirst = true;
        for (final v in p.variants) {
          final varInventory = v.inventoryByBranch.values.fold(0, (a, b) => a + b);

          // Resolve option values for this variant
          final optValues = List<String>.filled(3, '');
          final optNames = List<String>.filled(3, '');
          for (var oi = 0; oi < p.options.length && oi < 3; oi++) {
            final opt = p.options[oi];
            optNames[oi] = optionNames[oi];
            // find which value this variant uses for this option
            final matchingValue = opt.values
                .where((val) => v.optionValueIds.contains(val.id))
                .firstOrNull;
            optValues[oi] = matchingValue?.value ?? (opt.values.isNotEmpty ? opt.values.first.value : '');
          }

          rows.add([
            handle,
            isFirst ? p.name : '',
            isFirst ? (p.description ?? '') : '',
            '',
            '',
            isFirst ? p.type.value : '',
            '',
            isFirst ? p.isActive : '',
            optNames[0], optValues[0],
            optNames[1], optValues[1],
            optNames[2], optValues[2],
            '',
            '',
            'shopify',
            varInventory,
            'deny',
            'manual',
            v.price,
            v.compareAtPrice ?? '',
            true,
            false,
            '',
            isFirst ? imageUrl : '',
            isFirst ? 1 : '',
            '',
            false,
            '',
            '',
            status,
          ]);
          isFirst = false;
        }
      }
    }

    final csv = const ListToCsvConverter().convert(rows);
    final date = _dateStamp();
    await platformDownloadCsv(csv, 'products_$date.csv');
  }

  /// Parses a Shopify-format product CSV.
  /// Returns a list of product import maps ready for ProductsRepository.createProduct.
  List<Map<String, dynamic>> importProducts(String csvContent) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvContent);
    if (rows.length < 2) return [];

    final headers = rows.first.map((h) => h.toString().trim()).toList();
    final dataRows = rows.skip(1).map((r) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length && i < r.length; i++) {
        map[headers[i]] = r[i]?.toString().trim() ?? '';
      }
      return map;
    }).toList();

    // Group rows by Handle
    final Map<String, List<Map<String, String>>> byHandle = {};
    for (final row in dataRows) {
      final handle = row['Handle'] ?? '';
      if (handle.isEmpty) continue;
      byHandle.putIfAbsent(handle, () => []).add(row);
    }

    final result = <Map<String, dynamic>>[];

    for (final entry in byHandle.entries) {
      final rows = entry.value;
      final first = rows.first;

      final title = first['Title'] ?? '';
      if (title.isEmpty) continue;

      final description = first['Body (HTML)'] ?? '';
      final typeStr = first['Type'] ?? 'fixed';
      final status = first['Status'] ?? 'active';
      final isActive = status.toLowerCase() != 'draft';
      final imageUrl = first['Image Src'] ?? '';
      final price = double.tryParse(first['Variant Price'] ?? '') ?? 0;
      final compareAt = double.tryParse(first['Variant Compare At Price'] ?? '');

      final opt1Name = first['Option1 Name'] ?? '';
      final opt2Name = first['Option2 Name'] ?? '';
      final opt3Name = first['Option3 Name'] ?? '';

      final hasOptions = opt1Name.isNotEmpty;

      final fields = <String, dynamic>{
        'name': title,
        'description': description.isEmpty ? null : description,
        'price': price,
        'compare_at_price': compareAt,
        'product_type': typeStr,
        'is_active': isActive,
        'track_inventory': false,
        'sort_order': 0,
        'images': imageUrl.isNotEmpty ? [imageUrl] : [],
        'loyalty_points': 0,
      };

      if (!hasOptions) {
        // Simple product
        final invQty = int.tryParse(first['Variant Inventory Qty'] ?? '') ?? 0;
        result.add({
          'fields': fields,
          'branchIds': <String>[],
          'categoryIds': <String>[],
          'options': <Map<String, dynamic>>[],
          'variants': <Map<String, dynamic>>[],
          'inventory': invQty > 0 ? {'__total__': invQty} : <String, int>{},
        });
      } else {
        // Build option structures
        final optNamesList = [opt1Name, opt2Name, opt3Name]
            .where((n) => n.isNotEmpty)
            .toList();

        // Collect unique values per option in order of appearance
        final optValuesMap = List.generate(optNamesList.length, (_) => <String>[]);
        for (final row in rows) {
          final vals = [
            row['Option1 Value'] ?? '',
            row['Option2 Value'] ?? '',
            row['Option3 Value'] ?? '',
          ];
          for (var oi = 0; oi < optNamesList.length; oi++) {
            final v = vals[oi];
            if (v.isNotEmpty && !optValuesMap[oi].contains(v)) {
              optValuesMap[oi].add(v);
            }
          }
        }

        final options = <Map<String, dynamic>>[];
        for (var oi = 0; oi < optNamesList.length; oi++) {
          options.add({'name': optNamesList[oi], 'values': optValuesMap[oi]});
        }

        // Build variants
        final variants = <Map<String, dynamic>>[];
        for (final row in rows) {
          final vals = [
            row['Option1 Value'] ?? '',
            row['Option2 Value'] ?? '',
            row['Option3 Value'] ?? '',
          ];
          final varPrice = double.tryParse(row['Variant Price'] ?? '') ?? price;
          final varCompare = double.tryParse(row['Variant Compare At Price'] ?? '');
          final invQty = int.tryParse(row['Variant Inventory Qty'] ?? '') ?? 0;

          final valueIndices = <int>[];
          for (var oi = 0; oi < optNamesList.length; oi++) {
            final idx = optValuesMap[oi].indexOf(vals[oi]);
            valueIndices.add(idx < 0 ? 0 : idx);
          }

          variants.add({
            'valueIndices': valueIndices,
            'price': varPrice,
            'compareAtPrice': varCompare,
            'isActive': true,
            'inventory': invQty > 0 ? {'__total__': invQty} : <String, int>{},
          });
        }

        result.add({
          'fields': fields,
          'branchIds': <String>[],
          'categoryIds': <String>[],
          'options': options,
          'variants': variants,
          'inventory': <String, int>{},
        });
      }
    }

    return result;
  }

  // ─── Customers ───────────────────────────────────────────────────────────────

  Future<void> exportCustomers(List<Customer> customers) async {
    final rows = <List<dynamic>>[_shopifyCustomerHeaders];
    for (final c in customers) {
      final parts = (c.name ?? '').trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      rows.add([
        firstName,
        lastName,
        c.email ?? '',
        false,            // Accepts Email Marketing
        '',               // Company
        '',               // Address1
        '',               // Address2
        '',               // City
        '',               // Province
        '',               // Province Code
        '',               // Country
        '',               // Country Code
        '',               // Zip
        c.phone ?? '',
        false,            // Accepts SMS Marketing
        c.totalSpent.toStringAsFixed(2),
        c.orderCount,
        c.isBlocked ? 'blocked' : '',  // Tags
        c.internalNotes ?? '',          // Note
        false,            // Tax Exempt
      ]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    await platformDownloadCsv(csv, 'customers_${_dateStamp()}.csv');
  }

  /// Parses a Shopify-format customer CSV.
  /// Returns list of maps with name/phone/email for createCustomer.
  List<Map<String, String>> importCustomers(String csvContent) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvContent);
    if (rows.length < 2) return [];

    final headers = rows.first.map((h) => h.toString().trim()).toList();
    final result = <Map<String, String>>[];

    for (final row in rows.skip(1)) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        map[headers[i]] = row[i]?.toString().trim() ?? '';
      }

      final firstName = map['First Name'] ?? '';
      final lastName = map['Last Name'] ?? '';
      final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
      final email = map['Email'] ?? '';
      final phone = map['Phone'] ?? '';

      if (name.isEmpty && email.isEmpty && phone.isEmpty) continue;

      result.add({'name': name, 'email': email, 'phone': phone});
    }

    return result;
  }

  // ─── Orders ──────────────────────────────────────────────────────────────────

  Future<void> exportOrders(List<OrderModel> orders) async {
    final rows = <List<dynamic>>[_orderHeaders];
    for (final o in orders) {
      for (final item in o.items) {
        rows.add([
          o.id,
          o.createdAt.toIso8601String(),
          o.status.label,
          o.paymentLabel,
          o.totalPrice.toStringAsFixed(2),
          o.userPaidDeliveryFees.toStringAsFixed(2),
          o.serviceFee.toStringAsFixed(2),
          o.loyaltyDiscount.toStringAsFixed(2),
          o.promoDiscount.toStringAsFixed(2),
          o.promoCodeUsed ?? '',
          o.deliveryAddress ?? '',
          o.notes ?? '',
          o.driverName ?? '',
          item.productName,
          item.quantity,
          item.unitPrice.toStringAsFixed(2),
          item.subtotal.toStringAsFixed(2),
        ]);
      }
      if (o.items.isEmpty) {
        rows.add([
          o.id, o.createdAt.toIso8601String(), o.status.label,
          o.paymentLabel, o.totalPrice.toStringAsFixed(2),
          o.userPaidDeliveryFees.toStringAsFixed(2), o.serviceFee.toStringAsFixed(2),
          o.loyaltyDiscount.toStringAsFixed(2), o.promoDiscount.toStringAsFixed(2),
          o.promoCodeUsed ?? '', o.deliveryAddress ?? '', o.notes ?? '',
          o.driverName ?? '', '', '', '', '',
        ]);
      }
    }
    final csv = const ListToCsvConverter().convert(rows);
    await platformDownloadCsv(csv, 'orders_${_dateStamp()}.csv');
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _toHandle(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'-+$'), '');

  String _dateStamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  static const _shopifyProductHeaders = [
    'Handle', 'Title', 'Body (HTML)', 'Vendor', 'Product Category', 'Type',
    'Tags', 'Published',
    'Option1 Name', 'Option1 Value', 'Option2 Name', 'Option2 Value',
    'Option3 Name', 'Option3 Value',
    'Variant SKU', 'Variant Grams', 'Variant Inventory Tracker',
    'Variant Inventory Qty', 'Variant Inventory Policy',
    'Variant Fulfillment Service', 'Variant Price', 'Variant Compare At Price',
    'Variant Requires Shipping', 'Variant Taxable', 'Variant Barcode',
    'Image Src', 'Image Position', 'Image Alt Text',
    'Gift Card', 'SEO Title', 'SEO Description', 'Status',
  ];

  static const _shopifyCustomerHeaders = [
    'First Name', 'Last Name', 'Email', 'Accepts Email Marketing', 'Company',
    'Address1', 'Address2', 'City', 'Province', 'Province Code', 'Country',
    'Country Code', 'Zip', 'Phone', 'Accepts SMS Marketing',
    'Total Spent', 'Total Orders', 'Tags', 'Note', 'Tax Exempt',
  ];

  static const _orderHeaders = [
    'Order ID', 'Created At', 'Status', 'Payment Method',
    'Total', 'Delivery Fee', 'Service Fee', 'Loyalty Discount', 'Promo Discount',
    'Promo Code', 'Delivery Address', 'Notes', 'Driver',
    'Item Name', 'Item Qty', 'Item Unit Price', 'Item Subtotal',
  ];
}
