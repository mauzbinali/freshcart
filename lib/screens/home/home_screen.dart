// FIX: use flutter_carousel_widget — no CarouselController naming conflict
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _bannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── APP BAR ───
            SliverAppBar(
              floating: true,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deliver to',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppTheme.primaryGreen),
                      const SizedBox(width: 2),
                      Text(
                        user?.name ?? 'My Location',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ],
              ),
              actions: const [
                CartBadge(),
                SizedBox(width: 4),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── GREETING ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'Hello, ${AppUtils.firstName(user?.name)} 👋',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                    child: Text(
                      'What would you like to order today?',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ),

                  // ─── SEARCH BAR ───
                  GestureDetector(
                    onTap: () => context.push('/home/search'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade400),
                          const SizedBox(width: 10),
                          Text('Search products...',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── BANNER SLIDER ───
                  // flutter_carousel_widget API: FlutterCarousel, no CarouselController clash
                  FlutterCarousel(
                    options: CarouselOptions(
                      height: 160,
                      viewportFraction: 0.9,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      enlargeCenterPage: true,
                      showIndicator: false, // we draw our own dots below
                      onPageChanged: (i, _) => setState(() => _bannerIndex = i),
                    ),
                    items: AppConstants.banners.map((b) {
                      final color = Color(int.parse(b['color']!));
                      return _BannerCard(
                        banner: b,
                        color: color,
                        onShopNow: () {
                          final title = b['title'] ?? '';
                          if (title.contains('Vegetables')) {
                            context.push('/home/category/Vegetables');
                          } else if (title.contains('Fruits')) {
                            context.push('/home/category/Fruits');
                          } else {
                            context.push('/home/search');
                          }
                        },
                      );
                    }).toList(),
                  ),

                  // Dots
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      AppConstants.banners.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _bannerIndex == i ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: _bannerIndex == i
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ─── CATEGORIES ───
                  SectionHeader(
                    title: 'Categories',
                    actionText: 'See all',
                    onAction: () {},
                  ),
                  SizedBox(
                    height: 90,
                    child: categories.when(
                      data: (cats) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: cats.length,
                        itemBuilder: (_, i) => _CategoryChip(
                          name: cats[i].name,
                          emoji: cats[i].emoji,
                          onTap: () =>
                              context.push('/home/category/${cats[i].name}'),
                        ),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) =>
                          const Center(child: Text('Failed to load')),
                    ),
                  ),

                  // ─── FEATURED ───
                  SectionHeader(
                    title: 'Featured Products',
                    actionText: 'See all',
                    onAction: () => context.push('/home/search'),
                  ),
                ],
              ),
            ),

            // ─── PRODUCT GRID ───
            featured.when(
              data: (products) => products.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyState(
                        title: 'No products yet',
                        subtitle: 'Check back soon!',
                        icon: Icons.storefront_outlined,
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => ProductCard(product: products[i]),
                          childCount: products.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                      ),
                    ),
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const ProductCardShimmer(),
                    childCount: 6,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Map<String, String> banner;
  final Color color;
  final VoidCallback onShopNow;
  const _BannerCard({
    required this.banner,
    required this.color,
    required this.onShopNow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onShopNow,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(banner['tag']!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ),
                    const SizedBox(height: 6),
                    Text(banner['title']!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(banner['subtitle']!,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Shop Now',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Text(banner['emoji']!, style: const TextStyle(fontSize: 52)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final String emoji;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.name, required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 4),
            Text(name,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
