import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebouncedField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final IconData? icon;
  final bool digitsOnly;
  final double width;
  final Duration delay;

  const DebouncedField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.icon,
    this.digitsOnly = false,
    this.width = 320,
    this.delay = const Duration(milliseconds: 400),
  });

  @override
  State<DebouncedField> createState() => _DebouncedFieldState();
}

class _DebouncedFieldState extends State<DebouncedField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  Timer? _timer;

  @override
  void didUpdateWidget(DebouncedField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pending = _timer?.isActive ?? false;
    if (!pending && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _schedule(String text) {
    _timer?.cancel();
    _timer = Timer(widget.delay, () => widget.onChanged(text.trim()));
    setState(() {});
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        onChanged: _schedule,
        keyboardType: widget.digitsOnly ? TextInputType.number : null,
        inputFormatters: widget.digitsOnly
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ]
            : null,
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          border: const OutlineInputBorder(),
          prefixIcon: widget.icon == null ? null : Icon(widget.icon),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Очистить',
                  icon: const Icon(Icons.clear),
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}
