import 'package:flutter/material.dart';
import 'package:resqare_app/views/home/home_wrapper_screen.dart';
import 'package:resqare_app/views/profile/profile_screen.dart';

class BottomNavigator extends StatefulWidget {
  final int initialIndex;

  const BottomNavigator({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  late int _selectedIndex;

  static const List<Widget> _widgetOptions = <Widget>[
    RoleHomeWrapper(),
    RoleHomeWrapper(),
    RoleHomeWrapper(),
    RoleHomeWrapper(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleBack() {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color.fromARGB(160, 237, 238, 241),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_filled,
                    outlineIcon: Icons.home_outlined,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.map_rounded,
                    outlineIcon: Icons.map_outlined,
                    label: 'Explore',
                    index: 1,
                  ),

                  _buildCenterAddButton(),

                  _buildNavItem(
                    icon: Icons.history_rounded,
                    outlineIcon: Icons.history_outlined,
                    label: 'History',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    outlineIcon: Icons.person_outline_rounded,
                    label: 'Profile',
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Desain Icon biasa dengan Teks
  Widget _buildNavItem({
    required IconData icon,
    required IconData outlineIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF327AF4) : Colors.grey.shade400;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? icon : outlineIcon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(2),
        child: Center(
          child: Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF327AF4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D327AF4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
