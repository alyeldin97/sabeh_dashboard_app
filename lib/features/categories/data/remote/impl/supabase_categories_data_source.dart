import 'package:supabase_flutter/supabase_flutter.dart';
import '../categories_data_source.dart';
import '../../model/category.dart';

class SupabaseCategoriesDataSource implements CategoriesDataSource {
  final SupabaseClient _client;
  SupabaseCategoriesDataSource(this._client);

  static const _select = '*, category_branches(branch_id)';

  @override
  Future<List<Category>> getCategories({String? branchId}) async {
    if (branchId != null) {
      final rows = await _client
          .from('categories')
          .select('*, category_branches!inner(branch_id)')
          .eq('category_branches.branch_id', branchId)
          .order('sort_order')
          .order('name');
      return (rows as List).map((r) => Category.fromJson(r as Map<String, dynamic>)).toList();
    }
    final rows = await _client
        .from('categories')
        .select(_select)
        .order('sort_order')
        .order('name');
    return (rows as List).map((r) => Category.fromJson(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> data, List<String> branchIds) async {
    final row = await _client.from('categories').insert(data).select('id').single();
    final id = row['id'] as String;
    if (branchIds.isNotEmpty) {
      await _client.from('category_branches').insert(
        branchIds.map((bId) => {'category_id': id, 'branch_id': bId}).toList(),
      );
    }
    final updated = await _client.from('categories').select(_select).eq('id', id).single();
    return Category.fromJson(updated);
  }

  @override
  Future<Category> updateCategory({required String id, required Map<String, dynamic> data, required List<String> branchIds}) async {
    await _client.from('categories').update(data).eq('id', id);
    await _client.from('category_branches').delete().eq('category_id', id);
    if (branchIds.isNotEmpty) {
      await _client.from('category_branches').insert(
        branchIds.map((bId) => {'category_id': id, 'branch_id': bId}).toList(),
      );
    }
    final updated = await _client.from('categories').select(_select).eq('id', id).single();
    return Category.fromJson(updated);
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    await _client.from('categories').update({'is_active': false}).eq('id', id);
  }

  @override
  Future<void> updateSortOrders(List<({String id, int sortOrder})> updates) async {
    await Future.wait(
      updates.map((u) => _client.from('categories').update({'sort_order': u.sortOrder}).eq('id', u.id)),
    );
  }
}
