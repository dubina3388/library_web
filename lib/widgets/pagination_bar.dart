import 'package:flutter/material.dart';

import '../models/list_query.dart';
import '../models/page_result.dart';

class PaginationBar extends StatelessWidget {
  final PageResult<Object?> result;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onSize;

  const PaginationBar({
    super.key,
    required this.result,
    required this.onPage,
    required this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = result.totalPages;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Всего записей: ${result.total}'),
                const SizedBox(width: 16),
                const Text('По'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: result.size,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final size in pageSizes)
                      DropdownMenuItem(value: size, child: Text('$size')),
                  ],
                  onChanged: (value) {
                    if (value != null) onSize(value);
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Первая страница',
                  icon: const Icon(Icons.first_page),
                  onPressed: result.hasPrevious ? () => onPage(1) : null,
                ),
                IconButton(
                  tooltip: 'Предыдущая страница',
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      result.hasPrevious ? () => onPage(result.page - 1) : null,
                ),
                Text(
                  'Стр. ${result.page} из $last',
                  style: theme.textTheme.titleSmall,
                ),
                IconButton(
                  tooltip: 'Следующая страница',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: result.hasNext ? () => onPage(result.page + 1) : null,
                ),
                IconButton(
                  tooltip: 'Последняя страница',
                  icon: const Icon(Icons.last_page),
                  onPressed: result.hasNext ? () => onPage(last) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
