import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/screens/signup_screen.dart';
import '../theme/shopx_theme.dart';

final languageProvider = StateProvider<String>((ref) => 'English');

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ['English', 'Español', 'Français', 'Deutsch', 'हिन्दी', '中文'];
    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Language Selection', style: TextStyle(color: ShopXTheme.accentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: ShopXTheme.primaryBackground,
        foregroundColor: ShopXTheme.textLight,
        elevation: 0.5,
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            title: Text(lang, style: TextStyle(color: ShopXTheme.textLight)),
            trailing: ref.watch(languageProvider) == lang
                ? const Icon(Icons.check, color: Colors.indigo)
                : null,
            onTap: () {
              ref.read(languageProvider.notifier).state = lang;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
