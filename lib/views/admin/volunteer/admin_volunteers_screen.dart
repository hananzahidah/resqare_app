import 'dart:async';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/repositories/admin_repository.dart';
import 'package:resqare_app/utils/date_formater.dart';
import 'package:resqare_app/views/admin/volunteer/volunteer_application_detail_screen.dart';

class AdminVolunteersScreen extends StatefulWidget {
  const AdminVolunteersScreen({super.key});

  @override
  State<AdminVolunteersScreen> createState() => _AdminVolunteersScreenState();
}

class _AdminVolunteersScreenState extends State<AdminVolunteersScreen>
    with SingleTickerProviderStateMixin {
  final AdminRepository _adminRepository = AdminRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _activeTab = 0;

  // Pagination states for Volunteer Accounts
  final List<Map<String, dynamic>> _volunteers = [];
  bool _isLoadingVolunteers = false;
  int _volunteersOffset = 0;
  bool _hasMoreVolunteers = true;

  // Pagination states for Volunteer Applications
  final List<Map<String, dynamic>> _applications = [];
  bool _isLoadingApplications = false;
  int _applicationsOffset = 0;
  bool _hasMoreApplications = true;

  static const int _limit = 10;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  void _loadFirstPage() {
    if (_activeTab == 0) {
      setState(() {
        _volunteers.clear();
        _volunteersOffset = 0;
        _hasMoreVolunteers = true;
      });
      _fetchVolunteers();
    } else {
      setState(() {
        _applications.clear();
        _applicationsOffset = 0;
        _hasMoreApplications = true;
      });
      _fetchApplications();
    }
  }

  void _loadNextPage() {
    if (_activeTab == 0) {
      if (!_isLoadingVolunteers && _hasMoreVolunteers) {
        _fetchVolunteers();
      }
    } else {
      if (!_isLoadingApplications && _hasMoreApplications) {
        _fetchApplications();
      }
    }
  }

  Future<void> _fetchVolunteers() async {
    if (_isLoadingVolunteers) return;
    setState(() {
      _isLoadingVolunteers = true;
    });

    final results = await _adminRepository.getVolunteersPaginated(
      limit: _limit,
      offset: _volunteersOffset,
      search: _searchQuery,
    );

    if (mounted) {
      setState(() {
        _isLoadingVolunteers = false;
        if (results.length < _limit) {
          _hasMoreVolunteers = false;
        }
        _volunteers.addAll(results);
        _volunteersOffset += results.length;
      });
    }
  }

  Future<void> _fetchApplications() async {
    if (_isLoadingApplications) return;
    setState(() {
      _isLoadingApplications = true;
    });

    final results = await _adminRepository.getVolunteerApplicationsPaginated(
      limit: _limit,
      offset: _applicationsOffset,
      search: _searchQuery,
    );

    if (mounted) {
      setState(() {
        _isLoadingApplications = false;
        if (results.length < _limit) {
          _hasMoreApplications = false;
        }
        _applications.addAll(results);
        _applicationsOffset += results.length;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });
      _loadFirstPage();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _loadFirstPage();
  }

  void _toggleTab(int index) {
    if (_activeTab == index) return;
    setState(() {
      _activeTab = index;
    });
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Kelola Relawan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Upper Tab selector menu
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleTab(0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeTab == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Akun Relawan",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 0
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleTab(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeTab == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Pengajuan",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 1
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _activeTab == 0
                            ? "Cari nama, email, telepon..."
                            : "Cari pelamar...",
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          // Main Paginated List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadFirstPage();
              },
              color: AppColors.primaryBlue,
              child: _buildListContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    final bool isEmpty = _activeTab == 0
        ? _volunteers.isEmpty
        : _applications.isEmpty;
    final bool isLoading = _activeTab == 0
        ? _isLoadingVolunteers
        : _isLoadingApplications;

    if (isEmpty && !isLoading) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  color: Colors.grey.shade400,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Tidak Ada Data Ditemukan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan ubah kata pencarian untuk melihat data.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    final int itemCount = _activeTab == 0
        ? _volunteers.length
        : _applications.length;
    final bool hasMore = _activeTab == 0
        ? _hasMoreVolunteers
        : _hasMoreApplications;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: itemCount + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == itemCount) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            ),
          );
        }

        if (_activeTab == 0) {
          final volunteer = _volunteers[index];
          return _buildVolunteerCard(volunteer);
        } else {
          final application = _applications[index];
          return _buildApplicationCard(application);
        }
      },
    );
  }

  Widget _buildVolunteerCard(Map<String, dynamic> volunteer) {
    final String fullName = volunteer['fullName'] ?? '-';
    final String email = volunteer['email'] ?? '-';
    final String phone = volunteer['phone'] ?? '-';
    final int rescueCount = volunteer['rescueCount'] ?? 0;
    final bool isActive = (volunteer['isActive'] ?? 0) == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Volunteer Profile Icon
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          // Info Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Telp: $phone",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Rescue Count & Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$rescueCount Rescue",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryBlue.withOpacity(0.12)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryBlue.withOpacity(0.2)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  isActive ? "Aktif" : "Non-aktif",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final String fullName = app['fullName'] ?? '-';
    final String dateString = app['createdAt'] ?? '';
    final String status = (app['status'] as String).toLowerCase();

    Color statusColor;
    String statusText;
    switch (status) {
      case 'pending':
        statusColor = AppColors.waitingRescue;
        statusText = "Pending";
        break;
      case 'approved':
        statusColor = AppColors.success;
        statusText = "Disetujui";
        break;
      case 'rejected':
        statusColor = AppColors.emergency;
        statusText = "Ditolak";
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VolunteerApplicationDetailScreen(application: app),
          ),
        ).then((updated) {
          if (updated == true) {
            _loadFirstPage();
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Application Icon Badge
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_ind_rounded,
                color: statusColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            // Applicant Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateString.isNotEmpty
                        ? "Diajukan: ${DateFormatter.toReadableDateTime(dateString)}"
                        : '-',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Small reason/experience
                  Text(
                    "Alasan: ${app['reason'] ?? '-'}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Status Badge & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
