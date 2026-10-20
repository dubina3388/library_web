import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatefulWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final ValueChanged<bool>? onToggleAll;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? isMuted;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.onToggleAll,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    this.isMuted,
  });

  @override
  State<EntityTable<T>> createState() => _EntityTableState<T>();
}

class _EntityTableState<T> extends State<EntityTable<T>> {
  final _vertical = ScrollController();
  final _horizontal = ScrollController();

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  int? get _sortColumnIndex {
    final index =
        widget.columns.indexWhere((c) => c.sortField == widget.sortField);
    return index == -1 ? null : index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Scrollbar(
        controller: _vertical,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _vertical,
          child: Scrollbar(
            controller: _horizontal,
            thumbVisibility: true,
            notificationPredicate: (n) => n.depth == 0,
            child: SingleChildScrollView(
              controller: _horizontal,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  showCheckboxColumn: widget.onToggleSelect != null,
                  columnSpacing: 28,
                  horizontalMargin: 16,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: widget.sortAscending,
                  headingTextStyle: theme.textTheme.titleSmall,
                  onSelectAll: widget.onToggleAll == null
                      ? null
                      : (value) => widget.onToggleAll!(value ?? false),
                  columns: [
                    for (final column in widget.columns)
                      DataColumn(
                        label: Text(column.label),
                        numeric: column.numeric,
                        onSort: column.sortField == null || widget.onSort == null
                            ? null
                            : (_, _) => widget.onSort!(column.sortField!),
                      ),
                    if (widget.actions != null)
                      const DataColumn(label: Text('Действия')),
                  ],
                  rows: [
                    for (final item in widget.items) _row(item, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _row(T item, ThemeData theme) {
    final id = widget.idOf(item);
    final muted = widget.isMuted?.call(item) ?? false;
    return DataRow(
      selected: widget.selected.contains(id),
      onSelectChanged: widget.onToggleSelect == null
          ? null
          : (_) => widget.onToggleSelect!(id),
      color: muted
          ? WidgetStatePropertyAll(theme.colorScheme.errorContainer.withValues(alpha: 0.35))
          : null,
      cells: [
        for (final column in widget.columns)
          DataCell(
            DefaultTextStyle.merge(
              style: muted
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
              child: column.build(item),
            ),
          ),
        if (widget.actions != null)
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.actions!(item),
          )),
      ],
    );
  }
}
