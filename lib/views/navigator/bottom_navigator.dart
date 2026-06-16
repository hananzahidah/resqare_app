import 'package:flutter/material.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/views/admin/dashboard/admin_dashboard_screen.dart';
import 'package:resqare_app/views/admin/volunteer/admin_volunteers_screen.dart';
import 'package:resqare_app/views/explore/explore_map_screen.dart';
import 'package:resqare_app/views/history/role_history_wrapper.dart';
import 'package:resqare_app/views/home/home_wrapper_screen.dart';
import 'package:resqare_app/views/profile/profile_screen.dart';
import 'package:resqare_app/views/report/create/form_report_screen.dart';

class BottomNavigator extends StatefulWidget {
  final int initialIndex;

  const BottomNavigator({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  late int _selectedIndex;
  final List<int> _reloadCounters = [0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      setState(() {
        _reloadCounters[index]++;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
    final bool isAdmin = PreferenceHandler.userRole.toLowerCase() == 'admin';

    final List<Widget> pages = isAdmin
        ? [
            AdminDashboardScreen(
              isActive: _selectedIndex == 0,
              key: ValueKey('admin_dashboard_${_reloadCounters[0]}'),
            ),
            ExploreMapScreen(key: ValueKey('explore_${_reloadCounters[1]}')),
            AdminVolunteersScreen(
              key: ValueKey('admin_volunteers_${_reloadCounters[2]}'),
            ),

            ProfileScreen(
              isActive: _selectedIndex == 3,
              key: ValueKey('profile_${_reloadCounters[4]}'),
            ),
          ]
        : [
            RoleHomeWrapper(
              isActive: _selectedIndex == 0,
              key: ValueKey('home_${_reloadCounters[0]}'),
            ),
            ExploreMapScreen(key: ValueKey('explore_${_reloadCounters[1]}')),
            FormReportScreen(key: ValueKey('form_${_reloadCounters[2]}')),
            RoleHistoryWrapper(key: ValueKey('history_${_reloadCounters[3]}')),
            ProfileScreen(
              isActive: _selectedIndex == 4,
              key: ValueKey('profile_${_reloadCounters[4]}'),
            ),
          ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),

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
                children: isAdmin
                    ? [
                        _buildNavItem(
                          icon: Icons.dashboard_rounded,
                          outlineIcon: Icons.dashboard_outlined,
                          label: 'Dashboard',
                          index: 0,
                        ),
                        _buildNavItem(
                          icon: Icons.assignment_rounded,
                          outlineIcon: Icons.assignment_outlined,
                          label: 'Report',
                          index: 1,
                        ),
                        _buildNavItem(
                          icon: Icons.people_rounded,
                          outlineIcon: Icons.people_outline_rounded,
                          label: 'Relawan',
                          index: 2,
                        ),
                        _buildNavItem(
                          icon: Icons.person_rounded,
                          outlineIcon: Icons.person_outline_rounded,
                          label: 'Profile',
                          index: 3,
                        ),
                      ]
                    : [
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
