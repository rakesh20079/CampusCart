import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'auth_screen.dart';
import 'create_listing_screen.dart';
import 'home_feed_screen.dart';
import 'my_listings_screen.dart';
import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainScaffold({super.key, this.onLogout});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<MyListingsScreenState> _myListingsKey = GlobalKey<MyListingsScreenState>();
  final GlobalKey<HomeFeedScreenState> _homeFeedKey = GlobalKey<HomeFeedScreenState>();

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      _myListingsKey.currentState?.reloadListings();
    } else if (index == 0) {
      _homeFeedKey.currentState?.reloadFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeFeedScreen(
        key: _homeFeedKey,
        onOpenProfile: () => _onTabTapped(3),
      ),
      CreateListingScreen(
        onListingCreated: () {
          _onTabTapped(2);
          _myListingsKey.currentState?.reloadListings();
          _homeFeedKey.currentState?.reloadFeed();
        },
      ),
      MyListingsScreen(
        key: _myListingsKey,
        onNavigateToSell: () => _onTabTapped(1),
      ),
      ProfileScreen(
        onLogout: () {
          if (widget.onLogout != null) {
            widget.onLogout!();
          } else {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (authCtx) => AuthScreen(
                  onLoginSuccess: () {
                    Navigator.of(authCtx, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainScaffold()),
                      (route) => false,
                    );
                  },
                ),
              ),
              (route) => false,
            );
          }
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primary),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
              label: 'Sell',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.primary),
              label: 'My Listings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
