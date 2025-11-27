class Item {
  final int id;
  final String title;
  final String? summary;
  final String url;
  final String? imageUrl;
  final String? publishedAt;
  final String menu; // articles, blogs, reports

  Item({
    required this.id,
    required this.title,
    required this.url,
    this.summary,
    this.imageUrl,
    this.publishedAt,
    required this.menu,
  });

  factory Item.fromJson(Map<String, dynamic> json, String menu) {
    return Item(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? json['name'] ?? 'No title',
      summary: json['summary'] ?? json['description'] ?? '',
      url: json['url'] ?? json['data'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image'],
      publishedAt: json['published_at'] ?? json['publishedAt'],
      menu: menu,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'url': url,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt,
        'menu': menu,
      };
}
