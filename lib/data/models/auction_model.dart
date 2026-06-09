class AuctionModel {
  final int id;
  final String title;
  final String? description;
  final String? mainImage;
  final double startingPrice;
  final double? currentBid;
  final int bidsCount;
  final DateTime endsAt;
  final String status; // scheduled, live, ended
  final bool featured;

  AuctionModel({
    required this.id,
    required this.title,
    this.description,
    this.mainImage,
    required this.startingPrice,
    this.currentBid,
    this.bidsCount = 0,
    required this.endsAt,
    required this.status,
    this.featured = false,
  });

  double get displayPrice => currentBid ?? startingPrice;
  bool get isLive => status == 'live';

  factory AuctionModel.fromJson(Map<String, dynamic> j) => AuctionModel(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        mainImage: j['main_image'],
        startingPrice: double.tryParse(j['starting_price'].toString()) ?? 0,
        currentBid: j['current_bid'] != null ? double.tryParse(j['current_bid'].toString()) : null,
        bidsCount: int.tryParse(j['bids_count']?.toString() ?? '0') ?? 0,
        endsAt: DateTime.tryParse(j['ends_at'] ?? '') ?? DateTime.now(),
        status: j['status'] ?? 'scheduled',
        featured: j['featured'] == 1 || j['featured'] == true,
      );
}
