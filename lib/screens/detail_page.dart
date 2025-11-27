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
      appBar: AppBar(title: const Text('Detail Restoran')),
      body: FutureBuilder<Item>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final item = snapshot.data ?? widget.item;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.pictureId != null && item.pictureId!.isNotEmpty)
                  Image.network(
                    'https://restaurant-api.dicoding.dev/images/large/${item.pictureId}',
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, size: 60, color: Colors.grey),
                      );
                    },
                  ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(item.city ?? 'N/A', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${item.rating ?? 0}', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Tentang Restoran', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(item.description ?? 'Tidak ada deskripsi', style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
