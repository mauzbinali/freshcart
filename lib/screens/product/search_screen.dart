import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search products, categories...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _ctrl.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (v) =>
              ref.read(searchQueryProvider.notifier).state = v,
        ),
      ),
      body: query.isEmpty
          ? _EmptySearchHint()
          : results.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) => products.isEmpty
                  ? EmptyState(
                      title: 'No results for "$query"',
                      subtitle: 'Try a different keyword',
                      icon: Icons.search_off,
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) =>
                          ProductCard(product: products[i]),
                    ),
            ),
    );
  }
}

class _EmptySearchHint extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Browse by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          categories.when(
            data: (cats) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cats
                  .map((c) => ActionChip(
                        avatar: Text(c.emoji),
                        label: Text(c.name),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state =
                              c.name;
                        },
                      ))
                  .toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
