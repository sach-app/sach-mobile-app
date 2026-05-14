import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_strings.dart';
import 'app_nav.dart';
import 'dashboard_screen.dart';
import 'my_firs_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MyFirsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animationController.forward();
    appTabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    appTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _animationController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDeep,
      body: FadeTransition(
        opacity: _animationController,
        child: IndexedStack(
          index: appTabNotifier.value,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, S.home),
      (Icons.folder_open_rounded, S.myFirs),
      (Icons.notifications_rounded, S.alerts),
      (Icons.person_rounded, S.profile),
    ];
    final selectedTab = appTabNotifier.value;
    
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        border: const Border(top: BorderSide(color: kDivider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = selectedTab == i;
              return GestureDetector(
                onTap: () {
                  appTabNotifier.value = i;
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? kGreen.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$1,
                        color: selected ? kGold : kTextSub,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          color: selected ? kGold : kTextSub,
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
