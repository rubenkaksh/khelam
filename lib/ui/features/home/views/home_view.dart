import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/app_routes.dart';
import '../bloc/home_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    final HomeCubit homeCubit = context.read<HomeCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeCubit.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Khelam Template'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Preview theme components',
                onPressed: () {
                  final Brightness brightness = Theme.of(context).brightness;
                  context.pushNamed(AppRoutes.themePreview, extra: brightness);
                },
                icon: const Icon(Icons.palette_outlined),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }

    final templateInfo = state.templateInfo;
    if (templateInfo == null) {
      return const Center(child: Text('No template data available.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          templateInfo.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(templateInfo.description),
        const SizedBox(height: 24),
        Text(
          'Architecture layers',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...templateInfo.layers.map(
          (String layer) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.layers_outlined),
            title: Text(layer),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Feature implementation workflow',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...templateInfo.featureWorkflow.asMap().entries.map(
          (MapEntry<int, String> entry) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(radius: 12, child: Text('${entry.key + 1}')),
            title: Text(entry.value),
          ),
        ),
      ],
    );
  }
}
