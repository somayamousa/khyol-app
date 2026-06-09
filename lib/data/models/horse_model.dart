class HorseModel {
  final int id;
  final String name;
  final String? breed;
  final int? age;
  final String? gender;
  final String? color;
  final String? image;
  final double? price;
  final bool forSale;
  final String? city;
  final String? ownerName;

  HorseModel({
    required this.id,
    required this.name,
    this.breed,
    this.age,
    this.gender,
    this.color,
    this.image,
    this.price,
    this.forSale = false,
    this.city,
    this.ownerName,
  });

  factory HorseModel.fromJson(Map<String, dynamic> j) => HorseModel(
        id: j['id'],
        name: j['name'] ?? '',
        breed: j['breed'],
        age: j['age'] != null ? int.tryParse(j['age'].toString()) : null,
        gender: j['gender'],
        color: j['color'],
        image: j['image'],
        price: j['price'] != null ? double.tryParse(j['price'].toString()) : null,
        forSale: j['for_sale'] == 1 || j['for_sale'] == true,
        city: j['city'],
        ownerName: j['owner_name'],
      );
}
