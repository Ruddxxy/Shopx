import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/shopx_theme.dart';

final darkModeProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: ShopXTheme.accentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: ShopXTheme.primaryBackground,
        foregroundColor: ShopXTheme.textLight,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Notifications',
            items: [
              _SettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Colors.indigo[400],
                ),
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: Colors.indigo[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Appearance',
            items: [
              _SettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(darkModeProvider.notifier).state = value;
                    // Optionally, persist the theme preference here
                  },
                  activeColor: ShopXTheme.accentGold,
                ),
              ),
              _SettingsItem(
                icon: Icons.language_outlined,
                title: 'Language',
                trailing: const Text('English', style: TextStyle(color: Colors.grey)),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Privacy & Security',
            items: [
              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.security_outlined,
                title: 'Two-Factor Authentication',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: Colors.indigo[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'About',
            items: [
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'App Version',
                trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
              ),
              _SettingsItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.indigo[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ShopXTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo[400]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
