import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_x/core/config.dart';
import 'screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/products/screens/home_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'pages/account_page.dart';
import 'pages/saved_addresses_page.dart';
import 'pages/categories_page.dart';
import 'theme/shopx_theme.dart';
import 'features/products/screens/product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/auth_service.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );

  // Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    return MaterialApp(
      title: 'ShopX',
      theme: isDarkMode ? ShopXTheme.darkTheme : ShopXTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/orders': (context) => const OrderHistoryScreen(),
        '/cart': (context) => const CartScreen(),
        '/account': (context) => const AccountPage(),
        '/addresses': (context) => const SavedAddressesPage(),
        '/categories': (context) => const CategoriesPage(),
        '/settings': (context) => const SettingsPage(),
        '/product': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProductDetailScreen(product: args);
        },
      },
    );
  }
}