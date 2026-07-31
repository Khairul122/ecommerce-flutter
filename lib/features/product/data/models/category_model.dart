import '../../domain/entities/category_entity.dart';

int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  return v is int ? v : int.tryParse(v.toString());
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    super.storeId,
    required super.name,
    super.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _toInt(json['id']),
      storeId: _toIntOrNull(json['store_id']),
      name: json['name']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString(),
    );
  }
}
