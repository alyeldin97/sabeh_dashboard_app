import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../customers_data_source.dart';
import '../../model/customer.dart';

class SupabaseCustomersDataSource implements CustomersDataSource {
  static const _tag = 'CustomersDataSource';

  final SupabaseClient _supabase;
  SupabaseCustomersDataSource(this._supabase);

  @override
  Future<List<Customer>> getCustomers({String? search}) async {
    AppLogger.net(_tag, 'getCustomers', 'search=$search');
    try {
      var query = _supabase
          .from('profiles')
          .select('id, full_name, email, phone, created_at');

      if (search != null && search.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$search%,email.ilike.%$search%,phone.ilike.%$search%',
        );
      }

      final List<dynamic> rows =
          await query.order('created_at', ascending: false);
      AppLogger.d(_tag, 'getCustomers → ${rows.length} profiles fetched');

      final List<dynamic> statsRaw =
          await _supabase.from('orders').select('customer_id, total_price');
      AppLogger.d(_tag, 'getCustomers → ${statsRaw.length} order rows for stats');

      final Map<String, _Stats> statsMap = {};
      for (final row in statsRaw) {
        final cid = row['customer_id'] as String?;
        if (cid == null) continue;
        final price = (row['total_price'] as num?)?.toDouble() ?? 0;
        final s = statsMap[cid] ?? _Stats();
        s.count++;
        s.total += price;
        statsMap[cid] = s;
      }

      final result = rows.map((r) {
        final json = Map<String, dynamic>.from(r as Map);
        final stats = statsMap[json['id'] as String?];
        json['order_count'] = stats?.count ?? 0;
        json['total_spent'] = stats?.total ?? 0.0;
        return Customer.fromJson(json);
      }).toList();

      AppLogger.i(_tag, 'getCustomers → ${result.length} customers with stats');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getCustomers failed', e, st);
      rethrow;
    }
  }
}

class _Stats {
  int count = 0;
  double total = 0;
}
