import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../customers_data_source.dart';
import '../../model/customer.dart';
import '../../model/customer_address.dart';
import '../../../../orders/data/model/order_model.dart';

class SupabaseCustomersDataSource implements CustomersDataSource {
  static const _tag = 'CustomersDataSource';

  final SupabaseClient _supabase;
  SupabaseCustomersDataSource(this._supabase);

  @override
  Future<List<Customer>> getCustomers({String? search}) async {
    AppLogger.net(_tag, 'getCustomers', 'search=$search');
    try {
      var query = _supabase.from('customer_profiles').select(
        'id, name, email, phone, created_at, loyalty_points, referral_code, is_blocked, internal_notes, total_spent',
      );

      if (search != null && search.isNotEmpty) {
        query = query.or(
          'name.ilike.%$search%,email.ilike.%$search%,phone.ilike.%$search%',
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
        return Customer.fromJson(json);
      }).toList();

      AppLogger.i(_tag, 'getCustomers → ${result.length} customers with stats');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getCustomers failed', e, st);
      rethrow;
    }
  }

  @override
  Future<Customer> getCustomerById(String customerId) async {
    AppLogger.net(_tag, 'getCustomerById', 'id=$customerId');
    try {
      final row = await _supabase
          .from('customer_profiles')
          .select(
            'id, name, email, phone, created_at, loyalty_points, referral_code, is_blocked, internal_notes, total_spent',
          )
          .eq('id', customerId)
          .single();

      final json = Map<String, dynamic>.from(row);

      final statsRaw = await _supabase
          .from('orders')
          .select('customer_id, total_price')
          .eq('customer_id', customerId);

      int count = 0;
      for (final _ in statsRaw) {
        count++;
      }
      json['order_count'] = count;

      final customer = Customer.fromJson(json);
      AppLogger.i(_tag, 'getCustomerById → ${customer.displayName}');
      return customer;
    } catch (e, st) {
      AppLogger.e(_tag, 'getCustomerById failed', e, st);
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    AppLogger.net(_tag, 'getCustomerOrders', 'customerId=$customerId');
    try {
      final rows = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .limit(50);

      final result = (rows as List)
          .map((r) => OrderModel.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getCustomerOrders → ${result.length} orders');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getCustomerOrders failed', e, st);
      rethrow;
    }
  }

  @override
  Future<List<CustomerAddress>> getCustomerAddresses(String customerId) async {
    AppLogger.net(_tag, 'getCustomerAddresses', 'customerId=$customerId');
    try {
      final rows = await _supabase
          .from('customer_addresses')
          .select('id, customer_id, label, street, building, floor, apartment, landmark, is_default')
          .eq('customer_id', customerId)
          .order('is_default', ascending: false);

      final result = (rows as List)
          .map((r) => CustomerAddress.fromJson(r as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getCustomerAddresses → ${result.length} addresses');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, 'getCustomerAddresses failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> updateInternalNotes(String customerId, String notes) async {
    AppLogger.net(_tag, 'updateInternalNotes', 'customerId=$customerId');
    try {
      await _supabase
          .from('customer_profiles')
          .update({'internal_notes': notes})
          .eq('id', customerId);
      AppLogger.i(_tag, 'updateInternalNotes success');
    } catch (e, st) {
      AppLogger.e(_tag, 'updateInternalNotes failed', e, st);
      rethrow;
    }
  }

  @override
  Future<void> adjustLoyaltyPoints(
    String customerId,
    int delta,
    String description,
  ) async {
    AppLogger.net(_tag, 'adjustLoyaltyPoints', 'customerId=$customerId delta=$delta');
    try {
      await _supabase.from('loyalty_transactions').insert({
        'customer_id': customerId,
        'points':      delta,
        'type':        delta > 0 ? 'manual' : 'redeem',
        'description': description,
      });

      await _supabase.rpc('increment_loyalty_points', params: {
        'p_customer_id': customerId,
        'p_delta':       delta,
      }).onError((_, __) async {
        // Fallback: read current + update
        final row = await _supabase
            .from('customer_profiles')
            .select('loyalty_points')
            .eq('id', customerId)
            .single();
        final current = (row['loyalty_points'] as int?) ?? 0;
        await _supabase
            .from('customer_profiles')
            .update({'loyalty_points': current + delta})
            .eq('id', customerId);
      });

      AppLogger.i(_tag, 'adjustLoyaltyPoints success');
    } catch (e, st) {
      AppLogger.e(_tag, 'adjustLoyaltyPoints failed', e, st);
      rethrow;
    }
  }

  @override
  Future<CustomerAddress> createCustomerAddress({
    required String customerId,
    String? label,
    required String street,
    String? building,
    String? floor,
    String? apartment,
    String? landmark,
    bool isDefault = false,
  }) async {
    AppLogger.net(_tag, 'createCustomerAddress', 'customerId=$customerId label=$label');
    try {
      final row = await _supabase
          .from('customer_addresses')
          .insert({
            'customer_id': customerId,
            if (label != null && label.isNotEmpty) 'label': label,
            'street': street,
            if (building != null && building.isNotEmpty) 'building': building,
            if (floor != null && floor.isNotEmpty) 'floor': floor,
            if (apartment != null && apartment.isNotEmpty) 'apartment': apartment,
            if (landmark != null && landmark.isNotEmpty) 'landmark': landmark,
            'is_default': isDefault,
          })
          .select('id, customer_id, label, street, building, floor, apartment, landmark, is_default')
          .single();
      final address = CustomerAddress.fromJson(Map<String, dynamic>.from(row));
      AppLogger.i(_tag, 'createCustomerAddress → id=${address.id}');
      return address;
    } catch (e, st) {
      AppLogger.e(_tag, 'createCustomerAddress failed', e, st);
      rethrow;
    }
  }

  @override
  Future<Customer> createCustomer({
    required String name,
    String? phone,
    String? email,
  }) async {
    AppLogger.net(_tag, 'createCustomer', 'name=$name phone=$phone email=$email');
    try {
      final row = await _supabase
          .from('customer_profiles')
          .insert({
            'name':           name,
            if (phone != null) 'phone': phone,
            if (email != null) 'email': email,
            'loyalty_points': 0,
          })
          .select(
            'id, name, email, phone, created_at, loyalty_points, referral_code, is_blocked, internal_notes, total_spent',
          )
          .single();

      final json = Map<String, dynamic>.from(row);
      json['order_count'] = 0;
      final customer = Customer.fromJson(json);
      AppLogger.i(_tag, 'createCustomer → id=${customer.id}');
      return customer;
    } catch (e, st) {
      AppLogger.e(_tag, 'createCustomer failed', e, st);
      rethrow;
    }
  }
}

class _Stats {
  int count = 0;
  double total = 0;
}
