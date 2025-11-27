import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/item.dart';

class DetailPage extends StatelessWidget {
  final Item item;
  const DetailPage({super.key, required this.item});

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(item.url);
    final messenger = ScaffoldMessenger.of(context);
    if (uri == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Invalid URL')));
      return;
    }
    if (!await launchUrl(uri)) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not open URL')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              Image.network(item.imageUrl!, height: 220, fit: BoxFit.cover),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(item.menu, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text(item.publishedAt ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 12),
                  Text(item.summary ?? ''),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => _openUrl(context),
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.purple.shade50),
                      child: const Text('Read more...'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
