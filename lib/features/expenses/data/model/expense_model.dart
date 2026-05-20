import 'package:equatable/equatable.dart';

class ExpenseModel extends Equatable {
  final String id;
  final String name;
  final double value;
  final DateTime date;
  final String? branchId;
  final DateTime? createdAt;

  const ExpenseModel({
    required this.id,
    required this.name,
    required this.value,
    required this.date,
    this.branchId,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> j) => ExpenseModel(
        id:        j['id'] as String,
        name:      j['name'] as String,
        value:     (j['value'] as num).toDouble(),
        date:      DateTime.parse(j['date'] as String),
        branchId:  j['branch_id'] as String?,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toInsertJson({String? branchId}) => {
        'name':      name,
        'value':     value,
        'date':      _fmtDate(date),
        if (branchId != null) 'branch_id': branchId,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name':  name,
        'value': value,
        'date':  _fmtDate(date),
      };

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [id, name, value, date, branchId];
}
