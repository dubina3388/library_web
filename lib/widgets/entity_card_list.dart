import 'package:flutter/material.dart';

class EntityCardList<T> extends StatelessWidget {
  final List<T> items;
  final int Function(T item) idOf;
  final String Function(T item) title;
  final String Function(T item) subtitle;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final ValueChanged<T>? onOpen;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? isMuted;

  const EntityCardList({
    super.key,
    required this.items,
    required this.idOf,
    required this.title,
    required this.subtitle,
    this.selected = const {},
    this.onToggleSelect,
    this.onOpen,
    this.actions,
    this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = idOf(item);
        final muted = isMuted?.call(item) ?? false;
        final isSelected = selected.contains(id);
        return Card(
          margin: EdgeInsets.zero,
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : muted
                  ? theme.colorScheme.errorContainer.withValues(alpha: 0.35)
                  : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onOpen == null ? null : () => onOpen!(item),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onToggleSelect != null)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelect!(id),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title(item),
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration:
                                  muted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(subtitle(item), style: theme.textTheme.bodySmall),
                          if (actions != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(children: actions!(item)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
