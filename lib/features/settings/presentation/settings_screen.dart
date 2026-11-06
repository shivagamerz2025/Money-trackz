import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers.dart';
import '../../../../shared/repositories/settings_repository.dart';
import '../../../../shared/models/currency.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(['System', 'Light', 'Dark'][themeMode]),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  title: const Text('System'),
                  trailing: Radio<int>(
                    value: 0,
                    groupValue: themeMode,
                    onChanged: (v) => _setThemeMode(ref, v!),
                  ),
                ),
                ListTile(
                  title: const Text('Light'),
                  trailing: Radio<int>(
                    value: 1,
                    groupValue: themeMode,
                    onChanged: (v) => _setThemeMode(ref, v!),
                  ),
                ),
                ListTile(
                  title: const Text('Dark'),
                  trailing: Radio<int>(
                    value: 2,
                    groupValue: themeMode,
                    onChanged: (v) => _setThemeMode(ref, v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Currency
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Currency'),
                  subtitle: Text('${currency.code} (${currency.symbol})'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(height: 1, indent: 72),
                ...Currency.values.map((c) => RadioListTile<Currency>(
                  value: c,
                  groupValue: currency,
                  title: Text('${c.name} (${c.symbol})'),
                  onChanged: (v) => _setCurrency(ref, v!),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export all data as CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportData(context, ref),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Import Data'),
                  subtitle: const Text('Import data from CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _importData(context, ref),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                  title: Text('Clear All Data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  subtitle: const Text('Permanently delete all transactions, bills, and budgets'),
                  onTap: () => _clearData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Navigation
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Manage Categories'),
                  subtitle: const Text('Add, edit, or delete custom categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/categories'),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Budget Settings'),
                  subtitle: const Text('Set monthly spend limit and saving goal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/budget'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Money Tracker v1.0.0'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Money Tracker',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setThemeMode(WidgetRef ref, int mode) {
    ref.read(themeModeProvider.notifier).state = mode;
    ref.read(settingsRepositoryProvider).setThemeMode(mode);
  }

  void _setCurrency(WidgetRef ref, Currency currency) {
    ref.read(settingsRepositoryProvider).setCurrency(currency);
    ref.invalidate(selectedCurrencyProvider);
    ref.invalidate(currencyFormatterProvider);
  }

  void _exportData(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export coming soon')),
    );
  }

  void _importData(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import coming soon')),
    );
  }

  void _clearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all transactions, bills, budgets, and custom categories. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(settingsRepositoryProvider).clearAll();
              // Also clear other boxes
              await Hive.box('categories').clear();
              await Hive.box('transactions').clear();
              await Hive.box('bills').clear();
              await Hive.box('budgets').clear();
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}