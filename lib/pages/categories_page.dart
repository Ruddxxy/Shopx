import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_x/core/supabase_config.dart';
import 'package:project_x/widgets/bottom_nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_x/features/cart/providers/cart_provider.dart';
import '../theme/shopx_theme.dart';
import 'package:project_x/features/products/screens/product_screen.dart';

// Provider for products by category
final productsByCategoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('name');
  return List<Map<String, dynamic>>.from(response);
});

// Add these providers at the top, after productsByCategoryProvider
final featuredProductsFullProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

final newArrivalsFullProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

final bestSellersFullProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('views', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

final featuredProductsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false)
      .limit(10);
  return List<Map<String, dynamic>>.from(response);
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('categories')
      .select('*');
  return List<Map<String, dynamic>>.from(response);
});

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Categories
        // Already on categories
        break;
      case 2: // Chat
        Navigator.pushNamed(context, '/chat');
        break;
      case 3: // Orders
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 4: // Account
        Navigator.pushReplacementNamed(context, '/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredProductsAsync = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(color: ShopXTheme.accentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: ShopXTheme.primaryBackground,
        foregroundColor: ShopXTheme.textLight,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured Section
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Featured', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: ShopXTheme.accentGold)),
                const SizedBox(height: 12),
                featuredProductsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return Text('No featured products', style: TextStyle(color: ShopXTheme.textDark));
                    }
                    return SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final product = products[i];
                          return SizedBox(
                            width: 160,
                            child: Card(
                              elevation: 2,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: ShopXTheme.surfaceDark,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: product),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 160,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            color: ShopXTheme.surfaceDark,
                                            child: (product['image_url'] != null && (product['image_url'] as String).isNotEmpty)
                                                ? CachedNetworkImage(
                                                    imageUrl: product['image_url'],
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                    memCacheWidth: 320,
                                                    memCacheHeight: 320,
                                                    placeholder: (context, url) => const Center(
                                                      child: SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(strokeWidth: 2, color: ShopXTheme.accentGold),
                                                      ),
                                                    ),
                                                    errorWidget: (context, url, error) => const Center(
                                                      child: Icon(Icons.shopping_bag, size: 40, color: ShopXTheme.textDark),
                                                    ),
                                                  )
                                                : const Center(
                                                    child: Icon(Icons.shopping_bag, size: 40, color: ShopXTheme.textDark),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product['name'] ?? 'Product Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: ShopXTheme.textLight,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          color: ShopXTheme.accentGold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Failed to load featured products', style: TextStyle(color: ShopXTheme.errorRed)),
                ),
              ],
            ),
          ),
          // Categories Section
          categoriesAsync.when(
            data: (categories) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final category = categories[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryProductsPage(category: category['name']?.toString() ?? ''),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ShopXTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: category['image'] ?? '',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 120,
                              color: ShopXTheme.surfaceDark,
                              child: const Center(
                                child: CircularProgressIndicator(color: ShopXTheme.accentGold),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 120,
                              color: ShopXTheme.surfaceDark,
                              child: const Icon(Icons.image_not_supported, color: ShopXTheme.textDark),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['name']?.toString() ?? '',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: ShopXTheme.textLight),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category['description']?.toString() ?? '',
                                style: TextStyle(color: ShopXTheme.textDark, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load categories')),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CategoryProductsPage extends ConsumerWidget {
  final String category;
  const CategoryProductsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine which filter to use
    final AsyncValue<List<Map<String, dynamic>>> products;
    if (category == 'Featured Products') {
      products = ref.watch(featuredProductsFullProvider);
    } else if (category == 'New Arrivals') {
      products = ref.watch(newArrivalsFullProvider);
    } else if (category == 'Best Sellers') {
      products = ref.watch(bestSellersFullProvider);
    } else {
      products = ref.watch(productsByCategoryProvider(category));
    }

    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: Text(category, style: const TextStyle(color: ShopXTheme.accentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: ShopXTheme.primaryBackground,
        foregroundColor: ShopXTheme.textLight,
        elevation: 0.5,
      ),
      body: products.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: ShopXTheme.textDark),
                  const SizedBox(height: 16),
                  Text(
                    'No products found in this category',
                    style: TextStyle(color: ShopXTheme.textDark, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: ShopXTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product['image_url'] ?? 'https://via.placeholder.com/150',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 80,
                            width: 80,
                            color: ShopXTheme.surfaceDark,
                            child: const Center(
                              child: CircularProgressIndicator(color: ShopXTheme.accentGold),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 80,
                            width: 80,
                            color: ShopXTheme.surfaceDark,
                            child: const Icon(Icons.image_not_supported, color: ShopXTheme.textDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'Product Name',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: ShopXTheme.textLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              color: ShopXTheme.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['description'] ?? 'No description available',
                            style: TextStyle(
                              color: ShopXTheme.textDark,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await ref.read(cartProvider.notifier).addToCart(product);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Added to cart'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    action: SnackBarAction(
                                      label: 'View Cart',
                                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Add to Cart'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: ShopXTheme.accentGold)),
        error: (error, stack) => Center(
          child: Text(
            'Error loading products: $error',
            style: const TextStyle(color: ShopXTheme.textDark),
          ),
        ),
      ),
    );
  }
}
