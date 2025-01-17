import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';

class ShopWidget extends StatelessWidget {
  const ShopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Bạn đang tìm \nChó con hoặc mèo con mới?",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(
            height: 100,
            child: Image(
              image: AssetImage(
                "assets/puppy_shop.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: 100,
            child: Image(
              image: AssetImage(
                "assets/kitten_shop.jpg",
              ),
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
