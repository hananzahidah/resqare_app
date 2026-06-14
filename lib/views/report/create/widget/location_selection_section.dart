import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqare_app/constant/app_color.dart';

class LocationSelectionSection extends StatelessWidget {
  final Position? currentPosition;
  final String locationAddress;
  final bool isLoadingLocation;
  final MapController mapController;
  final VoidCallback onLoadLocationTap;

  const LocationSelectionSection({
    super.key,
    required this.currentPosition,
    required this.locationAddress,
    required this.isLoadingLocation,
    required this.mapController,
    required this.onLoadLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEDEEF1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Lokasi Penemuan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: isLoadingLocation ? null : onLoadLocationTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                icon: const Icon(
                  Icons.my_location_rounded,
                  size: 12,
                  color: AppColors.primaryBlue,
                ),
                label: const Text(
                  "Cari Lokasi",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (isLoadingLocation)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              ),
            )
          else if (currentPosition == null)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_rounded,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Peta belum memuat lokasi Anda",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onLoadLocationTap,
                      child: const Text(
                        "Muat Lokasi GPS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 160,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                    ),
                    initialZoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hananzahidah.resqareProject',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            currentPosition!.latitude,
                            currentPosition!.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),
          const Text(
            "Alamat Penemuan:",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            locationAddress,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
