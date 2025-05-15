// The contents of the old home_screen.dart will be moved here for product display only. 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_x/features/cart/screens/cart_screen.dart';
import '../../cart/providers/cart_provider.dart';
import 'package:project_x/theme/shopx_theme.dart';
import 'package:project_x/core/supabase_config.dart';

final productsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Products', style: TextStyle(color: ShopXTheme.accentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: ShopXTheme.primaryBackground,
        foregroundColor: ShopXTheme.textLight,
        elevation: 0.5,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: ShopXTheme.accentGold),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Consumer(
                  builder: (context, ref, _) {
                    final cart = ref.watch(cartProvider);
                    if (cart.isEmpty) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cart.length.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: products.when(
        data: (products) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: ShopXTheme.surfaceDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: CachedNetworkImage(
                      imageUrl: product['image_thumbnail_url'] ?? product['image_original_url'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: ShopXTheme.surfaceDark,
                        child: const Center(
                          child: CircularProgressIndicator(color: ShopXTheme.accentGold),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: ShopXTheme.surfaceDark,
                        child: const Icon(Icons.image_not_supported, color: ShopXTheme.textDark),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product['name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ShopXTheme.textLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              color: ShopXTheme.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: ShopXTheme.accentGold)),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: TextStyle(color: ShopXTheme.errorRed)),
        ),
      ),
    );
  }
}

// Product detail screen
class ProductDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: ShopXTheme.primaryBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: product['image_large_url'] ?? product['image_original_url'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: ShopXTheme.surfaceDark,
                  child: const Center(
                    child: CircularProgressIndicator(color: ShopXTheme.accentGold),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: ShopXTheme.surfaceDark,
                  child: const Icon(Icons.image_not_supported, color: ShopXTheme.textDark),
                ),
              ),
            ),
          ),
          // ... rest of the product detail screen ...
        ],
      ),
    );
  }
} 