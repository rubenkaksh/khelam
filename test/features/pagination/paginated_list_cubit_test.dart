import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/presentation/cubit/paginated_list_cubit.dart';
import 'package:khelam/domain/repositories/paginated_repository.dart';
import 'package:khelam/domain/models/paginated_response.dart';
import 'package:khelam/domain/models/paginated_item.dart';

class FakePaginatedRepository implements PaginatedRepository {
  final Map<int, PaginatedResponse Function()> _responses = {};
  final List<Exception> _errors = [];

  void returnOnPage(int page, PaginatedResponse Function() response) {
    _responses[page] = response;
  }

  void throwOnPage(int page, Exception error) {
    _errors.add(error);
  }

  @override
  Future<PaginatedResponse> fetchPage({required int page, required int limit}) async {
    if (_errors.isNotEmpty) {
      final error = _errors.removeAt(0);
      throw error;
    }
    final response = _responses[page];
    if (response != null) return response();
    return PaginatedResponse(
      items: [],
      hasMore: false,
      totalItems: 0,
    );
  }
}

PaginatedItem item(int i) => PaginatedItem(id: '$i', name: 'Item $i');

PaginatedResponse pageOf(List<int> ids, {bool hasMore = true, int total = 20}) {
  return PaginatedResponse(
    items: ids.map(item).toList(),
    hasMore: hasMore,
    totalItems: total,
  );
}

void main() {
  late FakePaginatedRepository mockRepo;

  setUp(() {
    mockRepo = FakePaginatedRepository();
  });

  group('PaginatedListCubit', () {
    test('initial state is loading', () {
      final cubit = PaginatedListCubit(mockRepo);
      expect(cubit.state, isA<PaginatedListLoading>());
    });

    test('loads first page and emits PaginatedListLoaded', () async {
      mockRepo.returnOnPage(0, () => pageOf([0, 1, 2, 3, 4]));

      final cubit = PaginatedListCubit(mockRepo);

      await cubit.fetchPage(0);

      final state = cubit.state as PaginatedListLoaded;
      expect(state.items.length, 5);
      expect(state.page, 0);
      expect(state.hasMore, isTrue);
    });

    test('merges items when loading next page', () async {
      mockRepo.returnOnPage(0, () => pageOf([0, 1, 2, 3, 4]));
      mockRepo.returnOnPage(1, () => pageOf([5, 6, 7, 8, 9]));

      final cubit = PaginatedListCubit(mockRepo);

      await cubit.fetchPage(0);
      expect((cubit.state as PaginatedListLoaded).items.length, 5);

      await cubit.fetchPage(1);
      final state = cubit.state as PaginatedListLoaded;
      expect(state.items.length, 10);
      expect(state.page, 1);
      expect(state.items.first.id, '0');
      expect(state.items.last.id, '9');
    });

    test('stops merging when hasMore is false', () async {
      mockRepo.returnOnPage(0, () => pageOf([0, 1, 2, 3, 4]));
      mockRepo.returnOnPage(1, () => pageOf([5, 6, 7, 8, 9]));
      mockRepo.returnOnPage(2, () => pageOf([10, 11], hasMore: false, total: 12));

      final cubit = PaginatedListCubit(mockRepo);

      await cubit.fetchPage(0);
      expect((cubit.state as PaginatedListLoaded).hasMore, isTrue);

      await cubit.fetchPage(1);
      expect((cubit.state as PaginatedListLoaded).hasMore, isTrue);

      await cubit.fetchPage(2);
      final state = cubit.state as PaginatedListLoaded;
      expect(state.hasMore, isFalse);
      expect(state.items.length, 12);
    });

    test('emits error state on repository failure', () async {
      mockRepo.throwOnPage(0, Exception('Network error'));

      final cubit = PaginatedListCubit(mockRepo);

      await cubit.fetchPage(0);

      final state = cubit.state as PaginatedListError;
      expect(state.message, contains('Network error'));
    });
  });
}
