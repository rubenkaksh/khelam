import 'package:flutter/material.dart' as m;

class LoadingView extends m.StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  m.Widget build(m.BuildContext context) {
    return m.Center(
      child: m.Column(
        mainAxisSize: m.MainAxisSize.min,
        children: <m.Widget>[
          const m.CircularProgressIndicator(),
          if (message case final String text) ...[
            const m.SizedBox(height: 16),
            m.Text(text),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends m.StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final m.VoidCallback? onRetry;

  @override
  m.Widget build(m.BuildContext context) {
    return m.Center(
      child: m.Column(
        mainAxisSize: m.MainAxisSize.min,
        children: <m.Widget>[
          const m.Icon(m.Icons.error_outline, size: 48),
          const m.SizedBox(height: 16),
          m.Text(message, textAlign: m.TextAlign.center),
          if (onRetry != null) ...[
            const m.SizedBox(height: 16),
            m.ElevatedButton(onPressed: onRetry, child: const m.Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class EmptyView extends m.StatelessWidget {
  const EmptyView({
    super.key,
    this.icon,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final m.IconData? icon;
  final String? message;
  final String? actionLabel;
  final m.VoidCallback? onAction;

  @override
  m.Widget build(m.BuildContext context) {
    return m.Center(
      child: m.Column(
        mainAxisSize: m.MainAxisSize.min,
        children: <m.Widget>[
          m.Icon(icon ?? m.Icons.inbox_outlined, size: 48),
          if (message case final String text) ...[
            const m.SizedBox(height: 16),
            m.Text(text, textAlign: m.TextAlign.center),
          ],
          if (actionLabel case final String label when onAction != null) ...[
            const m.SizedBox(height: 16),
            m.ElevatedButton(onPressed: onAction, child: m.Text(label)),
          ],
        ],
      ),
    );
  }
}

enum LoadState { loading, error, empty, data }

class StateSwitcher extends m.StatelessWidget {
  const StateSwitcher({
    super.key,
    required this.state,
    this.onRetry,
    this.loading,
    this.error,
    this.empty,
    required this.data,
  });

  final LoadState state;
  final m.VoidCallback? onRetry;
  final m.Widget? loading;
  final m.Widget Function()? error;
  final m.Widget? empty;
  final m.Widget data;

  @override
  m.Widget build(m.BuildContext context) {
    switch (state) {
      case LoadState.loading:
        return loading ?? const LoadingView();
      case LoadState.error:
        final m.Widget Function()? errorBuilder = error;
        return errorBuilder == null
            ? ErrorView(message: 'Something went wrong.', onRetry: onRetry)
            : errorBuilder();
      case LoadState.empty:
        return empty ?? const EmptyView();
      case LoadState.data:
        return data;
    }
  }
}
