import 'package:flutter/material.dart';
import 'package:w51/core/widgets/app_bottom_navigation.dart';
import 'package:w51/features/inspirations/presentation/pages/inspirations_page.dart';
import 'package:w51/features/home/presentation/pages/home_page.dart';
import 'package:w51/features/package/presentation/store_page.dart';
import 'package:w51/features/my_wedding/presentation/pages/profile_page.dart';
import 'package:w51/features/vendors/presentation/pages/vendor_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _pages = [
    HomePage(),
    VendorPage(),
    StorePage(),
    InspirationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
