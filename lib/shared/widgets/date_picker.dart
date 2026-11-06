import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Date picker field
class DatePickerField extends ConsumerWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.label,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = initialDate ?? DateTime.now();
    final formatter = DateFormat('MMM d, yyyy');

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.colorScheme.primary,
                onPrimary: theme.colorScheme.onPrimary,
                surface: theme.colorScheme.surface,
                onSurface: theme.colorScheme.onSurface,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurfaceVariant),
        ),
        child: Text(
          formatter.format(date),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

/// Month picker for navigation
class MonthPickerField extends ConsumerWidget {
  final DateTime currentMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final String? label;

  const MonthPickerField({
    super.key,
    required this.currentMonth,
    required this.onMonthChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = DateFormat('MMMM yyyy');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
          onPressed: () => onMonthChanged(DateTime(currentMonth.year, currentMonth.month - 1, 1)),
          tooltip: 'Previous month',
        ),
        Text(
          formatter.format(currentMonth),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
          onPressed: () => onMonthChanged(DateTime(currentMonth.year, currentMonth.month + 1, 1)),
          tooltip: 'Next month',
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(label!, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}