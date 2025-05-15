import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_x/core/supabase_config.dart';
import 'package:project_x/widgets/bottom_nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_x/pages/categories_page.dart';
import 'package:project_x/features/cart/providers/cart_provider.dart';
import 'package:project_x/theme/shopx_theme.dart';

// Provider for all products with pagination
final allProductsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, page) async {
  final pageSize = 10;
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false)
      .range(page * pageSize, (page + 1) * pageSize - 1);
  return List<Map<String, dynamic>>.from(response);
});

// Provider for featured products with pagination
final featuredProductsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false)
      .limit(10);
  return List<Map<String, dynamic>>.from(response);
});

// Provider for new arrivals with pagination
final newArrivalsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, page) async {
  final pageSize = 4;
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false)
      .range(page * pageSize, (page + 1) * pageSize - 1);
  return List<Map<String, dynamic>>.from(response);
});

// Provider for trending products with pagination
final trendingProductsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, page) async {
  final pageSize = 4;
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('views', ascending: false)
      .range(page * pageSize, (page + 1) * pageSize - 1);
  return List<Map<String, dynamic>>.from(response);
});

// Provider for products by category with pagination
final productsByCategoryProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String category, int page})>((ref, params) async {
  final pageSize = 4;
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .eq('category', params.category)
      .range(params.page * pageSize, (params.page + 1) * pageSize - 1);
  return List<Map<String, dynamic>>.from(response);
});

final bannersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Use featured products as banners, or just the latest products
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('created_at', ascending: false)
      .limit(5);
  return List<Map<String, dynamic>>.from(response)
      .where((product) => product['image_url'] != null && (product['image_url'] as String).isNotEmpty)
      .map((product) => {'image_url': product['image_url']})
      .toList();
});

final bestSellersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await SupabaseConfig.client
      .from('products')
      .select('*')
      .order('views', ascending: false)
      .limit(10);
  return List<Map<String, dynamic>>.from(response);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _newArrivalsPage = 0;
  final List<String> promoBanners = const [
    'assets/banner1.jpg',
    'assets/banner2.jpg',
    'assets/banner3.jpg',
  ];

  final List<Map<String, dynamic>> categories = const [
    {"name": "Electronics", "icon": Icons.devices},
    {"name": "Clothing", "icon": Icons.shopping_bag},
    {"name": "Home", "icon": Icons.home},
    {"name": "Beauty", "icon": Icons.face},
    {"name": "Toys", "icon": Icons.toys},
  ];

  @override
  Widget build(BuildContext context) {
    final featuredProducts = ref.watch(featuredProductsProvider);
    final bestSellers = ref.watch(bestSellersProvider);
    final newArrivals = ref.watch(newArrivalsProvider(_newArrivalsPage));

    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'ShopX',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: ShopXTheme.accentGold,
          ),
        ),
        elevation: 0,
        backgroundColor: ShopXTheme.primaryBackground,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: ShopXTheme.accentGold),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _newArrivalsPage = 0;
          });
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(newArrivalsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Center(
                  child: Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: ShopXTheme.accentGold,
                      fontFamily: 'Quintessential', // or any stylish font you have available
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildCategorySection(
                  context,
                  'Featured Products',
                  featuredProducts,
                  ref,
                  onLoadMore: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildCategorySection(
                  context,
                  'New Arrivals',
                  newArrivals,
                  ref,
                  onLoadMore: () {
                    setState(() {
                      _newArrivalsPage++;
                    });
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildCategorySection(
                  context,
                  'Best Sellers',
                  bestSellers,
                  ref,
                  onLoadMore: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/categories');
              break;
            case 2:
              Navigator.pushNamed(context, '/orders');
              break;
            case 3:
              Navigator.pushNamed(context, '/account');
              break;
          }
        },
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    AsyncValue<List<Map<String, dynamic>>> products,
    WidgetRef ref, {
    required VoidCallback onLoadMore,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ShopXTheme.textLight,
                fontSize: 20,
                letterSpacing: 0.2,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsPage(category: title),
                  ),
                );
              },
              child: Text(
                'See All',
                style: TextStyle(color: ShopXTheme.accentGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 270,
          child: products.when(
            loading: () => const Center(child: CircularProgressIndicator(color: ShopXTheme.accentGold)),
            error: (error, stack) => Center(child: Text('Error: $error', style: TextStyle(color: ShopXTheme.errorRed))),
            data: (products) => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length + 1,
              padding: const EdgeInsets.only(right: 8),
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == products.length) {
                  // Load More button styled as a card
                  return SizedBox(
                    width: 160,
                    child: Card(
                      elevation: 1,
                      color: ShopXTheme.surfaceDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onLoadMore,
                        child: Center(
                          child: Text(
                            'Load More',
                            style: TextStyle(
                              color: ShopXTheme.accentGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  width: 160,
                  child: _buildProductCard(context, products[index], ref),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product, WidgetRef ref) {
    final imageUrl = product['image_url'] ?? '';
    final productId = product['id']?.toString() ?? DateTime.now().toString();
    final uniqueHeroTag = 'product-image-$productId-${DateTime.now().millisecondsSinceEpoch}';
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: ShopXTheme.surfaceDark,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'] ?? 'Product Name', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(product['description'] ?? 'No description available', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/product', arguments: product);
                      },
                      child: const Text("View Details"),
                    ),
                  ],
                ),
              ),
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
              Hero(
                tag: uniqueHeroTag,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: ShopXTheme.surfaceDark,
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 36,
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
                    backgroundColor: ShopXTheme.accentGold,
                    foregroundColor: Colors.black,
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
      ),
    );
  }
} 