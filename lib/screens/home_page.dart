import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'detail_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Item>> _futureList;
  late Future<List<String>> _futureCategories;
  int _selectedIndex = 0; // 0: feed, 1: favorites, 2: profile
  String _selectedCategory = 'All'; // Filter kategori

  // in-memory set of favorite keys 'id'
  final Set<String> _favKeys = {};
  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _load();
    _futureCategories = ApiService.fetchCategories();
  }

  Future<void> _loadFavorites() async {
    final favs = await StorageService.getFavorites();
    setState(() {
      _favKeys.clear();
      for (var f in favs) {
        _favKeys.add(f.id);
      }
    });
  }

  void _load() {
    _futureList = ApiService.fetchList('restaurants');
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
  }

  bool _isFav(Item item) => _favKeys.contains(item.id);

  Future<void> _toggleFavorite(Item item) async {
    final messenger = ScaffoldMessenger.of(context);
    if (_favKeys.contains(item.id)) {
      await StorageService.removeFavorite(item.id, 'restaurants');
      setState(() => _favKeys.remove(item.id));
      messenger.showSnackBar(const SnackBar(content: Text('Removed from favorites')));
    } else {
      await StorageService.addFavorite(item);
      setState(() => _favKeys.add(item.id));
      messenger.showSnackBar(const SnackBar(content: Text('Added to favorites')));
    }
  }
  // Filter restaurant berdasarkan kategori
  List<Item> _filterByCategory(List<Item> restaurants) {
    if (_selectedCategory == 'All') {
      return restaurants;
    }
    return restaurants.where((item) {
      return item.categories.any((cat) => cat == _selectedCategory);
    }).toList();
  }Widget _buildFeed() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat datang ${widget.username}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Cari Restoran Favorit Anda', style: TextStyle(color: Colors.grey.shade600)),              const SizedBox(height: 12),              // Category Filter Buttons
              FutureBuilder<List<String>>(
                future: _futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (snapshot.hasError) {
                    print('Category error: ${snapshot.error}');
                  }
                  var categories = snapshot.data ?? ['All'];
                  if (categories.isEmpty) {
                    categories = ['All'];
                  }
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.deepOrange.shade100,
                            side: BorderSide(
                              color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.deepOrange : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Item>>(
            future: _futureList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              var list = snapshot.data ?? [];
              // Apply category filter
              list = _filterByCategory(list);
              if (list.isEmpty) return const Center(child: Text('No restaurants found'));
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(item: item))).then((_) => _loadFavorites()),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: item.pictureId != null && item.pictureId!.isNotEmpty
                                    ? Image.network('https://restaurant-api.dicoding.dev/images/small/${item.pictureId}', fit: BoxFit.cover)
                                    : const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text(item.city ?? '', style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text('${item.rating ?? 0}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(_isFav(item) ? Icons.favorite : Icons.favorite_border, color: _isFav(item) ? Colors.red : null),
                                onPressed: () => _toggleFavorite(item),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Restaurant'),
        
      ),
      body: _selectedIndex == 0
          ? _buildFeed()
          : _selectedIndex == 1
              ? FavoritesListView(onChanged: _loadFavorites)
              : ProfilePage(username: widget.username),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
