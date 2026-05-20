import 'package:equatable/equatable.dart';
import '../../../orders/data/model/order_model.dart';

enum DispatchBoardStatus { initial, loading, success, failure }

class DispatchBoardState extends Equatable {
  final DispatchBoardStatus status;
  final DateTime viewDate;
  final Map<OrderStatus, List<OrderModel>> columns;
  final String? selectedDriverId;
  final String searchQuery;
  final String? errorMessage;

  const DispatchBoardState({
    this.status = DispatchBoardStatus.initial,
    required this.viewDate,
    this.columns = const {},
    this.selectedDriverId,
    this.searchQuery = '',
    this.errorMessage,
  });

  DispatchBoardState copyWith({
    DispatchBoardStatus? status,
    DateTime? viewDate,
    Map<OrderStatus, List<OrderModel>>? columns,
    String? selectedDriverId,
    bool clearDriverFilter = false,
    String? searchQuery,
    String? errorMessage,
  }) =>
      DispatchBoardState(
        status:          status          ?? this.status,
        viewDate:        viewDate        ?? this.viewDate,
        columns:         columns         ?? this.columns,
        selectedDriverId: clearDriverFilter
            ? null
            : selectedDriverId ?? this.selectedDriverId,
        searchQuery:     searchQuery     ?? this.searchQuery,
        errorMessage:    errorMessage,
      );

  List<OrderModel> filteredColumn(OrderStatus s) {
    final orders = columns[s] ?? [];
    if (searchQuery.isEmpty && selectedDriverId == null) return orders;
    return orders.where((o) {
      final driverOk =
          selectedDriverId == null || o.driverId == selectedDriverId;
      final q = searchQuery.toLowerCase();
      final searchOk = q.isEmpty ||
          o.id.toLowerCase().contains(q) ||
          (o.notes?.toLowerCase().contains(q) ?? false) ||
          (o.driverName?.toLowerCase().contains(q) ?? false) ||
          (o.deliveryAddress?.toLowerCase().contains(q) ?? false);
      return driverOk && searchOk;
    }).toList();
  }

  int get totalCount =>
      columns.values.fold(0, (sum, list) => sum + list.length);

  bool get isToday {
    final now = DateTime.now();
    return viewDate.year == now.year &&
        viewDate.month == now.month &&
        viewDate.day == now.day;
  }

  @override
  List<Object?> get props =>
      [status, viewDate, columns, selectedDriverId, searchQuery, errorMessage];
}
