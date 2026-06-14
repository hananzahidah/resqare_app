import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsSection extends StatefulWidget {
  final ReportModel report;

  const MapsSection({super.key, required this.report});

  @override
  State<MapsSection> createState() => _MapsSectionState();
}

class _MapsSectionState extends State<MapsSection> {
  LatLng _mapCenter = LatLng(-6.2088, 106.8456); // Fallback: Jakarta Pusat
  bool _isLoadingMap = true;

  @override
  void initState() {
    super.initState();
    loadMaps();
  }

  Future<void> loadMaps() async {
    // Geocode the address
    try {
      List<Location> locations = await locationFromAddress(
        widget.report.address,
      );
      if (locations.isNotEmpty) {
        setState(() {
          _mapCenter = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _isLoadingMap = false;
        });
      } else {
        setState(() {
          _isLoadingMap = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoadingMap = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Maps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lokasi Laporan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () async {
                final double lat = widget.report.latitude;
                final double lng = widget.report.longitude;

                final Uri googleMapsUrl = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                );

                try {
                  if (!await launchUrl(
                    googleMapsUrl,
                    mode: LaunchMode.externalApplication,
                  )) {
                    debugPrint('Tidak dapat membuka Google Maps');
                  }
                } catch (e) {
                  debugPrint('Error: $e');
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.directions_rounded,
                size: 14,
                color: AppColors.primaryBlue,
              ),
              label: Text(
                "Buka di Maps",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Map Display
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFEDEEF1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _isLoadingMap
                ? Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: _mapCenter,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.hananzahidah.resqareProject',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _mapCenter,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                              size: 38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 8),

        // Text Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_pin, size: 14, color: AppColors.primaryBlue),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.report.address,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 50),
      ],
    );
  }
}
