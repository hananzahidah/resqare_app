import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/report/detail/detail_report_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final ReportRepository _reportRepository = ReportRepository();
  final MapController _mapController = MapController();

  List<dynamic> _allReports = [];
  List<dynamic> _filteredReports = [];
  bool _isLoading = true;

  // Selected Report for Bottom Info Card
  dynamic _selectedReport;

  // Filters State
  String _searchQuery = "";
  String _selectedStatus = "Semua";
  String _selectedPriority = "Semua";
  String _selectedCategory = "Semua";

  // Carousel PageController
  late final PageController _pageController;

  // Current user GPS coordinates
  LatLng? _userLocation;

  LatLng _currentMapCenter = LatLng(-6.917464, 107.619122);
  // Jakarta default
  bool _isLocatingUser = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadReports();
    _determineInitialPosition();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Load dynamic SQLite reports
      final dbReports = await _reportRepository.getAllReports();

      setState(() {
        _allReports = dbReports;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _determineInitialPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _userLocation = latLng;
          _currentMapCenter = latLng;
        });
        _mapController.move(_currentMapCenter, 14.0);
        _applyFilters();
      }
    } catch (_) {}
  }

  Future<void> _goToMyLocation() async {
    setState(() {
      _isLocatingUser = true;
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = latLng;
        _currentMapCenter = latLng;
        _isLocatingUser = false;
      });
      _mapController.move(latLng, 15.0);
      _applyFilters();

      if (_filteredReports.isNotEmpty && _pageController.hasClients) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      setState(() {
        _isLocatingUser = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendapatkan lokasi GPS saat ini.")),
        );
      }
    }
  }

  double _calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return "${distanceInMeters.toStringAsFixed(0)} m";
    } else {
      double km = distanceInMeters / 1000;
      return "${km.toStringAsFixed(1)} km";
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredReports = _allReports.where((report) {
        final String title = report.title;
        final String desc = report.description;
        final String loc = report.address;
        final String cat = report.animalCategory;
        final String priority = report.priorityLevel;
        final String status = report.status;

        // 1. Search filter
        final matchesSearch =
            title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            desc.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            loc.toLowerCase().contains(_searchQuery.toLowerCase());

        // 2. Status filter
        final matchesStatus = _matchStatus(status, _selectedStatus);

        // 3. Priority filter
        final matchesPriority =
            _selectedPriority == "Semua" ||
            priority.toLowerCase() == _selectedPriority.toLowerCase();

        // 4. Category filter
        bool matchesCategory = _selectedCategory == "Semua";
        if (!matchesCategory) {
          if (_selectedCategory == "Lainnya") {
            matchesCategory = ![
              "kucing",
              "anjing",
              "burung",
              "ular",
            ].contains(cat.toLowerCase());
          } else {
            matchesCategory =
                cat.toLowerCase() == _selectedCategory.toLowerCase();
          }
        }

        return matchesSearch &&
            matchesStatus &&
            matchesPriority &&
            matchesCategory;
      }).toList();

      // Sort by proximity to user location (or map center as fallback)
      final referenceLoc = _userLocation ?? _currentMapCenter;
      _filteredReports.sort((a, b) {
        final distA = _calculateDistance(
          referenceLoc,
          _getReportCoordinates(a),
        );
        final distB = _calculateDistance(
          referenceLoc,
          _getReportCoordinates(b),
        );
        return distA.compareTo(distB);
      });

      // Reset page view index
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }

      if (_filteredReports.isNotEmpty) {
        _selectedReport = _filteredReports.first;
      } else {
        _selectedReport = null;
      }
    });
  }

  LatLng _getReportCoordinates(dynamic report) {
    if (report is ReportModel) {
      return LatLng(report.latitude, report.longitude);
    }
    return LatLng(-6.917464, 107.619122);
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'emergency':
        return AppColors.emergency;
      case 'medium':
        return AppColors.waitingRescue;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.waitingRescue;
      case 'assigned':
        return AppColors.primaryBlue;
      case 'on rescue':
        return AppColors.onRescue;
      case 'completed':
        return AppColors.rescued;
      case 'cancelled':
        return AppColors.emergency;
      default:
        return AppColors.textSecondary;
    }
  }

  bool _matchStatus(String reportStatus, String selectedStatus) {
    if (selectedStatus == 'Semua') return true;
    final rStatus = reportStatus.toLowerCase().trim();
    final sStatus = selectedStatus.toLowerCase().trim();

    if (sStatus == 'pending') {
      return rStatus == 'pending';
    }
    if (sStatus == 'assigned') {
      return rStatus == 'assigned';
    }
    if (sStatus == 'on rescue') {
      return rStatus == 'on rescue';
    }
    if (sStatus == 'completed') {
      return rStatus == 'completed';
    }
    if (sStatus == 'cancelled') {
      return rStatus == 'cancelled';
    }
    return rStatus == sStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MAP VIEW LAYER
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentMapCenter,
                    initialZoom: 14.0,
                    onTap: (_, _) {
                      // Do not clear search/carousel on map tap
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hananzahidah.resqareProject',
                    ),
                    MarkerLayer(
                      markers: [
                        // User location marker
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryBlue.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Report markers
                        ..._filteredReports.map((report) {
                          final latLng = _getReportCoordinates(report);
                          final String priority = report.priorityLevel;
                          final color = _getPriorityColor(priority);

                          final isSelected = _selectedReport == report;

                          return Marker(
                            point: latLng,
                            width: isSelected ? 55 : 44,
                            height: isSelected ? 55 : 44,
                            child: GestureDetector(
                              onTap: () {
                                final index = _filteredReports.indexOf(report);
                                if (index != -1) {
                                  setState(() {
                                    _selectedReport = report;
                                  });
                                  if (_pageController.hasClients) {
                                    _pageController.animateToPage(
                                      index,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                  _mapController.move(
                                    latLng,
                                    _mapController.camera.zoom,
                                  );
                                }
                              },
                              child: AnimatedScale(
                                scale: isSelected ? 1.25 : 1.0,
                                duration: Duration(milliseconds: 200),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Marker Outer Shadow Circle
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color.withOpacity(0.25),
                                      ),
                                    ),
                                    // Marker Inner Color Circle
                                    Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.pets_rounded,
                                        color: Colors.white,
                                        size: isSelected ? 20 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

          // Search & Filter
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: "Cari kasus penyelamatan hewan...",
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = "";
                                  });
                                  _applyFilters();
                                },
                              )
                            : Icon(
                                Icons.map_outlined,
                                color: AppColors.primaryBlue,
                              ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Filters Bar
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: [
                        // 1. Status Filter Button
                        _buildFilterBadge(
                          label: "Status: $_selectedStatus",
                          icon: Icons.flag_rounded,
                          onTap: _showStatusFilterDialog,
                        ),
                        SizedBox(width: 8),

                        // 2. Priority Filter Button
                        _buildFilterBadge(
                          label: "Prioritas: $_selectedPriority",
                          icon: Icons.warning_amber_rounded,
                          onTap: _showPriorityFilterDialog,
                        ),
                        SizedBox(width: 8),

                        // 3. Category Filter Button
                        _buildFilterBadge(
                          label: "Hewan: $_selectedCategory",
                          icon: Icons.pets_rounded,
                          onTap: _showCategoryFilterDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: _filteredReports.isNotEmpty ? 195 : 24,
            child: FloatingActionButton(
              mini: true,
              onPressed: _isLocatingUser ? null : _goToMyLocation,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLocatingUser
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Icon(Icons.my_location_rounded),
            ),
          ),

          // Summary Carousel Report Info
          if (_filteredReports.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              height: 125,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _filteredReports.length,
                onPageChanged: (index) {
                  if (index >= 0 && index < _filteredReports.length) {
                    final report = _filteredReports[index];
                    final latLng = _getReportCoordinates(report);
                    setState(() {
                      _selectedReport = report;
                    });
                    _mapController.move(latLng, _mapController.camera.zoom);
                  }
                },
                itemBuilder: (context, index) {
                  final report = _filteredReports[index];
                  final isSelected = _selectedReport == report;
                  return AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: isSelected ? 1.0 : 0.7,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildReportSummaryCard(report),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Color(0xFFEDEEF1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.primaryBlue),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // Floating summary card layout
  Widget _buildReportSummaryCard(dynamic report) {
    final String title = report.title;
    final String address = report.address;
    final String priority = report.priorityLevel;
    final String status = report.status;

    // Proximity Calculation
    final reportLoc = _getReportCoordinates(report);
    final distanceMeters = _calculateDistance(
      _userLocation ?? _currentMapCenter,
      reportLoc,
    );
    final distanceStr = _formatDistance(distanceMeters);

    // Resolve Image Source
    Widget imageWidget;

    // Fetch DB image, get the first one or placeholder
    imageWidget = FutureBuilder<List<String>>(
      future: _reportRepository.getReportImages(reportId: report.id ?? 0),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final file = File(snapshot.data!.first);
          if (file.existsSync()) {
            return Image.file(file, fit: BoxFit.cover);
          }
        }
        return Container(
          color: AppColors.border,
          child: Icon(
            Icons.image_not_supported_rounded,
            color: AppColors.textSecondary,
          ),
        );
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await context.push(DetailReportScreen(reportId: report.id ?? 0));
              _loadReports();
            },
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  // Animal Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(width: 90, height: 90, child: imageWidget),
                  ),
                  SizedBox(width: 14),

                  // Texts details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),

                        // Badges Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(priority),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Proximity Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.near_me_rounded,
                                    size: 10,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    distanceStr,
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Address Row
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),

                  // Detail indicator arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Filter dialog sheets
  void _showStatusFilterDialog() {
    final list = [
      "Semua",
      "Pending",
      "Assigned",
      "On Rescue",
      "Completed",
      "Cancelled",
    ];
    _showSelectionSheet("Pilih Status", list, _selectedStatus, (val) {
      setState(() {
        _selectedStatus = val;
      });
      _applyFilters();
    });
  }

  void _showPriorityFilterDialog() {
    final list = ["Semua", "Urgent", "Medium", "Low"];
    _showSelectionSheet("Pilih Prioritas", list, _selectedPriority, (val) {
      setState(() {
        _selectedPriority = val;
      });
      _applyFilters();
    });
  }

  void _showCategoryFilterDialog() {
    final list = ["Semua", "Kucing", "Anjing", "Burung", "Ular", "Lainnya"];
    _showSelectionSheet("Pilih Kategori Hewan", list, _selectedCategory, (val) {
      setState(() {
        _selectedCategory = val;
      });
      _applyFilters();
    });
  }

  void _showSelectionSheet(
    String title,
    List<String> options,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 14),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option == currentValue;
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(option);
                        },
                        title: Text(
                          option,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
