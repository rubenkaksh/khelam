import '../../../domain/models/paginated_response.dart';

abstract class PaginatedRepository {
  Future<PaginatedResponse> fetchPage({
    required int page,
    required int limit,
  });
}
