class CenterModel {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? city;
  final double rating;
  final int reviewsCount;
  final bool featured;
  final String? phone;

  CenterModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.city,
    this.rating = 0,
    this.reviewsCount = 0,
    this.featured = false,
    this.phone,
  });

  factory CenterModel.fromJson(Map<String, dynamic> j) => CenterModel(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'],
        image: j['image'],
        city: j['city'],
        rating: double.tryParse(j['rating']?.toString() ?? '0') ?? 0,
        reviewsCount: int.tryParse(j['reviews_count']?.toString() ?? '0') ?? 0,
        featured: j['featured'] == 1 || j['featured'] == true,
        phone: j['phone'],
      );
}
