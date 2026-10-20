import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/widgets/entity_table.dart';

void main() {
  testWidgets('EntityTable строит колонки и вызывает сортировку',
      (tester) async {
    String? sorted;
    int? toggled;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EntityTable<(int, String)>(
          items: const [(1, 'Альфа'), (2, 'Бета')],
          idOf: (r) => r.$1,
          selected: const {2},
          onToggleSelect: (id) => toggled = id,
          sortField: 'name',
          onSort: (field) => sorted = field,
          columns: [
            TableColumnSpec(label: 'Номер', numeric: true, build: (r) => Text('${r.$1}')),
            TableColumnSpec(label: 'Имя', sortField: 'name', build: (r) => Text(r.$2)),
          ],
        ),
      ),
    ));

    expect(find.text('Альфа'), findsOneWidget);
    expect(find.text('Бета'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

    await tester.tap(find.text('Имя'));
    expect(sorted, 'name');

    await tester.tap(find.text('Альфа'));
    expect(toggled, 1);
  });
}
