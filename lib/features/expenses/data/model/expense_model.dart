import 'package:equatable/equatable.dart';

enum ExpenseType {
  salaries,
  overtime,
  fruitSuppliers,
  nutSuppliers,
  candySuppliers,
  dairySuppliers,
  readyToCook,
  rawMaterials,
  assets,
  bills,
  miscellaneous,
  packaging,
  customerCompensation,
  indriveDelivery;

  String get dbValue {
    switch (this) {
      case ExpenseType.salaries:             return 'salaries';
      case ExpenseType.overtime:             return 'overtime';
      case ExpenseType.fruitSuppliers:       return 'fruit_suppliers';
      case ExpenseType.nutSuppliers:         return 'nut_suppliers';
      case ExpenseType.candySuppliers:       return 'candy_suppliers';
      case ExpenseType.dairySuppliers:       return 'dairy_suppliers';
      case ExpenseType.readyToCook:          return 'ready_to_cook';
      case ExpenseType.rawMaterials:         return 'raw_materials';
      case ExpenseType.assets:               return 'assets';
      case ExpenseType.bills:                return 'bills';
      case ExpenseType.miscellaneous:        return 'miscellaneous';
      case ExpenseType.packaging:            return 'packaging';
      case ExpenseType.customerCompensation: return 'customer_compensation';
      case ExpenseType.indriveDelivery:      return 'indrive_delivery';
    }
  }

  String get labelAr {
    switch (this) {
      case ExpenseType.salaries:             return 'سلف و مرتبات';
      case ExpenseType.overtime:             return 'اوفر تايم';
      case ExpenseType.fruitSuppliers:       return 'موردين فاكهة';
      case ExpenseType.nutSuppliers:         return 'موردين مكسرات';
      case ExpenseType.candySuppliers:       return 'موردين كاندي';
      case ExpenseType.dairySuppliers:       return 'موردين البان';
      case ExpenseType.readyToCook:          return 'ريدي تو كوك';
      case ExpenseType.rawMaterials:         return 'خامات';
      case ExpenseType.assets:               return 'Assets';
      case ExpenseType.bills:                return 'فواتير';
      case ExpenseType.miscellaneous:        return 'نثريات';
      case ExpenseType.packaging:            return 'باكدج';
      case ExpenseType.customerCompensation: return 'تعويض العملا';
      case ExpenseType.indriveDelivery:      return 'اندرايف دلفري';
    }
  }

  String get labelEn {
    switch (this) {
      case ExpenseType.salaries:             return 'Salaries & Advances';
      case ExpenseType.overtime:             return 'Overtime';
      case ExpenseType.fruitSuppliers:       return 'Fruit Suppliers';
      case ExpenseType.nutSuppliers:         return 'Nut Suppliers';
      case ExpenseType.candySuppliers:       return 'Candy Suppliers';
      case ExpenseType.dairySuppliers:       return 'Dairy Suppliers';
      case ExpenseType.readyToCook:          return 'Ready to Cook';
      case ExpenseType.rawMaterials:         return 'Raw Materials';
      case ExpenseType.assets:               return 'Assets';
      case ExpenseType.bills:                return 'Bills';
      case ExpenseType.miscellaneous:        return 'Miscellaneous';
      case ExpenseType.packaging:            return 'Packaging';
      case ExpenseType.customerCompensation: return 'Customer Compensation';
      case ExpenseType.indriveDelivery:      return 'InDrive Delivery';
    }
  }

  static ExpenseType fromDb(String? v) {
    switch (v) {
      case 'salaries':              return ExpenseType.salaries;
      case 'overtime':              return ExpenseType.overtime;
      case 'fruit_suppliers':       return ExpenseType.fruitSuppliers;
      case 'nut_suppliers':         return ExpenseType.nutSuppliers;
      case 'candy_suppliers':       return ExpenseType.candySuppliers;
      case 'dairy_suppliers':       return ExpenseType.dairySuppliers;
      case 'ready_to_cook':         return ExpenseType.readyToCook;
      case 'raw_materials':         return ExpenseType.rawMaterials;
      case 'assets':                return ExpenseType.assets;
      case 'bills':                 return ExpenseType.bills;
      case 'packaging':             return ExpenseType.packaging;
      case 'customer_compensation': return ExpenseType.customerCompensation;
      case 'indrive_delivery':      return ExpenseType.indriveDelivery;
      default:                      return ExpenseType.miscellaneous;
    }
  }
}

class ExpenseModel extends Equatable {
  final String id;
  final String name;
  final double value;
  final DateTime date;
  final String? branchId;
  final DateTime? createdAt;
  final ExpenseType type;

  const ExpenseModel({
    required this.id,
    required this.name,
    required this.value,
    required this.date,
    this.branchId,
    this.createdAt,
    this.type = ExpenseType.miscellaneous,
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
        type: ExpenseType.fromDb(j['type'] as String?),
      );

  Map<String, dynamic> toInsertJson({String? branchId}) => {
        'name':      name,
        'value':     value,
        'date':      _fmtDate(date),
        'type':      type.dbValue,
        if (branchId != null) 'branch_id': branchId,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name':  name,
        'value': value,
        'date':  _fmtDate(date),
        'type':  type.dbValue,
      };

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [id, name, value, date, branchId, type];
}
