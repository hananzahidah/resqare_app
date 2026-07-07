import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqare_app/models/report_model_firebase.dart';

class ReportRepositoryFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Report (returns Firestore document ID)
  Future<String> createReport(ReportModelFirebase laporan) async {
    try {
      final docRef = _firestore.collection('reports').doc();
      final reportToSave = laporan.copyWith(id: docRef.id);
      await docRef.set(reportToSave.toMap());
      return docRef.id;
    } catch (e) {
      log("Error creating report: ${e.toString()}");
      return "";
    }
  }

  // Add Report Image
  Future<bool> addReportImage({
    required String reportId,
    required String imagePath,
  }) async {
    try {
      await _firestore.collection('report_images').add({
        'reportId': reportId,
        'image': imagePath,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      log("Error adding report image: ${e.toString()}");
      return false;
    }
  }

  // Get Images for a Report
  Future<List<String>> getReportImages({required String reportId}) async {
    try {
      final query = await _firestore
          .collection('report_images')
          .where('reportId', isEqualTo: reportId)
          .get();
      
      return query.docs.map((doc) => doc.data()['image'] as String).toList();
    } catch (e) {
      log("Error getting report images: ${e.toString()}");
      return [];
    }
  }

  // Update Report
  Future<bool> updateReport({
    required String reportId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('reports').doc(reportId).update(data);
      return true;
    } catch (e) {
      log("Error updating report: ${e.toString()}");
      return false;
    }
  }

  // Delete single report image
  Future<bool> deleteReportImage({
    required String reportId,
    required String imagePath,
  }) async {
    try {
      final query = await _firestore
          .collection('report_images')
          .where('reportId', isEqualTo: reportId)
          .where('image', isEqualTo: imagePath)
          .get();
      
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      log("Error deleting report image: ${e.toString()}");
      return false;
    }
  }

  // Get All Reports Data
  Future<List<ReportModelFirebase>> getAllReports() async {
    try {
      final query = await _firestore.collection('reports').get();
      return query.docs.map((doc) => ReportModelFirebase.fromFirestore(doc)).toList();
    } catch (e) {
      log("Error getting all reports: ${e.toString()}");
      return [];
    }
  }

  // Get Report by ID
  Future<ReportModelFirebase?> getReportById({required String reportId}) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      if (doc.exists) {
        return ReportModelFirebase.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      log("Error getting report by id: ${e.toString()}");
      return null;
    }
  }

  // Get All Reports By User
  Future<List<ReportModelFirebase>> getUserReports(String userId) async {
    try {
      final query = await _firestore
          .collection('reports')
          .where('createdBy', isEqualTo: userId)
          .get();
      
      return query.docs.map((doc) => ReportModelFirebase.fromFirestore(doc)).toList();
    } catch (e) {
      log("Error getting user reports: ${e.toString()}");
      return [];
    }
  }

  // Get active mission for a volunteer
  Future<ReportModelFirebase?> getActiveMission(String userId) async {
    try {
      final query = await _firestore
          .collection('reports')
          .where('rescuedBy', isEqualTo: userId)
          .get();
      
      final activeReports = query.docs
          .map((doc) => ReportModelFirebase.fromFirestore(doc))
          .where((report) {
            final status = report.status.toLowerCase();
            return status != 'completed' &&
                   status != 'rescued' &&
                   status != 'cancelled';
          })
          .toList();

      if (activeReports.isNotEmpty) {
        activeReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return activeReports.first;
      }
      return null;
    } catch (e) {
      log("Error getting active mission: ${e.toString()}");
      return null;
    }
  }

  // Get all reports rescued by a volunteer
  Future<List<ReportModelFirebase>> getVolunteerReports(String userId) async {
    try {
      final query = await _firestore
          .collection('reports')
          .where('rescuedBy', isEqualTo: userId)
          .get();
      
      return query.docs.map((doc) => ReportModelFirebase.fromFirestore(doc)).toList();
    } catch (e) {
      log("Error getting volunteer reports: ${e.toString()}");
      return [];
    }
  }

  // Get latest 3 reports created by the user
  Future<List<ReportModelFirebase>> getMyActiveReports(String userId) async {
    try {
      final query = await _firestore
          .collection('reports')
          .where('createdBy', isEqualTo: userId)
          .get();
      
      final reports = query.docs.map((doc) => ReportModelFirebase.fromFirestore(doc)).toList();
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports.take(3).toList();
    } catch (e) {
      log("Error getting my active reports: ${e.toString()}");
      return [];
    }
  }

  // Get statistics of rescue tasks for a volunteer
  Future<Map<String, int>> getVolunteerStats(String userId) async {
    try {
      final query = await _firestore
          .collection('reports')
          .where('rescuedBy', isEqualTo: userId)
          .get();

      int total = query.docs.length;
      int completed = 0;
      int active = 0;
      int cancelled = 0;

      for (var doc in query.docs) {
        final status = (doc.data()['status'] as String? ?? '').toLowerCase();
        if (status == 'completed' || status == 'rescued') {
          completed++;
        } else if (status == 'cancelled') {
          cancelled++;
        } else if (status == 'on rescue' || status == 'assigned') {
          active++;
        }
      }

      return {
        'total': total,
        'completed': completed,
        'active': active,
        'cancelled': cancelled,
      };
    } catch (e) {
      log("Error getting volunteer stats: ${e.toString()}");
      return {'total': 0, 'completed': 0, 'active': 0, 'cancelled': 0};
    }
  }
}
