import 'package:flutter/material.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/views/history/report_history_screen.dart';
import 'package:resqare_app/views/history/rescue_history_screen.dart';

class RoleHistoryWrapper extends StatefulWidget {
  const RoleHistoryWrapper({super.key});

  @override
  State<RoleHistoryWrapper> createState() => _RoleHistoryWrapperState();
}

class _RoleHistoryWrapperState extends State<RoleHistoryWrapper> {
  final UserRepository _userRepository = UserRepository();
  bool _isVolunteer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final userId = PreferenceHandler.userId;
      if (userId > 0) {
        final user = await _userRepository.getUserById(userId);
        if (user != null) {
          setState(() {
            _isVolunteer = user.role.toLowerCase() == 'volunteer';
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isVolunteer
        ? const RescueHistoryScreen()
        : const ReportHistoryScreen();
  }
}
