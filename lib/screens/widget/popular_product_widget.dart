import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/pet_service_model.dart';
import '../../services/api_client.dart';
import '../apoinment/servicedetail_screen.dart';

class PopularServiceWidget extends StatefulWidget {
  const PopularServiceWidget({super.key});

  @override
  _PopularServiceWidgetState createState() => _PopularServiceWidgetState();
}

class _PopularServiceWidgetState extends State<PopularServiceWidget> {
  late Future<List<PetService>> _services;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _services = _fetchServices();
  }

  Future<List<PetService>> _fetchServices() async {
    try {
      // ApiClient sẽ tự động thêm baseUrl và header Authorization nếu có token :contentReference[oaicite:0]{index=0}
      final response = await _apiClient.get('Service');
      debugPrint('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('Parsed Data: $data');
        return data.map((e) => PetService.fromJson(e)).toList();
      } else {
        throw Exception(
            'Failed to load services (status ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            "Danh sách dịch vụ thú cưng",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<List<PetService>>(
            future: _services,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Không thể tải dịch vụ: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final services = snapshot.data!;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailScreen(service: service),
                          ),
                        );
                      },
                      child: Container(
                        width: 220,
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[200]!,
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: const Offset(1, 1),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 220,
                              height: 180,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: Image.network(
                                  service.images.isNotEmpty
                                      ? service.images[0].url
                                      : 'https://via.placeholder.com/220x180',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (ctx, child, prog) {
                                    if (prog == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                service.name,
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('Không có dịch vụ nào'));
              }
            },
          ),
        ),
      ],
    );
  }
}
