import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/repositories/user_repository.dart';

class LocationCardSection extends StatefulWidget {
  final VoidCallback? onLocationUpdated;
  const LocationCardSection({super.key, this.onLocationUpdated});

  @override
  State<LocationCardSection> createState() => _LocationCardSectionState();
}

class _LocationCardSectionState extends State<LocationCardSection> {
  bool _isLoadingLocation = true;
  String _currentAddress = "Mendeteksi lokasi...";
  final UserRepository _userRepository = UserRepository();
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _finishLoading(String address) {
    if (mounted) {
      setState(() {
        _currentAddress = address;
        _isLoadingLocation = false;
      });
      widget.onLocationUpdated?.call();
    }
  }

  void _useFallback(double? savedLat, double? savedLng) {
    if (savedLat != null && savedLng != null) {
      latitude = savedLat;
      longitude = savedLng;

      placemarkFromCoordinates(savedLat, savedLng)
          .timeout(Duration(seconds: 3))
          .then((placemarks) {
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              final addressParts = [
                if (place.street != null && place.street!.isNotEmpty)
                  place.street,
                if (place.subLocality != null && place.subLocality!.isNotEmpty)
                  place.subLocality,
                if (place.locality != null && place.locality!.isNotEmpty)
                  place.locality,
                if (place.subAdministrativeArea != null &&
                    place.subAdministrativeArea!.isNotEmpty)
                  place.subAdministrativeArea,
              ];
              _finishLoading("${addressParts.join(', ')} (Terakhir Disimpan)");
            } else {
              _finishLoading(
                "${savedLat.toStringAsFixed(5)}, ${savedLng.toStringAsFixed(5)} (Terakhir Disimpan)",
              );
            }
          })
          .catchError((_) {
            _finishLoading(
              "${savedLat.toStringAsFixed(5)}, ${savedLng.toStringAsFixed(5)} (Terakhir Disimpan - Offline)",
            );
          });
    } else {
      _finishLoading("Lokasi tidak diketahui (Aktifkan GPS & Internet)");
    }
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
        _currentAddress = "Mendeteksi lokasi...";
      });
    }

    final userId = PreferenceHandler.userId;
    double? savedLat;
    double? savedLng;

    if (userId > 0) {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        savedLat = user.currentLatitude;
        savedLng = user.currentLongitude;
      }
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );

        latitude = position.latitude;
        longitude = position.longitude;

        if (userId > 0) {
          await _userRepository.updateUser(
            userId: userId,
            data: {
              'currentLatitude': position.latitude,
              'currentLongitude': position.longitude,
            },
          );
        }

        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(Duration(seconds: 3));
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final addressParts = [
              if (place.street != null && place.street!.isNotEmpty)
                place.street,
              if (place.subLocality != null && place.subLocality!.isNotEmpty)
                place.subLocality,
              if (place.locality != null && place.locality!.isNotEmpty)
                place.locality,
              if (place.subAdministrativeArea != null &&
                  place.subAdministrativeArea!.isNotEmpty)
                place.subAdministrativeArea,
            ];
            _finishLoading(addressParts.join(', '));
          } else {
            _finishLoading(
              "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}",
            );
          }
        } catch (_) {
          _finishLoading(
            "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)} (Offline)",
          );
        }
      } else {
        _useFallback(savedLat, savedLng);
      }
    } catch (_) {
      _useFallback(savedLat, savedLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,

        // color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primaryBlue,
                      size: 14,
                    ),
                    Text(
                      "Lokasi Anda Saat Ini",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                _isLoadingLocation
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Mencari lokasi...",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentAddress,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
    );
  }
}
