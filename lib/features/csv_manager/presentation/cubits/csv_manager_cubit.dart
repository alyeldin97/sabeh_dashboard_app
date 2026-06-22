import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/csv/csv_service.dart';
import '../../../customers/data/repo/customers_repository.dart';
import '../../../orders/data/repo/orders_repository.dart';
import '../../../products/data/repo/products_repository.dart';
import 'csv_manager_state.dart';

class CsvManagerCubit extends Cubit<CsvManagerState> {
  CsvManagerCubit({
    required ProductsRepository productsRepo,
    required CustomersRepository customersRepo,
    required OrdersRepository ordersRepo,
  })  : _productsRepo = productsRepo,
        _customersRepo = customersRepo,
        _ordersRepo = ordersRepo,
        super(const CsvManagerState());

  final ProductsRepository _productsRepo;
  final CustomersRepository _customersRepo;
  final OrdersRepository _ordersRepo;
  final _csv = CsvService();

  // ─── Products export ─────────────────────────────────────────────────────────

  Future<void> exportProducts() async {
    emit(state.copyWith(productsExport: CsvOp.loading, clearError: true, clearSuccess: true));
    try {
      final products = await _productsRepo.getProducts();
      await _csv.exportProducts(products);
      emit(state.copyWith(
        productsExport: CsvOp.success,
        successMessage: 'Exported ${products.length} products.',
      ));
    } catch (e) {
      emit(state.copyWith(
        productsExport: CsvOp.error,
        errorMessage: 'Products export failed: $e',
      ));
    }
  }

  // ─── Products import ─────────────────────────────────────────────────────────

  Future<void> pickProductsFile() async {
    emit(state.copyWith(productsImport: CsvOp.loading, clearError: true, clearSuccess: true));
    try {
      final content = await _csv.pickCsvContent();
      if (content == null) {
        emit(state.copyWith(productsImport: CsvOp.idle));
        return;
      }
      final preview = _csv.importProducts(content);
      if (preview.isEmpty) {
        emit(state.copyWith(
          productsImport: CsvOp.error,
          errorMessage: 'No valid product rows found in the file.',
        ));
        return;
      }
      emit(state.copyWith(
        productsImport: CsvOp.idle,
        productImportPreview: preview,
      ));
    } catch (e) {
      emit(state.copyWith(
        productsImport: CsvOp.error,
        errorMessage: 'Failed to read file: $e',
      ));
    }
  }

  Future<void> commitProductsImport() async {
    final preview = state.productImportPreview;
    if (preview == null || preview.isEmpty) return;

    emit(state.copyWith(productsImport: CsvOp.loading, clearError: true, clearSuccess: true));
    int imported = 0;
    final errors = <String>[];

    for (final item in preview) {
      try {
        await _productsRepo.createProduct(
          fields: item['fields'] as Map<String, dynamic>,
          branchIds: (item['branchIds'] as List).cast<String>(),
          categoryIds: (item['categoryIds'] as List).cast<String>(),
          options: (item['options'] as List).cast<Map<String, dynamic>>(),
          variants: (item['variants'] as List).cast<Map<String, dynamic>>(),
          productInventory: (item['inventory'] as Map).cast<String, int>(),
        );
        imported++;
      } catch (e) {
        final name = (item['fields'] as Map<String, dynamic>)['name'] ?? '?';
        errors.add('$name: $e');
      }
    }

    if (errors.isEmpty) {
      emit(state.copyWith(
        productsImport: CsvOp.success,
        clearProductPreview: true,
        successMessage: 'Imported $imported products successfully.',
      ));
    } else {
      emit(state.copyWith(
        productsImport: CsvOp.error,
        clearProductPreview: true,
        errorMessage: 'Imported $imported/${preview.length}. Errors:\n${errors.take(5).join('\n')}',
      ));
    }
  }

  void cancelProductsImport() =>
      emit(state.copyWith(clearProductPreview: true, productsImport: CsvOp.idle));

  // ─── Customers export ────────────────────────────────────────────────────────

  Future<void> exportCustomers() async {
    emit(state.copyWith(customersExport: CsvOp.loading, clearError: true, clearSuccess: true));
    try {
      final customers = await _customersRepo.getCustomers();
      await _csv.exportCustomers(customers);
      emit(state.copyWith(
        customersExport: CsvOp.success,
        successMessage: 'Exported ${customers.length} customers.',
      ));
    } catch (e) {
      emit(state.copyWith(
        customersExport: CsvOp.error,
        errorMessage: 'Customers export failed: $e',
      ));
    }
  }

  // ─── Customers import ────────────────────────────────────────────────────────

  Future<void> pickCustomersFile() async {
    emit(state.copyWith(customersImport: CsvOp.loading, clearError: true, clearSuccess: true));
    try {
      final content = await _csv.pickCsvContent();
      if (content == null) {
        emit(state.copyWith(customersImport: CsvOp.idle));
        return;
      }
      final preview = _csv.importCustomers(content);
      if (preview.isEmpty) {
        emit(state.copyWith(
          customersImport: CsvOp.error,
          errorMessage: 'No valid customer rows found in the file.',
        ));
        return;
      }
      emit(state.copyWith(
        customersImport: CsvOp.idle,
        customerImportPreview: preview,
      ));
    } catch (e) {
      emit(state.copyWith(
        customersImport: CsvOp.error,
        errorMessage: 'Failed to read file: $e',
      ));
    }
  }

  Future<void> commitCustomersImport() async {
    final preview = state.customerImportPreview;
    if (preview == null || preview.isEmpty) return;

    emit(state.copyWith(customersImport: CsvOp.loading, clearError: true, clearSuccess: true));
    int imported = 0;
    final errors = <String>[];

    for (final row in preview) {
      try {
        await _customersRepo.createCustomer(
          name: row['name'] ?? '',
          phone: row['phone']?.isNotEmpty == true ? row['phone'] : null,
          email: row['email']?.isNotEmpty == true ? row['email'] : null,
        );
        imported++;
      } catch (e) {
        errors.add('${row['name'] ?? '?'}: $e');
      }
    }

    if (errors.isEmpty) {
      emit(state.copyWith(
        customersImport: CsvOp.success,
        clearCustomerPreview: true,
        successMessage: 'Imported $imported customers successfully.',
      ));
    } else {
      emit(state.copyWith(
        customersImport: CsvOp.error,
        clearCustomerPreview: true,
        errorMessage: 'Imported $imported/${preview.length}. Errors:\n${errors.take(5).join('\n')}',
      ));
    }
  }

  void cancelCustomersImport() =>
      emit(state.copyWith(clearCustomerPreview: true, customersImport: CsvOp.idle));

  // ─── Orders export ───────────────────────────────────────────────────────────

  Future<void> exportOrders() async {
    emit(state.copyWith(ordersExport: CsvOp.loading, clearError: true, clearSuccess: true));
    try {
      final orders = await _ordersRepo.getOrders();
      await _csv.exportOrders(orders);
      emit(state.copyWith(
        ordersExport: CsvOp.success,
        successMessage: 'Exported ${orders.length} orders.',
      ));
    } catch (e) {
      emit(state.copyWith(
        ordersExport: CsvOp.error,
        errorMessage: 'Orders export failed: $e',
      ));
    }
  }
}
