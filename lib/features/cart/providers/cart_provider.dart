import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_x/core/supabase_config.dart';
import 'package:logging/logging.dart';

final _logger = Logger('CartProvider');

final cartProvider = StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>((ref) {
  return CartNotifier()..loadCart();
});

class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  Future<void> loadCart() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    try {
      final cartItems = await SupabaseConfig.client
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id);

      state = List<Map<String, dynamic>>.from(cartItems);
    } catch (e) {
      _logger.severe('Error loading cart', e);
      state = [];
    }
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    try {
      // Check if product already in cart
      final existingItems = await SupabaseConfig.client
          .from('cart_items')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', product['id']);

      if (existingItems.isNotEmpty) {
        // Update quantity
        await SupabaseConfig.client
            .from('cart_items')
            .update({'quantity': existingItems[0]['quantity'] + 1})
            .eq('id', existingItems[0]['id']);
      } else {
        // Add new item
        await SupabaseConfig.client.from('cart_items').insert({
          'user_id': user.id,
          'product_id': product['id'],
          'quantity': 1,
        });
      }

      await loadCart(); // Reload cart after changes
    } catch (e) {
      _logger.severe('Error adding to cart', e);
    }
  }

  Future<void> removeFromCart(String productId) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    try {
      await SupabaseConfig.client
          .from('cart_items')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', productId);

      await loadCart(); // Reload cart after changes
    } catch (e) {
      _logger.severe('Error removing from cart', e);
    }
  }

  Future<void> incrementQuantity(String productId) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    try {
      final item = await SupabaseConfig.client
          .from('cart_items')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .single();

        await SupabaseConfig.client
            .from('cart_items')
            .update({'quantity': item['quantity'] + 1})
            .eq('id', item['id']);

        await loadCart(); // Reload cart after changes
    } catch (e) {
      _logger.severe('Error incrementing quantity', e);
    }
  }

  Future<void> decrementQuantity(String productId) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    try {
      final item = await SupabaseConfig.client
          .from('cart_items')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .single();

        if (item['quantity'] > 1) {
          await SupabaseConfig.client
              .from('cart_items')
              .update({'quantity': item['quantity'] - 1})
              .eq('id', item['id']);
        } else {
          await removeFromCart(productId);
        }

        await loadCart(); // Reload cart after changes
    } catch (e) {
      _logger.severe('Error decrementing quantity', e);
    }
  }

  Future<void> clearCart() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    try {
      await SupabaseConfig.client
          .from('cart_items')
          .delete()
          .eq('user_id', user.id);

      state = [];
    } catch (e) {
      _logger.severe('Error clearing cart', e);
    }
  }

  double getTotal() {
    return state.fold(0.0, (sum, item) {
      final products = item['products'];
      final price = (products is Map && products['price'] is num) ? products['price'] as num : 0.0;
      final quantity = (item['quantity'] is num) ? item['quantity'] as num : 1;
      return sum + (price.toDouble() * quantity.toDouble());
    });
  }
}
