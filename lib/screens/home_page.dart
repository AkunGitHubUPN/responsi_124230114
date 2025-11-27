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
  String _menu = 'articles';
  late Future<List<Item>> _futureList;
  int _selectedIndex = 0; // 0: feed, 1: favorites, 2: profile

  // in-memory set of favorite keys 'menu-id'
  final Set<String> _favKeys = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _load();
  }

  Future<void> _loadFavorites() async {
    final favs = await StorageService.getFavorites();
    setState(() {
      _favKeys.clear();
      for (var f in favs) {
        _favKeys.add('${f.menu}-${f.id}');
      }
    });
  }

  void _load() {
    _futureList = ApiService.fetchList(_menu);
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
  }

  bool _isFav(Item item) => _favKeys.contains('${item.menu}-${item.id}');

  Future<void> _toggleFavorite(Item item) async {
    final messenger = ScaffoldMessenger.of(context);
    final key = '${item.menu}-${item.id}';
    if (_favKeys.contains(key)) {
      await StorageService.removeFavorite(item.id, item.menu);
      setState(() => _favKeys.remove(key));
      messenger.showSnackBar(const SnackBar(content: Text('Removed from favorites')));
    } else {
      await StorageService.addFavorite(item);
      setState(() => _favKeys.add(key));
      messenger.showSnackBar(const SnackBar(content: Text('Added to favorites')));
    }
  }

  Widget _buildFeed() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat datang ${widget.username}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  _menuButton('articles', 'Articles'),
                  const SizedBox(width: 8),
                  _menuButton('blogs', 'Blogs'),
                  const SizedBox(width: 8),
                  _menuButton('reports', 'Reports'),
                ],
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
              final list = snapshot.data ?? [];
              if (list.isEmpty) return const Center(child: Text('No items'));
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
                                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                                    : const Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(item.menu, style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 6),
                                    Text(item.publishedAt ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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

  Widget _menuButton(String menuValue, String label) {
    final active = _menu == menuValue;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: active ? Colors.purple.shade50 : null,
          side: BorderSide(color: active ? Colors.purple : Colors.grey.shade300),
        ),
        onPressed: () {
          setState(() {
            _menu = menuValue;
            _load();
          });
        },
        child: Text(label, style: TextStyle(color: active ? Colors.purple : null)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Articles'),
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
