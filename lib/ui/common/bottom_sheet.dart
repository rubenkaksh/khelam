import 'package:flutter/material.dart' as m;

/// A generic bottom sheet with title, scrollable body, and confirm/cancel CTAs.
///
/// Use [showFormBottomSheet] to display this as a modal bottom sheet.
class FormBottomSheet extends m.StatelessWidget {
  const FormBottomSheet({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
    this.subtitle,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.confirmEnabled = true,
  });

  final String title;
  final String? subtitle;
  final m.Widget body;
  final String confirmLabel;
  final m.VoidCallback? onConfirm;
  final String cancelLabel;
  final m.VoidCallback? onCancel;
  final bool confirmEnabled;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (m.BuildContext context, m.ScrollController scrollController) {
        return m.Container(
          decoration: m.BoxDecoration(
            color: colors.surface,
            borderRadius: const m.BorderRadius.vertical(
              top: m.Radius.circular(20),
            ),
          ),
          child: m.Column(
            children: <m.Widget>[
              // Drag handle
              m.Container(
                margin: const m.EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: m.BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: m.BorderRadius.circular(2),
                ),
              ),
              // Header
              m.Padding(
                padding: const m.EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: m.Column(
                  crossAxisAlignment: m.CrossAxisAlignment.start,
                  children: <m.Widget>[
                    m.Text(
                      title,
                      style: m.Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (subtitle case final subtitle?) ...[
                      const m.SizedBox(height: 4),
                      m.Text(
                        subtitle,
                        style: m.Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Scrollable body
              m.Expanded(
                child: m.SingleChildScrollView(
                  controller: scrollController,
                  padding: const m.EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: body,
                ),
              ),
              // CTAs
              m.Padding(
                padding: const m.EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: m.Row(
                  children: <m.Widget>[
                    m.Expanded(
                      child: m.OutlinedButton(
                        onPressed: onCancel ?? () => m.Navigator.pop(context),
                        child: m.Text(cancelLabel),
                      ),
                    ),
                    const m.SizedBox(width: 12),
                    m.Expanded(
                      child: m.FilledButton(
                        onPressed: confirmEnabled ? onConfirm : null,
                        child: m.Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shows a modal bottom sheet with [FormBottomSheet] content.
///
/// Returns a [Future] that completes with the value passed to
/// [Navigator.pop] when the sheet is dismissed.
Future<T?> showFormBottomSheet<T>({
  required m.BuildContext context,
  required m.WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return m.showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: builder,
  );
}
