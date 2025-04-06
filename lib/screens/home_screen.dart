import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/screens/payment_detail/cart_screen.dart';
import 'package:the_cherry_pet_shop/screens/widget/carousel_widget.dart';
import 'package:the_cherry_pet_shop/screens/widget/shop_widget.dart';
import 'package:the_cherry_pet_shop/shared_preferences/token_manager.dart';

import '../core/theme/app_color.dart';
import 'home_screen/search_box.dart';
import 'widget/category_widget.dart';
import 'widget/pets_widget.dart';
import 'widget/popular_product_widget.dart';
import 'widget/promotion_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadCartCount();
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenManager.getToken();
    setState(() => isLoggedIn = token != null);
  }

  Future<void> _loadCartCount() async {
    final cart = await TokenManager.getCart();
    setState(() => _cartCount = cart.length);
  }

  Future<List<String>> fetchSuggestionsFromAPI(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Product 1', 'Product 2', 'Pet 1', 'Service 1']
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PETSHOP",
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isLoggedIn)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                          // reload count khi quay lại
                          _loadCartCount();
                        },
                      ),
                      if (_cartCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                )
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$_cartCount',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            centerTitle: true,
            backgroundColor: AppColor.primaryColor,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.primaryColor, Colors.amber.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.topCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: SearchBox(fetchSuggestions: fetchSuggestionsFromAPI),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: CarouselWidget()),
          const SliverToBoxAdapter(child: PromotionWidget()),
          const SliverToBoxAdapter(child: PetsWidget()),
          const SliverToBoxAdapter(child: CategoryWidget()),
          const SliverToBoxAdapter(child: PopularServiceWidget()),
          const SliverToBoxAdapter(child: ShopWidget()),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}