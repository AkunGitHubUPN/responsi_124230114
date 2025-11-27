import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class DetailPage extends StatefulWidget {
  final Item item;
  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Item> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = ApiService.fetchDetail(widget.item.id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Restoran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<Item>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final item = snapshot.data ?? widget.item;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image
                if (item.pictureId != null && item.pictureId!.isNotEmpty)
                  Image.network(
                    'https://restaurant-api.dicoding.dev/images/large/${item.pictureId}',
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, size: 60, color: Colors.grey),
                      );
                    },
                  ),
                // Basic Info Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(item.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      const SizedBox(height: 12),
                      
                      // Info Row: Location, Rating, Address
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 18, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(item.city ?? 'N/A', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.star, size: 18, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text('${item.rating ?? 0}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (item.address != null && item.address!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.home, size: 18, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(item.address!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      
                      // Categories
                      if (item.categories.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kategori', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: item.categories.map((category) {
                                return Chip(
                                  label: Text(category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  backgroundColor: Colors.deepOrange,
                                  labelStyle: const TextStyle(color: Colors.white),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Description Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tentang Restoran', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      const SizedBox(height: 12),
                      Text(item.description ?? 'Tidak ada deskripsi', style: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 14)),
                    ],
                  ),
                ),
                
                // Menus Section
                if (item.menus != null && (item.menus!.containsKey('foods') || item.menus!.containsKey('drinks')))
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Menu', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        const SizedBox(height: 12),
                        
                        // Foods
                        if (item.menus!['foods'] != null && (item.menus!['foods'] as List).isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('🍽️ Makanan', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                              const SizedBox(height: 8),
                              ...(item.menus!['foods'] as List).map((food) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          food['name'] ?? 'Menu item',
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 12),
                            ],
                          ),
                        
                        // Drinks
                        if (item.menus!['drinks'] != null && (item.menus!['drinks'] as List).isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('🥤 Minuman', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                              const SizedBox(height: 8),
                              ...(item.menus!['drinks'] as List).map((drink) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          drink['name'] ?? 'Menu item',
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                
                // Customer Reviews Section
                if (item.customerReviews != null && item.customerReviews!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Review Pelanggan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        const SizedBox(height: 12),
                        ...item.customerReviews!.map((review) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.deepOrange.shade200, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review['name'] ?? 'Anonymous',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrange),
                                    ),
                                    if (review['date'] != null)
                                      Text(
                                        review['date'],
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  review['review'] ?? 'No review text',
                                  style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
