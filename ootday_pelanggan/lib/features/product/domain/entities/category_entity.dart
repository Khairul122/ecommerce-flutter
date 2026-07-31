class CategoryEntity {
  final int id;
  final int? storeId;
  final String name;
  final String? iconUrl;

  const CategoryEntity({
    required this.id,
    this.storeId,
    required this.name,
    this.iconUrl,
  });
}
