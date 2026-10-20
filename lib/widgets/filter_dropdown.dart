import 'package:flutter/material.dart';

class FilterDropdown<V> extends StatelessWidget {
  final String label;
  final V? value;
  final String allLabel;
  final List<(V, String)> options;
  final ValueChanged<V?> onChanged;
  final double width;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.allLabel,
    required this.options,
    required this.onChanged,
    this.width = 210,
  });

  @override
  Widget build(BuildContext context) {
    final known = options.any((o) => o.$1 == value);
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<V?>(
            value: known ? value : null,
            isExpanded: true,
            isDense: true,
            items: [
              DropdownMenuItem<V?>(value: null, child: Text(allLabel)),
              for (final (id, name) in options)
                DropdownMenuItem<V?>(value: id, child: Text(name)),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
