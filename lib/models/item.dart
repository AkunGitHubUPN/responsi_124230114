class Item {
  final String id;
  final String title;
  final String? description;
  final String? city;
  final String? pictureId;
  final double? rating;
  final String menu;
  final String? address;
  final List<String> categories;

  Item({
    required this.id,
    required this.title,
    this.description,
    this.city,
    this.pictureId,
    this.rating,
    required this.menu,
    this.address,
    this.categories = const [],
  });  factory Item.fromJson(Map<String, dynamic> json, String menu) {
    // Parsing categories - since API doesn't have categories field,
    // we'll extract it from city as category (or leave empty for now)
    List<String> parsedCategories = [];
    
    // Option 1: Use city as a pseudo-category
    if (json.containsKey('city') && json['city'] != null) {
      parsedCategories.add(json['city'].toString());
    }
    
    print('DEBUG: Parsed item "${json['name']}" with categories: $parsedCategories');

    return Item(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? 'No name',
      description: json['description'] ?? 'No description',
      city: json['city'] ?? '',
      address: json['address'] ?? 'No address',
      pictureId: json['pictureId'],
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : null,
      menu: menu,
      categories: parsedCategories,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'city': city,
        'address': address,
        'pictureId': pictureId,
        'rating': rating,
        'menu': menu,
        'categories': categories,
      };
}
