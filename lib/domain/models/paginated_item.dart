import 'package:equatable/equatable.dart';

class PaginatedItem extends Equatable {
  final String id;
  final String name;

  const PaginatedItem({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];

  factory PaginatedItem.fromJson(Map<String, dynamic> json) {
    return PaginatedItem(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
