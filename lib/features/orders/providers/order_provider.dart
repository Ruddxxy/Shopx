import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_x/core/supabase_config.dart';

// Provider for order history
final orderHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return [];

  final orders = await SupabaseConfig.client
      .from('orders')
      .select('*, order_items(*)')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(orders);
});

// Provider for order details
final orderDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final order = await SupabaseConfig.client
      .from('orders')
      .select('*, order_items(*, products(*))')
      .eq('id', orderId)
      .single();

  return order;
});

// Provider for creating new orders
final createOrderProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, orderData) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  // Start a transaction
  await SupabaseConfig.client.rpc('create_order', params: {
    'p_user_id': user.id,
    'p_total': orderData['total'],
    'p_items': orderData['items'],
  });
});