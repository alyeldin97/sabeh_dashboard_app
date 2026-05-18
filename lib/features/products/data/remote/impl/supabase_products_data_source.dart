import 'package:supabase_flutter/supabase_flutter.dart';
import '../products_data_source.dart';
import '../../model/product.dart';

class SupabaseProductsDataSource implements ProductsDataSource {
  final SupabaseClient _client;
  SupabaseProductsDataSource(this._client);

  static const _select = '''
    *,
    product_branches(branch_id),
    product_categories(category_id),
    product_options(
      id, product_id, name, sort_order,
      product_option_values(id, option_id, value, sort_order)
    ),
    product_variants(
      id, product_id, price, compare_at_price, is_active, sort_order,
      variant_option_values(option_value_id),
      variant_inventory(branch_id, quantity)
    ),
    product_inventory(branch_id, quantity)
  ''';

  @override
  Future<List<Product>> getProducts({String? branchId, String? categoryId}) async {
    if (branchId != null && categoryId != null) {
      final rows = await _client
          .from('products')
          .select('$_select, product_categories!inner(category_id)')
          .eq('product_branches.branch_id', branchId)
          .eq('product_categories.category_id', categoryId)
          .eq('is_active', true)
          .order('sort_order')
          .order('name');
      return (rows as List).map((r) => Product.fromJson(r as Map<String, dynamic>)).toList();
    }

    if (branchId != null) {
      final rows = await _client
          .from('products')
          .select('*, product_branches!inner(branch_id), product_categories(category_id), product_options(id, product_id, name, sort_order, product_option_values(id, option_id, value, sort_order)), product_variants(id, product_id, price, compare_at_price, is_active, sort_order, variant_option_values(option_value_id), variant_inventory(branch_id, quantity)), product_inventory(branch_id, quantity)')
          .eq('product_branches.branch_id', branchId)
          .order('sort_order')
          .order('name');
      return (rows as List).map((r) => Product.fromJson(r as Map<String, dynamic>)).toList();
    }

    var q = _client.from('products').select(_select);
    if (categoryId != null) {
      q = q.eq('product_categories.category_id', categoryId);
    }
    final rows = await q.order('sort_order').order('name');
    return (rows as List).map((r) => Product.fromJson(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product> createProduct({
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
  }) async {
    final row = await _client.from('products').insert(fields).select('id').single();
    final id = row['id'] as String;
    await _saveRelations(
      productId: id,
      branchIds: branchIds,
      categoryIds: categoryIds,
      options: options,
      variants: variants,
      productInventory: productInventory,
    );
    return _fetchProduct(id);
  }

  @override
  Future<Product> updateProduct({
    required String id,
    required Map<String, dynamic> fields,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
  }) async {
    await _client.from('products').update(fields).eq('id', id);

    // Delete and recreate all relations
    await Future.wait([
      _client.from('product_branches').delete().eq('product_id', id),
      _client.from('product_categories').delete().eq('product_id', id),
      _client.from('product_options').delete().eq('product_id', id),
      _client.from('product_inventory').delete().eq('product_id', id),
    ]);

    await _saveRelations(
      productId: id,
      branchIds: branchIds,
      categoryIds: categoryIds,
      options: options,
      variants: variants,
      productInventory: productInventory,
    );
    return _fetchProduct(id);
  }

  Future<void> _saveRelations({
    required String productId,
    required List<String> branchIds,
    required List<String> categoryIds,
    required List<Map<String, dynamic>> options,
    required List<Map<String, dynamic>> variants,
    required Map<String, int> productInventory,
  }) async {
    // Branches
    if (branchIds.isNotEmpty) {
      await _client.from('product_branches').insert(
        branchIds.map((b) => {'product_id': productId, 'branch_id': b}).toList(),
      );
    }

    // Categories
    if (categoryIds.isNotEmpty) {
      await _client.from('product_categories').insert(
        categoryIds.map((c) => {'product_id': productId, 'category_id': c}).toList(),
      );
    }

    // Options and values → collect value ID maps for variants
    // options: [{name, values: [{value}]}]
    // variants: [{valueIndices: [[optIdx, valIdx]], price, compareAtPrice, isActive, inventory}]
    if (options.isNotEmpty) {
      // optValueIdMatrix[optIdx][valIdx] = DB id of that option value
      final List<List<String>> optValueIdMatrix = [];

      for (var optIdx = 0; optIdx < options.length; optIdx++) {
        final opt = options[optIdx];
        final optRow = await _client.from('product_options').insert({
          'product_id': productId,
          'name':       opt['name'] as String,
          'sort_order': optIdx,
        }).select('id').single();
        final optId = optRow['id'] as String;

        final vals = (opt['values'] as List<dynamic>).cast<String>();
        final List<String> valIds = [];
        for (var valIdx = 0; valIdx < vals.length; valIdx++) {
          final valRow = await _client.from('product_option_values').insert({
            'option_id':  optId,
            'value':      vals[valIdx],
            'sort_order': valIdx,
          }).select('id').single();
          valIds.add(valRow['id'] as String);
        }
        optValueIdMatrix.add(valIds);
      }

      // Variants: [{valueIndices: [valIdx per opt], price, compareAtPrice, isActive, inventory}]
      for (var varIdx = 0; varIdx < variants.length; varIdx++) {
        final v = variants[varIdx];
        final valueIndices = (v['valueIndices'] as List<dynamic>).cast<int>();
        final varRow = await _client.from('product_variants').insert({
          'product_id':       productId,
          'price':            v['price'] as double,
          'compare_at_price': v['compareAtPrice'] as double?,
          'is_active':        v['isActive'] as bool? ?? true,
          'sort_order':       varIdx,
        }).select('id').single();
        final varId = varRow['id'] as String;

        // Link option values to variant
        final links = <Map<String, dynamic>>[];
        for (var optIdx = 0; optIdx < valueIndices.length; optIdx++) {
          final valIdx = valueIndices[optIdx];
          if (optIdx < optValueIdMatrix.length && valIdx < optValueIdMatrix[optIdx].length) {
            links.add({'variant_id': varId, 'option_value_id': optValueIdMatrix[optIdx][valIdx]});
          }
        }
        if (links.isNotEmpty) {
          await _client.from('variant_option_values').insert(links);
        }

        // Variant inventory
        final inventory = (v['inventory'] as Map<dynamic, dynamic>?) ?? {};
        if (inventory.isNotEmpty) {
          await _client.from('variant_inventory').insert(
            inventory.entries
                .where((e) => (e.value as int) >= 0)
                .map((e) => {'variant_id': varId, 'branch_id': e.key as String, 'quantity': e.value as int})
                .toList(),
          );
        }
      }
    }

    // Product-level inventory (no variants)
    if (options.isEmpty && productInventory.isNotEmpty) {
      await _client.from('product_inventory').insert(
        productInventory.entries
            .where((e) => e.value >= 0)
            .map((e) => {'product_id': productId, 'branch_id': e.key, 'quantity': e.value})
            .toList(),
      );
    }
  }

  Future<Product> _fetchProduct(String id) async {
    final row = await _client.from('products').select(_select).eq('id', id).single();
    return Product.fromJson(row);
  }

  @override
  Future<void> deleteProduct({required String id}) async {
    await _client.from('products').update({'is_active': false}).eq('id', id);
  }
}
