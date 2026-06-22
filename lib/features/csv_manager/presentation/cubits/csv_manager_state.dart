import 'package:equatable/equatable.dart';

enum CsvOp { idle, loading, success, error }

class CsvManagerState extends Equatable {
  final CsvOp productsExport;
  final CsvOp productsImport;
  final CsvOp customersExport;
  final CsvOp customersImport;
  final CsvOp ordersExport;

  /// Preview rows before committing an import (null = no preview active)
  final List<Map<String, dynamic>>? productImportPreview;
  final List<Map<String, String>>? customerImportPreview;

  final String? errorMessage;
  final String? successMessage;

  const CsvManagerState({
    this.productsExport = CsvOp.idle,
    this.productsImport = CsvOp.idle,
    this.customersExport = CsvOp.idle,
    this.customersImport = CsvOp.idle,
    this.ordersExport = CsvOp.idle,
    this.productImportPreview,
    this.customerImportPreview,
    this.errorMessage,
    this.successMessage,
  });

  CsvManagerState copyWith({
    CsvOp? productsExport,
    CsvOp? productsImport,
    CsvOp? customersExport,
    CsvOp? customersImport,
    CsvOp? ordersExport,
    List<Map<String, dynamic>>? productImportPreview,
    bool clearProductPreview = false,
    List<Map<String, String>>? customerImportPreview,
    bool clearCustomerPreview = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) =>
      CsvManagerState(
        productsExport: productsExport ?? this.productsExport,
        productsImport: productsImport ?? this.productsImport,
        customersExport: customersExport ?? this.customersExport,
        customersImport: customersImport ?? this.customersImport,
        ordersExport: ordersExport ?? this.ordersExport,
        productImportPreview:
            clearProductPreview ? null : productImportPreview ?? this.productImportPreview,
        customerImportPreview:
            clearCustomerPreview ? null : customerImportPreview ?? this.customerImportPreview,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      );

  @override
  List<Object?> get props => [
        productsExport, productsImport,
        customersExport, customersImport,
        ordersExport,
        productImportPreview, customerImportPreview,
        errorMessage, successMessage,
      ];
}
