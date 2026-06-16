import 'package:flutter/material.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/auth/login_screen.dart';
import 'package:resqare_app/views/home/reporter_home_screen.dart';
import 'package:resqare_app/views/home/volunteer_home_screen.dart';

class RoleHomeWrapper extends StatefulWidget {
  final bool isActive;
  const RoleHomeWrapper({super.key, this.isActive = false});

  @override
  State<RoleHomeWrapper> createState() => _RoleHomeWrapperState();
}

class _RoleHomeWrapperState extends State<RoleHomeWrapper> {
  final UserRepository _userRepository = UserRepository();
  bool _isVolunteer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  @override
  void didUpdateWidget(covariant RoleHomeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _checkUserRole();
    }
  }

  Future<void> _checkUserRole() async {
    try {
      final userId = PreferenceHandler.userId;

      if (userId <= 0) {
        setState(() => _isLoading = false);
        return;
      }

      final user = await _userRepository.getUserById(userId);

      if (!mounted) return;

      if (user == null) {
        await PreferenceHandler.logOut();

        if (!mounted) return;

        context.pushReplacement(LoginScreen());
        return;
      }

      setState(() {
        _isVolunteer = user.role.toLowerCase() == 'volunteer';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error check user role: $e");

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _isVolunteer
          ? VolunteerHomeScreen(isActive: widget.isActive)
          : ReporterHomeScreen(isActive: widget.isActive),
    );
  }
}
