import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers.dart';
import '../models/models.dart';

/// Currency input field with formatter
class AmountInput extends ConsumerWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final ValueChanged<double>? onChanged;
  final bool autoFocus;

  const AmountInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final symbol = formatter.currencySymbol;

    return TextFormField(
      controller: controller,
      autofocus: autoFocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? '0.00',
        prefixText: '$symbol ',
        prefixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        onChanged?.call(parsed);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Enter amount';
        final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (parsed == null || parsed <= 0) return 'Enter valid amount';
        return null;
      },
    );
  }
}

/// Simple amount display
class AmountDisplay extends ConsumerWidget {
  final double amount;
  final TransactionType? type;
  final TextStyle? style;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.type,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final theme = Theme.of(context);
    final color = type == TransactionType.income
        ? theme.colorScheme.tertiary
        : type == TransactionType.expense
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface;

    return Text(
      formatter.format(amount),
      style: (style ?? theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}