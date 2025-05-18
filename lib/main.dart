import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/products/screens/home_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/products/screens/product_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'pages/account_page.dart';
import 'pages/saved_addresses_page.dart';
import 'pages/categories_page.dart';
import 'pages/settings_page.dart';

// Theme & Providers
import 'theme/shopx_theme.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize Supabase using environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
        '/chat': (context) => const ChatScreen(),
        '/product': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProductDetailScreen(product: args);
        },
      },
    );
  }
}