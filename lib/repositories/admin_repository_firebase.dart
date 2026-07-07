import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepositoryFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch admin dashboard stats
  Future<Map<String, int>> getAdminStats() async {
    try {
      final totalReports = (await _firestore.collection('reports').count().get()).count ?? 0;
      final pendingReports = (await _firestore.collection('reports').where('status', isEqualTo: 'pending').count().get()).count ?? 0;
      final assignedReports = (await _firestore.collection('reports').where('status', isEqualTo: 'assigned').count().get()).count ?? 0;
      final onRescueReports = (await _firestore.collection('reports').where('status', isEqualTo: 'on rescue').count().get()).count ?? 0;
      final completedReports = (await _firestore.collection('reports').where('status', isEqualTo: 'completed').count().get()).count ?? 0;
      final cancelledReports = (await _firestore.collection('reports').where('status', isEqualTo: 'cancelled').count().get()).count ?? 0;

      final totalReporters = (await _firestore.collection('users').where('role', isEqualTo: 'reporter').count().get()).count ?? 0;
      final totalVolunteers = (await _firestore.collection('users').where('role', isEqualTo: 'volunteer').count().get()).count ?? 0;
      final activeVolunteers = (await _firestore.collection('volunteers').where('isActive', isEqualTo: true).count().get()).count ?? 0;
      final pendingApplications = (await _firestore.collection('volunteer_applications').where('status', isEqualTo: 'pending').count().get()).count ?? 0;

      return {
        'totalReports': totalReports,
        'pendingReports': pendingReports,
        'assignedReports': assignedReports,
        'onRescueReports': onRescueReports,
        'completedReports': completedReports,
        'cancelledReports': cancelledReports,
        'totalReporters': totalReporters,
        'totalVolunteers': totalVolunteers,
        'activeVolunteers': activeVolunteers,
        'pendingApplications': pendingApplications,
      };
    } catch (e) {
      log("Error getting admin stats: ${e.toString()}");
      return {};
    }
  }

  // Fetch all reporters
  Future<List<Map<String, dynamic>>> getAllReporters() async {
    try {
      final query = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'reporter')
          .get();
      
      final list = query.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      list.sort((a, b) => (a['fullName'] as String? ?? '').compareTo(b['fullName'] as String? ?? ''));
      return list;
    } catch (e) {
      log("Error getting reporters: ${e.toString()}");
      return [];
    }
  }

  // Fetch all volunteers
  Future<List<Map<String, dynamic>>> getAllVolunteers() async {
    try {
      final usersQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'volunteer')
          .get();
      
      final volunteersQuery = await _firestore.collection('volunteers').get();
      final volunteerMap = {for (var doc in volunteersQuery.docs) doc.id: doc.data()};

      final List<Map<String, dynamic>> list = [];
      for (var uDoc in usersQuery.docs) {
        final userData = uDoc.data();
        final userId = uDoc.id;
        final volData = volunteerMap[userId] ?? {};
        list.add({
          'id': userId,
          'fullName': userData['fullName'],
          'email': userData['email'],
          'phone': userData['phone'],
          'imgProfile': userData['imgProfile'],
          'isActive': volData['isActive'] ?? false,
          'rescueCount': volData['rescueCount'] ?? 0,
        });
      }
      list.sort((a, b) => (a['fullName'] as String? ?? '').compareTo(b['fullName'] as String? ?? ''));
      return list;
    } catch (e) {
      log("Error getting volunteers: ${e.toString()}");
      return [];
    }
  }

  // Fetch paginated, filtered, and sorted volunteer accounts
  Future<List<Map<String, dynamic>>> getVolunteersPaginated({
    required int limit,
    required int offset,
    String? search,
    String sortBy = 'fullName',
    String sortOrder = 'ASC',
    int? isActiveFilter,
  }) async {
    try {
      final all = await getAllVolunteers();
      List<Map<String, dynamic>> filtered = all;

      if (search != null && search.trim().isNotEmpty) {
        final searchLower = search.trim().toLowerCase();
        filtered = filtered.where((v) {
          final fullName = (v['fullName'] as String? ?? '').toLowerCase();
          final email = (v['email'] as String? ?? '').toLowerCase();
          final phone = (v['phone'] as String? ?? '').toLowerCase();
          return fullName.contains(searchLower) || email.contains(searchLower) || phone.contains(searchLower);
        }).toList();
      }

      if (isActiveFilter != null) {
        final isActiveBool = isActiveFilter == 1;
        filtered = filtered.where((v) {
          final isActiveVal = v['isActive'];
          final bool val = isActiveVal is bool ? isActiveVal : (isActiveVal == 1);
          return val == isActiveBool;
        }).toList();
      }

      filtered.sort((a, b) {
        dynamic valA;
        dynamic valB;
        if (sortBy == 'rescueCount') {
          valA = a['rescueCount'] ?? 0;
          valB = b['rescueCount'] ?? 0;
        } else if (sortBy == 'isActive') {
          final activeA = a['isActive'];
          final activeB = b['isActive'];
          valA = (activeA is bool ? activeA : activeA == 1) ? 1 : 0;
          valB = (activeB is bool ? activeB : activeB == 1) ? 1 : 0;
        } else {
          valA = a['fullName'] as String? ?? '';
          valB = b['fullName'] as String? ?? '';
        }

        if (valA is String && valB is String) {
          return sortOrder.toUpperCase() == 'DESC' ? valB.compareTo(valA) : valA.compareTo(valB);
        } else {
          return sortOrder.toUpperCase() == 'DESC'
              ? (valB as num).compareTo(valA as num)
              : (valA as num).compareTo(valB as num);
        }
      });

      if (offset >= filtered.length) return [];
      final end = (offset + limit) < filtered.length ? (offset + limit) : filtered.length;
      return filtered.sublist(offset, end);
    } catch (e) {
      log("Error getting paginated volunteers: ${e.toString()}");
      return [];
    }
  }

  // Fetch paginated, filtered, and sorted volunteer applications
  Future<List<Map<String, dynamic>>> getVolunteerApplicationsPaginated({
    required int limit,
    required int offset,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
    String? statusFilter,
  }) async {
    try {
      final appsQuery = await _firestore.collection('volunteer_applications').get();
      final usersQuery = await _firestore.collection('users').get();
      final userMap = {for (var doc in usersQuery.docs) doc.id: doc.data()};

      final List<Map<String, dynamic>> list = [];
      for (var doc in appsQuery.docs) {
        final data = doc.data();
        final userId = data['userId'] as String? ?? doc.id;
        final userData = userMap[userId] ?? {};
        list.add({
          'id': doc.id,
          'userId': userId,
          'experience': data['experience'],
          'reason': data['reason'],
          'image1': data['image1'],
          'image2': data['image2'],
          'image3': data['image3'],
          'status': data['status'],
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
          'reviewedAt': data['reviewedAt'],
          'fullName': userData['fullName'],
          'email': userData['email'],
          'phone': userData['phone'],
          'imgProfile': userData['imgProfile'],
        });
      }

      List<Map<String, dynamic>> filtered = list;
      if (search != null && search.trim().isNotEmpty) {
        final searchLower = search.trim().toLowerCase();
        filtered = filtered.where((v) {
          final fullName = (v['fullName'] as String? ?? '').toLowerCase();
          final email = (v['email'] as String? ?? '').toLowerCase();
          final phone = (v['phone'] as String? ?? '').toLowerCase();
          return fullName.contains(searchLower) || email.contains(searchLower) || phone.contains(searchLower);
        }).toList();
      }

      if (statusFilter != null && statusFilter.trim().isNotEmpty) {
        final statusLower = statusFilter.trim().toLowerCase();
        filtered = filtered.where((v) => (v['status'] as String? ?? '').toLowerCase() == statusLower).toList();
      }

      filtered.sort((a, b) {
        dynamic valA;
        dynamic valB;
        if (sortBy == 'status') {
          valA = a['status'] as String? ?? '';
          valB = b['status'] as String? ?? '';
        } else if (sortBy == 'fullName') {
          valA = a['fullName'] as String? ?? '';
          valB = b['fullName'] as String? ?? '';
        } else {
          valA = a['createdAt'] as String? ?? '';
          valB = b['createdAt'] as String? ?? '';
        }

        return sortOrder.toUpperCase() == 'ASC' ? valA.compareTo(valB) : valB.compareTo(valA);
      });

      if (offset >= filtered.length) return [];
      final end = (offset + limit) < filtered.length ? (offset + limit) : filtered.length;
      return filtered.sublist(offset, end);
    } catch (e) {
      log("Error getting paginated volunteer applications: ${e.toString()}");
      return [];
    }
  }

  // Approve or Reject volunteer application with transaction updates
  Future<bool> reviewVolunteerApplication({
    required String applicationId,
    required String userId,
    required String newStatus,
  }) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now().toIso8601String();
      final statusLower = newStatus.toLowerCase();

      // 1. Update application status
      batch.update(_firestore.collection('volunteer_applications').doc(applicationId), {
        'status': statusLower,
        'reviewedAt': now,
        'updatedAt': now,
      });

      // 2. Adjust role & volunteer record based on approval/rejection
      if (statusLower == 'approved') {
        batch.update(_firestore.collection('users').doc(userId), {
          'role': 'volunteer',
          'isVerified': 1,
          'updatedAt': now,
        });

        // Ensure a record exists in volunteers
        batch.set(_firestore.collection('volunteers').doc(userId), {
          'userId': userId,
          'isActive': true,
          'rescueCount': 0,
          'createdAt': now,
          'updatedAt': now,
        }, SetOptions(merge: true));
      } else if (statusLower == 'rejected') {
        batch.update(_firestore.collection('users').doc(userId), {
          'role': 'reporter',
          'updatedAt': now,
        });

        batch.set(_firestore.collection('volunteers').doc(userId), {
          'isActive': false,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }

      await batch.commit();
      return true;
    } catch (e) {
      log("Error reviewing volunteer application: ${e.toString()}");
      return false;
    }
  }
}
