import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart';

class MyListingsScreen extends StatefulWidget {
  final VoidCallback onNavigateToSell;

  const MyListingsScreen({super.key, required this.onNavigateToSell});

  @override
  State<MyListingsScreen> createState() => MyListingsScreenState();
}

class MyListingsScreenState extends State<MyListingsScreen> {
  final ApiService _apiService = ApiService();
  List<ProductModel> _myListings = [];
  UserModel? _currentUser;
  bool _isLoading = true;

  Future<void> reloadListings() => _loadListings();

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    _currentUser = await StorageService.getUser();
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final items = await _apiService.getMyListings();
      if (mounted) {
        setState(() {
          _myListings = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(ProductModel product) async {
    final newStatus = product.isAvailable ? 'SOLD' : 'AVAILABLE';
    try {
      await _apiService.updateProductStatus(product.id, newStatus);
      _loadListings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteListing(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to remove this listing? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _apiService.deleteProduct(id);
      _loadListings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 54, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('Sign in to view your listings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuthScreen(
                        onLoginSuccess: () {
                          Navigator.pop(context);
                          _loadListings();
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _myListings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.post_add_rounded, size: 54, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      const Text(
                        'You haven\'t listed any items yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Declutter your dorm and sell to fellow students!',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: widget.onNavigateToSell,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Post an Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadListings,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myListings.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _myListings[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Icon Thumbnail
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.category?.iconData ?? Icons.category_rounded,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Main Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      // Status Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.isAvailable ? AppColors.secondaryLight : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.status,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: item.isAvailable ? AppColors.secondaryDark : Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)} • ${item.conditionLabel}',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),

                                  // Actions Row
                                  Row(
                                    children: [
                                      // Toggle Sold / Available
                                      OutlinedButton(
                                        onPressed: () => _toggleStatus(item),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: const Size(0, 30),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text(
                                          item.isAvailable ? 'Mark as Sold' : 'Mark as Available',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Delete Button
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                        onPressed: () => _deleteListing(item.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
