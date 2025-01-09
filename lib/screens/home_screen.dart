import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/screens/widget/carousel_widget.dart';
import 'package:the_cherry_pet_shop/screens/widget/shop_widget.dart';
import '../core/theme/app_color.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text("PetShop"),
            centerTitle: true,
            backgroundColor:AppColor.primaryColor,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search),
                    Expanded(
                      child: Text("Search | pets, toy, etc."),
                    )
                  ],
                ),
              ),
            ),
          ),

          /// using this methode you can easyly change the widget order

          const SliverToBoxAdapter(
            child: CarouselWidget(),
          ),
          const SliverToBoxAdapter(
            child: PromotionWidget(),
          ),
          const SliverToBoxAdapter(
            child: PetsWidget(),
          ),
          const SliverToBoxAdapter(
            child: CategoryWidget(),
          ),
          const SliverToBoxAdapter(
            child: PopularProductWidget(),
          ),
          const SliverToBoxAdapter(
            child: ShopWidget(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
