class EventModel {
  final int id;
  final String title;
  final String? description;
  final String? image;
  final DateTime eventDate;
  final double price;
  final String type; // competition, workshop, event
  final String? location;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.image,
    required this.eventDate,
    this.price = 0,
    this.type = 'event',
    this.location,
  });

  bool get isFree => price == 0;

  String get typeLabel {
    switch (type) {
      case 'competition': return 'مسابقة';
      case 'workshop': return 'ورشة';
      default: return 'فعالية';
    }
  }

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        image: j['image'],
        eventDate: DateTime.tryParse(j['event_date'] ?? '') ?? DateTime.now(),
        price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
        type: j['type'] ?? 'event',
        location: j['location'],
      );
}
