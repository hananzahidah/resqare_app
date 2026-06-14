import 'dart:developer';

import 'package:resqare_app/database/db_helper.dart';
import 'package:resqare_app/models/report_model.dart';

class ReportRepository {
  final DBHelper dbHelper = DBHelper();

  // Create Report (returns row ID)
  Future<int> createReport(ReportModel laporan) async {
    final db = await dbHelper.database;
    try {
      return await db.insert('reports', laporan.toMap());
    } catch (e) {
      log(e.toString());
      return -1;
    }
  }

  // Add Report Image
  Future<bool> addReportImage({
    required int reportId,
    required String imagePath,
  }) async {
    final db = await dbHelper.database;
    try {
      await db.insert('report_images', {
        'reportId': reportId,
        'image': imagePath,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Get Images for a Report
  Future<List<String>> getReportImages({required int reportId}) async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'report_images',
        where: 'reportId = ?',
        whereArgs: [reportId],
      );
      return results.map((map) => map['image'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // Update Report
  Future<bool> updateReport({
    required int reportId,
    required Map<String, dynamic> data,
  }) async {
    final db = await dbHelper.database;

    try {
      await db.update('reports', data, where: 'id = ?', whereArgs: [reportId]);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete single report image
  Future<bool> deleteReportImage({
    required int reportId,
    required String imagePath,
  }) async {
    final db = await dbHelper.database;
    try {
      await db.delete(
        'report_images',
        where: 'reportId = ? AND image = ?',
        whereArgs: [reportId, imagePath],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get All Reports Data
  Future<List<ReportModel>> getAllReports() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query('reports');

    return results.map((map) => ReportModel.fromMap(map)).toList();
  }

  // Get Report by ID
  Future<ReportModel?> getReportById({required int reportId}) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'reports',
      where: 'id = ?',
      whereArgs: [reportId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ReportModel.fromMap(result.first);
  }

  // Get All Reports By User
  Future<List<ReportModel>> getUserReports(int userId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      'reports',
      where: 'createdBy = ?',
      whereArgs: [userId],
    );

    return results.map((map) => ReportModel.fromMap(map)).toList();
  }

  // Get active mission for a volunteer
  Future<ReportModel?> getActiveMission(int userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'reports',
      where: 'rescuedBy = ? AND status NOT IN (?, ?, ?, ?, ?, ?)',
      whereArgs: [
        userId,
        'Completed',
        'Rescued',
        'Cancelled',
        'completed',
        'rescued',
        'cancelled',
      ],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (results.isNotEmpty) {
      return ReportModel.fromMap(results.first);
    }
    return null;
  }

  // Get all reports rescued by a volunteer
  Future<List<ReportModel>> getVolunteerReports(int userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'reports',
      where: 'rescuedBy = ?',
      whereArgs: [userId],
    );
    return results.map((map) => ReportModel.fromMap(map)).toList();
  }

  // Get latest 3 reports created by the user
  Future<List<ReportModel>> getMyActiveReports(int userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'reports',
      where: 'createdBy = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
      limit: 3,
    );

    return results.map((map) => ReportModel.fromMap(map)).toList();
  }

  // Get statistics of rescue tasks for a volunteer
  Future<Map<String, int>> getVolunteerStats(int userId) async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'reports',
        columns: ['status'],
        where: 'rescuedBy = ?',
        whereArgs: [userId],
      );

      int total = results.length;
      int completed = 0;
      int active = 0;
      int cancelled = 0;

      for (var row in results) {
        final status = (row['status'] as String).toLowerCase();
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
