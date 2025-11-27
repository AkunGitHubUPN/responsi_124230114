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
    _futureList = ApiService.fetchListWithCategories('restaurants');
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
  }  Widget _buildFeed() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat datang ${widget.username} 👋', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 4),
              Text('Cari Restoran Favorit Anda', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              // Category Filter Buttons
              FutureBuilder<List<String>>(
                future: _futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepOrange)),
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
                            selectedColor: Colors.deepOrange,
                            side: BorderSide(
                              color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              var list = snapshot.data ?? [];
              // Apply category filter
              list = _filterByCategory(list);
              if (list.isEmpty) return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Restoran tidak ditemukan', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  ],
                ),
              );
              return RefreshIndicator(
                onRefresh: _refresh,
                color: Colors.deepOrange,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(item: item))).then((_) => _loadFavorites()),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                child: item.pictureId != null && item.pictureId!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network('https://restaurant-api.dicoding.dev/images/small/${item.pictureId}', fit: BoxFit.cover),
                                      )
                                    : Icon(Icons.restaurant, size: 45, color: Colors.grey.shade400),
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
                              ),
                              IconButton(
                                icon: Icon(
                                  _isFav(item) ? Icons.favorite : Icons.favorite_border,
                                  color: _isFav(item) ? Colors.red : Colors.deepOrange,
                                  size: 20,
                                ),
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
        title: const Text('Restaurant App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: _selectedIndex == 0
          ? _buildFeed()
          : _selectedIndex == 1
              ? FavoritesListView(onChanged: _loadFavorites)
              : ProfilePage(username: widget.username),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey.shade500,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
