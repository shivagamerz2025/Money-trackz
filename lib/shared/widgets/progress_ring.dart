import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers.dart';

/// Thin-stroke progress ring - calm, minimalist
class ProgressRing extends ConsumerWidget {
  final ProgressData data;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.data,
    this.size = 80,
    this.strokeWidth = 6,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = data.isPositive
        ? (data.isOverLimit ? theme.colorScheme.error : theme.colorScheme.tertiary)
        : theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.outlineVariant),
          ),
          // Progress
          CircularProgressIndicator(
            value: data.progress,
            strokeWidth: strokeWidth,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.formattedCurrent,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                data.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small progress ring for dashboard cards
class SmallProgressRing extends ConsumerWidget {
  final ProgressData data;
  final double size;

  const SmallProgressRing({super.key, required this.data, this.size = 48});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = data.isPositive
        ? (data.isOverLimit ? theme.colorScheme.error : theme.colorScheme.tertiary)
        : theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.outlineVariant),
          ),
          CircularProgressIndicator(
            value: data.progress,
            strokeWidth: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '${(data.progress * 100).round()}%',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}