import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/category_pill.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;

  const HomeFeedScreen({super.key, required this.onOpenProfile});

  @override
  State<HomeFeedScreen> createState() => HomeFeedScreenState();
}

class HomeFeedScreenState extends State<HomeFeedScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  Future<void> reloadFeed() => _loadInitialData();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  UserModel? _currentUser;

  int? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    _currentUser = await StorageService.getUser();
    final fetched = await _apiService.getCategories();
    _categories = fetched.isNotEmpty ? fetched : CategoryModel.defaultCategories;
    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final items = await _apiService.getProducts(
        categoryId: _selectedCategoryId,
        query: _searchController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _products = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(int? catId) {
    setState(() {
      // Toggle off to "All" if tapping the already selected category
      if (_selectedCategoryId == catId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = catId;
      }
    });
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProducts,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Top Bar with Logo & Campus Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Title & Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Campus Cart',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Profile Avatar
                      GestureDetector(
                        onTap: widget.onOpenProfile,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surfaceContainer,
                          child: Text(
                            (_currentUser?.fullName.isNotEmpty ?? false)
                                ? (_currentUser?.fullName[0].toUpperCase() ?? 'S')
                                : 'S',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _fetchProducts(),
                      decoration: InputDecoration(
                        hintText: 'Search textbooks, electronics, dorm...',
                        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  _fetchProducts();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),

              // Category Filter Pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    children: [
                      CategoryPill(
                        label: 'All',
                        isSelected: _selectedCategoryId == null,
                        onTap: () => _onCategorySelected(null),
                      ),
                      ..._categories.map((c) => CategoryPill(
                            label: c.name,
                            icon: c.iconData,
                            isSelected: _selectedCategoryId == c.id,
                            onTap: () => _onCategorySelected(c.id),
                          )),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Product Grid
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_products.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 54, color: AppColors.textLight),
                        const SizedBox(height: 12),
                        const Text(
                          'No listings found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first student to post an item!',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(productId: product.id),
                              ),
                            ).then((_) => _fetchProducts());
                          },
                        );
                      },
                      childCount: _products.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
