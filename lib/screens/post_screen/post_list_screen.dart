import 'package:flutter/material.dart';

import '../../models/postlist_model.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = Post.sampleData;

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách bài đăng')),
      body: ListView.separated(
        itemCount: posts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final p = posts[i];
          return ListTile(
            leading: p.imageUrl.isNotEmpty
                ? Image.network(
                    p.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
            title: Text(p.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bởi ${p.author} • ${p.time}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(p.detail, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.white54),
      );
}
