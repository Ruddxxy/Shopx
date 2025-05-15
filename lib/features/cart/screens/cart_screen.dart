import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_x/features/orders/screens/order_history_screen.dart';
import '../providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_x/features/orders/providers/order_provider.dart';
import 'package:project_x/theme/shopx_theme.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _shippingAddressController = TextEditingController();
  String? _addressError;

  @override
  void dispose() {
    _shippingAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).getTotal();

    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: ShopXTheme.textLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: ShopXTheme.primaryBackground,
        elevation: 0,
      ),
      body: cart.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 16,
                  color: ShopXTheme.textDark,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: ShopXTheme.surfaceDark,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item['products']['image_thumbnail_url'] ?? item['products']['image_original_url'] ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 60,
                                    height: 60,
                                    color: ShopXTheme.surfaceDark,
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: ShopXTheme.accentGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 60,
                                    height: 60,
                                    color: ShopXTheme.surfaceDark,
                                    child: Icon(Icons.image_not_supported, color: ShopXTheme.textDark),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['products']['name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: ShopXTheme.textLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item['products']['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        color: ShopXTheme.accentGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline, size: 20, color: ShopXTheme.accentGold),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => ref.read(cartProvider.notifier).decrementQuantity(item['products']['id']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${item['quantity'] ?? 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ShopXTheme.textLight,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline, size: 20, color: ShopXTheme.accentGold),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => ref.read(cartProvider.notifier).incrementQuantity(item['products']['id']),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: ShopXTheme.errorRed, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => ref.read(cartProvider.notifier).removeFromCart(item['products']['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ShopXTheme.surfaceDark,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShopXTheme.textLight,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShopXTheme.accentGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Shipping Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ShopXTheme.accentGold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _shippingAddressController,
                        style: TextStyle(color: ShopXTheme.textLight),
                        decoration: InputDecoration(
                          labelText: 'Enter your shipping address',
                          labelStyle: TextStyle(color: ShopXTheme.textDark),
                          hintText: 'e.g. 123 Main St, City, Country',
                          hintStyle: TextStyle(color: ShopXTheme.textDark.withValues(alpha: 0.5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: ShopXTheme.textDark.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: ShopXTheme.textDark.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: ShopXTheme.accentGold, width: 2),
                          ),
                          errorText: _addressError,
                          errorStyle: TextStyle(color: ShopXTheme.errorRed),
                          filled: true,
                          fillColor: ShopXTheme.primaryBackground,
                        ),
                        minLines: 1,
                        maxLines: 2,
                        autofillHints: const [AutofillHints.fullStreetAddress],
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => checkout(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ShopXTheme.accentGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> checkout(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider);
    final shippingAddress = _shippingAddressController.text.trim();

    setState(() {
      _addressError = null;
    });

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    if (shippingAddress.isEmpty) {
      setState(() {
        _addressError = 'Please enter a shipping address';
      });
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare order data
      final orderData = {
        'total': ref.read(cartProvider.notifier).getTotal(),
        'items': cart.map((item) => {
          'product_id': item['products']['id'],
          'quantity': item['quantity'],
          'price': (item['products']['price'] ?? 0.0) as num,
        }).toList(),
        'shipping_address': shippingAddress,
      };

      // Create order using the provider
      await ref.read(createOrderProvider(orderData).future);

      // Clear cart after successful order
      await ref.read(cartProvider.notifier).clearCart();

      // Dismiss loading indicator
      if (!context.mounted) return;
      Navigator.pop(context); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
      );
    } catch (e) {
      // Dismiss loading indicator
      if (!context.mounted) return;
      Navigator.pop(context); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
