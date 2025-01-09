import 'package:flutter/material.dart';

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pet['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pet['images'].isNotEmpty)
              Image.network(
                pet['images'][0]['url'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              'Tên: ${pet['name']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Giá: ${pet['price']} VND'),
            const SizedBox(height: 8),
            Text('Mô tả: ${pet['description']}'),
            const SizedBox(height: 8),
            Text('Tình trạng: ${pet['status']}'),
          ],
        ),
      ),
    );
  }
}
