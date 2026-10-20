import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/list_query.dart';
import '../state/entity_list_notifier.dart';
import 'confirm_dialog.dart';
import 'debounced_field.dart';
import 'entity_card_list.dart';
import 'entity_table.dart';
import 'pagination_bar.dart';
import 'state_views.dart';

const narrowBreakpoint = 600.0;

class EntityListPage<T, Q extends ListQuery<Q>> extends StatefulWidget {
  final Q query;
  final EntityListNotifier<T, Q> notifier;
  final String searchLabel;
  final List<TableColumnSpec<T>> columns;
  final String Function(T item) cardTitle;
  final String Function(T item) cardSubtitle;
  final String Function(T item) itemLabel;
  final String Function(T item) detailsLocation;
  final bool Function(T item) isDeleted;
  final List<Widget> Function(Q query, ValueChanged<Q> apply)? filters;
  final int Function(Q query)? activeFilterCount;
  final VoidCallback? onDataChanged;

  const EntityListPage({
    super.key,
    required this.query,
    required this.notifier,
    required this.searchLabel,
    required this.columns,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.itemLabel,
    required this.detailsLocation,
    required this.isDeleted,
    this.filters,
    this.activeFilterCount,
    this.onDataChanged,
  });

  @override
  State<EntityListPage<T, Q>> createState() => _EntityListPageState<T, Q>();
}

