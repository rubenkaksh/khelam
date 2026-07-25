import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/paginated_repository.dart';
import '../../../domain/models/paginated_item.dart';

abstract class PaginatedListState extends Equatable {
  const PaginatedListState();
}

class PaginatedListLoading extends PaginatedListState {
  const PaginatedListLoading();

  @override
  List<Object?> get props => [];
}

class PaginatedListError extends PaginatedListState {
  final String message;
  const PaginatedListError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaginatedListLoaded extends PaginatedListState {
  final List<PaginatedItem> items;
  final int page;
  final bool hasMore;

  const PaginatedListLoaded({
    required this.items,
    this.page = 0,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [items, page, hasMore];
}

class PaginatedListCubit extends Cubit<PaginatedListState> {
  final PaginatedRepository repository;
  final int pageSize;

  PaginatedListCubit(this.repository, {this.pageSize = 20})
      : super(const PaginatedListLoading());

  Future<void> fetchPage(int page) async {
    final itemsBefore = state is PaginatedListLoaded
        ? (state as PaginatedListLoaded).items
        : <PaginatedItem>[];

    emit(const PaginatedListLoading());

    try {
      final response = await repository.fetchPage(page: page, limit: pageSize);

      emit(PaginatedListLoaded(
        items: [...itemsBefore, ...response.items],
        page: page,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      emit(PaginatedListError(e.toString()));
    }
  }
}
