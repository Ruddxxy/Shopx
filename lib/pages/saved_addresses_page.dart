import 'package:flutter/material.dart';
import '../theme/shopx_theme.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  final List<String> addresses = [
    '123 Main St, Springfield',
    '456 Elm St, Shelbyville',
  ];

  void _addAddress() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => addresses.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopXTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Saved Addresses', style: TextStyle(color: ShopXTheme.accentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: ShopXTheme.primaryBackground,
        foregroundColor: ShopXTheme.textLight,
        elevation: 0.5,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: ShopXTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              title: Text(addresses[index], style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() => addresses.removeAt(index));
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        tooltip: 'Add Address',
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
