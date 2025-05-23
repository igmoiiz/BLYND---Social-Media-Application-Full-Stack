// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:social_media/View/Interface/Feed/interface_page.dart';
import 'package:social_media/View/Interface/Post/post_page.dart';
import 'package:social_media/View/Interface/Profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _tabController;

  final List<Widget> _pages = [
    InterfacePage(),
    Center(child: Text('Search')),
    CreatePostPage(),
    Center(child: Text('Notifications')),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white10.withOpacity(0.2)
                        : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.white70,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home, index: 0),
                  _buildNavItem(icon: Icons.search, index: 1),
                  _buildNavItem(icon: Icons.add_box_rounded, index: 2),
                  _buildNavItem(icon: Icons.notifications, index: 3),
                  _buildNavItem(icon: Icons.person, index: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = _selectedIndex == index;
    final color =
        isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary.withOpacity(0.5);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
