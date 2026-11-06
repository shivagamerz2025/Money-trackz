import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers.dart';

/// Category picker - shows icon + name in a grid
class CategoryPicker extends ConsumerWidget {
  final CategoryType type;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelect;
  final String? label;

  const CategoryPicker({
    super.key,
    required this.type,
    required this.selectedCategoryId,
    required this.onSelect,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = type == CategoryType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
          const SizedBox(height: 8),
        ],
        categoriesAsync.when(
          data: (categories) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = cat.id == selectedCategoryId;
              return FilterChip(
                avatar: Icon(cat.icon, size: 18, color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant),
                label: Text(cat.name),
                selected: isSelected,
                onSelected: (_) => onSelect(cat.id),
                showCheckmark: false,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text('Error loading categories', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    );
  }
}

/// Compact category chip for list items
class CategoryChip extends ConsumerWidget {
  final String categoryId;
  final CategoryType type;

  const CategoryChip({super.key, required this.categoryId, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = type == CategoryType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        final cat = categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => categories.first,
        );
        return Chip(
          avatar: Icon(cat.icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          label: Text(cat.name, style: Theme.of(context).textTheme.labelSmall),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          visualDensity: VisualDensity.compact,
        );
      },
      loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}