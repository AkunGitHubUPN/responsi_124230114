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
  final Map<String, dynamic>? menus;
  final List<Map<String, dynamic>>? customerReviews;

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
    this.menus,
    this.customerReviews,
  });  factory Item.fromJson(Map<String, dynamic> json, String menu) {
    // Parse categories dari API
    List<String> parsedCategories = [];
    
    // Check if categories field exists (dari detail endpoint)
    if (json.containsKey('categories') && json['categories'] is List) {
      print('DEBUG: Found "categories" field in JSON');
      parsedCategories = (json['categories'] as List)
          .map<String>((e) {
            if (e is Map && e.containsKey('name')) {
              return e['name']?.toString() ?? '';
            }
            return '';
          })
          .where((e) => e.isNotEmpty)
          .toList();
      print('DEBUG: Parsed categories for "${json['name']}": $parsedCategories');
    } else {
      // Fallback: use city as category if no categories field
      if (json.containsKey('city') && json['city'] != null && json['city'].toString().isNotEmpty) {
        parsedCategories = [json['city'].toString()];
      }
    }

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
      menus: json['menus'] as Map<String, dynamic>?,
      customerReviews: json['customerReviews'] is List 
          ? List<Map<String, dynamic>>.from(json['customerReviews'] as List)
          : null,
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
        'menus': menus,
        'customerReviews': customerReviews,
      };
}
