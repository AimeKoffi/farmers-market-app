import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/service_providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends ConsumerState<ProductListScreen> {
  String _search = '';
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue produits')),
      body: FutureBuilder<List<dynamic>>(
        future: ref.read(productServiceProvider).getProducts(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary));
          }

          final allProducts = snap.data!;
          final filtered = allProducts.where((p) {
            final product = p as Map;
            final matchSearch = _search.isEmpty ||
                product['name']
                    .toString()
                    .toLowerCase()
                    .contains(_search.toLowerCase());
            final matchCat = _selectedCategoryId == null ||
                product['category']?['id'] == _selectedCategoryId;
            return matchSearch && matchCat;
          }).toList();

          // Catégories uniques pour le filtre
          final categories = <int, String>{};
          for (final p in allProducts) {
            final cat = (p as Map)['category'];
            if (cat != null) {
              categories[cat['id'] as int] = cat['name'] as String;
            }
          }

          return Column(
            children: [
              // Barre de recherche
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5)),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),

              // Filtres catégories
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  children: [
                    _CatChip(
                      label: 'Tous',
                      selected: _selectedCategoryId == null,
                      onTap: () =>
                          setState(() => _selectedCategoryId = null),
                    ),
                    ...categories.entries.map((e) => _CatChip(
                          label: e.value,
                          selected: _selectedCategoryId == e.key,
                          onTap: () => setState(
                              () => _selectedCategoryId = e.key),
                        )),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Liste produits
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('Aucun produit trouvé',
                            style: TextStyle(
                                color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final p = filtered[i] as Map;
                          final cat = p['category'] as Map?;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        Icons.inventory_2_outlined,
                                        color: AppColors.primary,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p['name'],
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 14)),
                                        if (cat != null)
                                          Text(cat['name'],
                                              style: const TextStyle(
                                                  color: AppColors
                                                      .textSecondary,
                                                  fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${(p['price_fcfa'] as num).toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(right: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}