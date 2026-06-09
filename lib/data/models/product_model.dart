class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? oldPrice;
  final String? image;
  final String? categoryName;
  final double rating;
  final bool featured;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.oldPrice,
    this.image,
    this.categoryName,
    this.rating = 0,
    this.featured = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'],
        price: double.tryParse(j['price'].toString()) ?? 0,
        oldPrice: j['old_price'] != null ? double.tryParse(j['old_price'].toString()) : null,
        image: j['image'],
        categoryName: j['category_name'],
        rating: double.tryParse(j['rating']?.toString() ?? '0') ?? 0,
        featured: j['featured'] == 1 || j['featured'] == true,
      );
}
