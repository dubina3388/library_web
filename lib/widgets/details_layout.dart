import 'package:flutter/material.dart';

import '../state/details_notifier.dart';
import '../state/entity_list_notifier.dart';
import 'state_views.dart';

class DetailsLayout<T> extends StatelessWidget {
  final DetailsNotifier<T> notifier;
  final String notFoundText;
  final VoidCallback onBack;
  final String backLabel;
  final Widget Function(T item) builder;

  const DetailsLayout({
    super.key,
    required this.notifier,
    required this.notFoundText,
    required this.onBack,
    required this.backLabel,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final item = notifier.item;
    final Widget body = switch (notifier.status) {
      LoadStatus.idle || LoadStatus.loading => const LoadingView(),
      LoadStatus.error => ErrorView(
          message: notifier.error ?? 'Неизвестная ошибка',
          onRetry: notifier.load,
        ),
      LoadStatus.success when item == null => MessageView(
          icon: Icons.help_outline,
          title: 'Запись не найдена',
          message: notFoundText,
          actionLabel: backLabel,
          onAction: onBack,
        ),
      LoadStatus.success => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(backLabel),
                  ),
                  const SizedBox(height: 8),
                  builder(item as T),
                ],
              ),
            ),
          ),
        ),
    };
    return body;
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final Widget value;

  const InfoRow({super.key, required this.label, required this.value});

  InfoRow.text({super.key, required this.label, required String text})
      : value = Text(text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: narrow ? 110 : 150,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }
}
