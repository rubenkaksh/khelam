import 'package:equatable/equatable.dart';
import 'paginated_item.dart';

class PaginatedResponse extends Equatable {
  final List<PaginatedItem> items;
  final bool hasMore;
  final int totalItems;

  const PaginatedResponse({
    required this.items,
    required this.hasMore,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [items, hasMore, totalItems];

  PaginatedResponse copyWith({
    List<PaginatedItem>? items,
    bool? hasMore,
    int? totalItems,
  }) {
    return PaginatedResponse(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}