class _EntityListPageState<T, Q extends ListQuery<Q>>
    extends State<EntityListPage<T, Q>> {
  bool _syncScheduled = false;

  EntityListNotifier<T, Q> get _notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifier.applyQuery(widget.query);
    });
  }

  @override
  void didUpdateWidget(EntityListPage<T, Q> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _notifier.query && !_syncScheduled) {
      _syncScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncScheduled = false;
        if (mounted && widget.query != _notifier.query) {
          _notifier.applyQuery(widget.query);
        }
      });
    }
  }

  void _apply(Q next) => context.go(next.toLocation());

  Future<void> _softDelete(T item) async {
    final ok = await confirm(
      context,
      title: 'Удалить запись?',
      message: '«${widget.itemLabel(item)}» будет помечена как удалённая. '
          'Её можно будет восстановить, включив показ удалённых.',
    );
    if (!ok || !mounted) return;
    await _notifier.softDelete(_notifier.idOf(item));
    widget.onDataChanged?.call();
    if (mounted) showMessage(context, 'Запись перемещена в удалённые');
  }

  Future<void> _hardDelete(T item) async {
    final ok = await confirm(
      context,
      title: 'Удалить навсегда?',
      message: '«${widget.itemLabel(item)}» будет стёрта без возможности '
          'восстановления.',
      action: 'Удалить навсегда',
    );
    if (!ok || !mounted) return;
    await _notifier.hardDelete(_notifier.idOf(item));
    widget.onDataChanged?.call();
    if (mounted) showMessage(context, 'Запись удалена навсегда');
  }

  Future<void> _restore(T item) async {
    await _notifier.restore(_notifier.idOf(item));
    widget.onDataChanged?.call();
    if (mounted) showMessage(context, 'Запись восстановлена');
  }

  Future<void> _deleteSelected() async {
    final count = _notifier.selected.length;
    final ok = await confirm(
      context,
      title: 'Удалить выбранные записи?',
      message: 'Будет удалено записей: $count. '
          'Их можно будет восстановить, включив показ удалённых.',
    );
    if (!ok || !mounted) return;
    final deleted = await _notifier.deleteSelected();
    widget.onDataChanged?.call();
    if (mounted) showMessage(context, 'Удалено записей: $deleted');
  }

  List<Widget> _actions(T item) {
    final scheme = Theme.of(context).colorScheme;
    return [
      IconButton(
        tooltip: 'Открыть карточку',
        icon: const Icon(Icons.visibility_outlined),
        onPressed: () => context.go(widget.detailsLocation(item)),
      ),
      if (!widget.isDeleted(item))
        IconButton(
          tooltip: 'Удалить',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _softDelete(item),
        )
      else ...[
        IconButton(
          tooltip: 'Восстановить',
          icon: const Icon(Icons.restore),
          onPressed: () => _restore(item),
        ),
        IconButton(
          tooltip: 'Удалить навсегда',
          color: scheme.error,
          icon: const Icon(Icons.delete_forever),
          onPressed: () => _hardDelete(item),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < narrowBreakpoint;
    final query = _notifier.query;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(query, narrow),
        _selectionBar(),
        const Divider(height: 1),
        Expanded(child: _content(query, narrow)),
        if (_notifier.status != LoadStatus.error)
          PaginationBar(
            result: _notifier.result,
            onPage: (page) => _apply(query.toPage(page)),
            onSize: (size) => _apply(query.copyWith(size: size)),
          ),
      ],
    );
  }

  Widget _header(Q query, bool narrow) {
    final filters = widget.filters?.call(query, _apply) ?? const [];
    final active = widget.activeFilterCount?.call(query) ?? 0;
    final common = <Widget>[
      FilterChip(
        label: const Text('Показать удалённые'),
        selected: query.includeDeleted,
        onSelected: (value) => _apply(query.copyWith(includeDeleted: value)),
      ),
      if (query.hasFilters)
        TextButton.icon(
          onPressed: () => _apply(query.cleared()),
          icon: const Icon(Icons.filter_alt_off),
          label: const Text('Сбросить'),
        ),
    ];
    final search = DebouncedField(
      value: query.search,
      label: widget.searchLabel,
      icon: Icons.search,
      width: narrow ? double.infinity : 340,
      onChanged: (text) => _apply(query.copyWith(search: text)),
    );
    if (!narrow) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [search, ...filters, ...common],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(active == 0 ? 'Фильтры и сортировка' : 'Фильтры: $active'),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [...filters, _sortControl(query), ...common],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sortControl(Q query) {
    final sortable = widget.columns.where((c) => c.sortField != null).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Сортировка:'),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: query.sortField,
          items: [
            for (final c in sortable)
              DropdownMenuItem(value: c.sortField, child: Text(c.label)),
          ],
          onChanged: (field) {
            if (field != null && field != query.sortField) {
              _apply(query.sortedBy(field));
            }
          },
        ),
        IconButton(
          tooltip: query.sortAscending ? 'По возрастанию' : 'По убыванию',
          icon: Icon(query.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () => _apply(query.sortedBy(query.sortField)),
        ),
      ],
    );
  }

  Widget _selectionBar() {
    final count = _notifier.selected.length;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(
            avatar: const Icon(Icons.check_box_outlined, size: 18),
            label: Text('Выбрано: $count'),
          ),
          if (count > 0)
            TextButton(
              onPressed: _notifier.clearSelection,
              child: const Text('Снять выделение'),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: count == 0 ? null : _deleteSelected,
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Удалить выбранные'),
          ),
        ],
      ),
    );
  }

  Widget _content(Q query, bool narrow) {
    final notifier = _notifier;
    final result = notifier.result;
    switch (notifier.status) {
      case LoadStatus.idle:
        return const LoadingView();
      case LoadStatus.error:
        return ErrorView(
          message: notifier.error ?? 'Неизвестная ошибка',
          onRetry: notifier.load,
        );
      case LoadStatus.loading:
        if (result.isEmpty) return const LoadingView();
        return Stack(
          children: [
            Positioned.fill(
              child: Opacity(opacity: 0.5, child: _list(narrow)),
            ),
            const LinearProgressIndicator(),
          ],
        );
      case LoadStatus.success:
        if (result.isEmpty) return _empty(query);
        return _list(narrow);
    }
  }

  Widget _empty(Q query) {
    final result = _notifier.result;
    if (result.total > 0) {
      return EmptyView(
        message: 'Страницы ${result.page} нет: всего страниц ${result.totalPages}.',
        actionLabel: 'На первую страницу',
        onAction: () => _apply(query.toPage(1)),
      );
    }
    if (query.hasFilters) {
      return EmptyView(
        message: 'По заданным условиям записей нет. '
            'Измените строку поиска или фильтры.',
        actionLabel: 'Сбросить фильтры',
        onAction: () => _apply(query.cleared()),
      );
    }
    return const EmptyView(message: 'Список пока пуст.');
  }

  Widget _list(bool narrow) {
    final notifier = _notifier;
    final query = notifier.query;
    final items = notifier.result.items;
    if (narrow) {
      return EntityCardList<T>(
        items: items,
        idOf: notifier.idOf,
        title: widget.cardTitle,
        subtitle: widget.cardSubtitle,
        selected: notifier.selected,
        onToggleSelect: notifier.toggleSelection,
        onOpen: (item) => context.go(widget.detailsLocation(item)),
        actions: _actions,
        isMuted: widget.isDeleted,
      );
    }
    return EntityTable<T>(
      columns: widget.columns,
      items: items,
      idOf: notifier.idOf,
      selected: notifier.selected,
      onToggleSelect: notifier.toggleSelection,
      onToggleAll: notifier.selectAllOnPage,
      sortField: query.sortField,
      sortAscending: query.sortAscending,
      onSort: (field) => _apply(query.sortedBy(field)),
      actions: _actions,
      isMuted: widget.isDeleted,
    );
  }
}
