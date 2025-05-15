import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_x/core/supabase_config.dart';
import 'package:project_x/features/orders/models/order.dart';

final orderControllerProvider = Provider((ref) => OrderController());

class OrderController {
  final _supabase = SupabaseConfig.client;

  Stream<List<Order>> getOrders() async* {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final orders = (response as List).map((json) => Order.fromJson(json)).toList();
      yield orders;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> createOrder({
    required String userId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
  }) async {
    try {
      await _supabase.rpc('create_order', params: {
        'p_user_id': userId,
        'p_total_amount': totalAmount,
        'p_items': items,
        'p_shipping_address': shippingAddress,
      });
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }
} 