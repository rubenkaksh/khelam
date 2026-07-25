import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/template_repository.dart';
import '../../../../domain/models/template_info.dart';

class HomeState {
  const HomeState({
    this.templateInfo,
    this.isLoading = false,
    this.errorMessage,
  });

  final TemplateInfo? templateInfo;
  final bool isLoading;
  final String? errorMessage;

  HomeState copyWith({
    TemplateInfo? templateInfo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      templateInfo: templateInfo ?? this.templateInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required TemplateRepository repository})
    : _repository = repository,
      super(const HomeState());

  final TemplateRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final TemplateInfo templateInfo = await _repository.getTemplateInfo();
      emit(
        state.copyWith(
          templateInfo: templateInfo,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load template information.',
        ),
      );
    }
  }
}
