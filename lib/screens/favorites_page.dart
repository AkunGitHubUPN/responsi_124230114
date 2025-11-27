import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/storage_service.dart';
import 'detail_page.dart';

typedef OnChangedCallback = void Function();

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // page-level reload triggers the embeddable view to refresh
  void _reload() {
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: FavoritesListView(onChanged: _reload),
    );
  }
}

class FavoritesListView extends StatefulWidget {
  final OnChangedCallback? onChanged;
  const FavoritesListView({super.key, this.onChanged});

  @override
  State<FavoritesListView> createState() => _FavoritesListViewState();
}

class _FavoritesListViewState extends State<FavoritesListView> {
  late Future<List<Item>> _futureFavs;

  @override
  void initState() {
    super.initState();
    _futureFavs = StorageService.getFavorites();
  }

  void _reload() {
    setState(() {
      _futureFavs = StorageService.getFavorites();
    });
    widget.onChanged?.call();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: _futureFavs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
        final list = snapshot.data ?? [];
        if (list.isEmpty) return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Belum ada favorit', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            ],
          ),
        );
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: list.length,
          itemBuilder: (context, index) {            final item = list[index];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.horizontal,
              onDismissed: (dir) async {
                final messenger = ScaffoldMessenger.of(context);
                await StorageService.removeFavorite(item.id, item.menu);
                _reload();
                messenger.showSnackBar(const SnackBar(content: Text('Dihapus dari favorit')));
              },              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(item: item))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: item.pictureId != null && item.pictureId!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network('https://restaurant-api.dicoding.dev/images/small/${item.pictureId}', fit: BoxFit.cover),
                                )
                              : Icon(Icons.restaurant, size: 32, color: Colors.grey.shade400),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.deepOrange),
                                  const SizedBox(width: 4),
                                  Text(item.city ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('${item.rating ?? 0}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
