import 'package:flutter/material.dart' as m;

enum HeadlineSize { large, medium, small }

class Headline extends m.StatelessWidget {
  const Headline(this.text, {super.key, this.size = HeadlineSize.medium});

  final String text;
  final HeadlineSize size;

  @override
  m.Widget build(m.BuildContext context) {
    final m.TextTheme theme = m.Theme.of(context).textTheme;
    final m.TextStyle? style = switch (size) {
      HeadlineSize.large => theme.headlineLarge,
      HeadlineSize.medium => theme.headlineMedium,
      HeadlineSize.small => theme.headlineSmall,
    };
    return m.Text(text, style: style);
  }
}

enum TitleSize { large, medium, small }

class Title extends m.StatelessWidget {
  const Title(this.text, {super.key, this.size = TitleSize.medium});

  final String text;
  final TitleSize size;

  @override
  m.Widget build(m.BuildContext context) {
    final m.TextTheme theme = m.Theme.of(context).textTheme;
    final m.TextStyle? style = switch (size) {
      TitleSize.large => theme.titleLarge,
      TitleSize.medium => theme.titleMedium,
      TitleSize.small => theme.titleSmall,
    };
    return m.Text(text, style: style);
  }
}

enum BodySize { large, medium, small }

class Body extends m.StatelessWidget {
  const Body(this.text, {super.key, this.size = BodySize.medium});

  final String text;
  final BodySize size;

  @override
  m.Widget build(m.BuildContext context) {
    final m.TextTheme theme = m.Theme.of(context).textTheme;
    final m.TextStyle? style = switch (size) {
      BodySize.large => theme.bodyLarge,
      BodySize.medium => theme.bodyMedium,
      BodySize.small => theme.bodySmall,
    };
    return m.Text(text, style: style);
  }
}

enum LabelSize { large, medium, small }

class Label extends m.StatelessWidget {
  const Label(this.text, {super.key, this.size = LabelSize.medium});

  final String text;
  final LabelSize size;

  @override
  m.Widget build(m.BuildContext context) {
    final m.TextTheme theme = m.Theme.of(context).textTheme;
    final m.TextStyle? style = switch (size) {
      LabelSize.large => theme.labelLarge,
      LabelSize.medium => theme.labelMedium,
      LabelSize.small => theme.labelSmall,
    };
    return m.Text(text, style: style);
  }
}
