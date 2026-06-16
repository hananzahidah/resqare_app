import 'dart:developer';
import 'package:resqare_app/database/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class AdminRepository {
  final DBHelper dbHelper = DBHelper();

  // Fetch admin dashboard stats
  Future<Map<String, int>> getAdminStats() async {
    final db = await dbHelper.database;
    try {
      final totalReports = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM reports'),
          ) ??
          0;
      final pendingReports = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM reports WHERE status = 'pending'",
            ),
          ) ??
          0;
      final assignedReports = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM reports WHERE status = 'assigned'",
            ),
          ) ??
          0;
      final onRescueReports = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM reports WHERE status = 'on rescue'",
            ),
          ) ??
          0;
      final completedReports = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM reports WHERE status = 'completed'",
            ),
          ) ??
          0;
      final cancelledReports = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM reports WHERE status = 'cancelled'",
            ),
          ) ??
          0;

      final totalReporters = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM users WHERE role = 'reporter'",
            ),
          ) ??
          0;
      final totalVolunteers = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM users WHERE role = 'volunteer'",
            ),
          ) ??
          0;
      final activeVolunteers = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM volunteers WHERE isActive = 1",
            ),
          ) ??
          0;
      final pendingApplications = Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM volunteer_applications WHERE status = 'pending'",
            ),
          ) ??
          0;

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
    final db = await dbHelper.database;
    try {
      return await db.query(
        'users',
        where: "role = 'reporter'",
        orderBy: 'fullName ASC',
      );
    } catch (e) {
      log("Error getting reporters: ${e.toString()}");
      return [];
    }
  }

  // Fetch all volunteers
  Future<List<Map<String, dynamic>>> getAllVolunteers() async {
    final db = await dbHelper.database;
    try {
      return await db.rawQuery('''
        SELECT u.id, u.fullName, u.email, u.phone, u.imgProfile, v.isActive, v.rescueCount
        FROM users u
        INNER JOIN volunteers v ON u.id = v.userId
        WHERE u.role = 'volunteer'
        ORDER BY u.fullName ASC
      ''');
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
    final db = await dbHelper.database;
    try {
      List<String> whereClauses = ["u.role = 'volunteer'"];
      List<dynamic> whereArgs = [];

      if (search != null && search.trim().isNotEmpty) {
        whereClauses.add("(u.fullName LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)");
        final searchPattern = "%${search.trim()}%";
        whereArgs.addAll([searchPattern, searchPattern, searchPattern]);
      }

      if (isActiveFilter != null) {
        whereClauses.add("v.isActive = ?");
        whereArgs.add(isActiveFilter);
      }

      String whereString = "WHERE ${whereClauses.join(' AND ')}";
      
      String sortColumn;
      if (sortBy == 'rescueCount') {
        sortColumn = 'v.rescueCount';
      } else if (sortBy == 'isActive') {
        sortColumn = 'v.isActive';
      } else {
        sortColumn = 'u.fullName';
      }
      
      String orderClause = "ORDER BY $sortColumn ${sortOrder.toUpperCase() == 'DESC' ? 'DESC' : 'ASC'}";

      final query = '''
        SELECT u.id, u.fullName, u.email, u.phone, u.imgProfile, v.isActive, v.rescueCount
        FROM users u
        INNER JOIN volunteers v ON u.id = v.userId
        $whereString
        $orderClause
        LIMIT ? OFFSET ?
      ''';
      
      whereArgs.addAll([limit, offset]);
      return await db.rawQuery(query, whereArgs);
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
    final db = await dbHelper.database;
    try {
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [];

      if (search != null && search.trim().isNotEmpty) {
        whereClauses.add("(u.fullName LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)");
        final searchPattern = "%${search.trim()}%";
        whereArgs.addAll([searchPattern, searchPattern, searchPattern]);
      }

      if (statusFilter != null && statusFilter.trim().isNotEmpty) {
        whereClauses.add("app.status = ?");
        whereArgs.add(statusFilter.trim().toLowerCase());
      }

      String whereString = whereClauses.isNotEmpty ? "WHERE ${whereClauses.join(' AND ')}" : "";
      
      String sortColumn;
      if (sortBy == 'status') {
        sortColumn = 'app.status';
      } else if (sortBy == 'fullName') {
        sortColumn = 'u.fullName';
      } else {
        sortColumn = 'app.createdAt';
      }
      
      String orderClause = "ORDER BY $sortColumn ${sortOrder.toUpperCase() == 'ASC' ? 'ASC' : 'DESC'}";

      final query = '''
        SELECT app.id, app.userId, app.experience, app.reason, 
               app.image1, app.image2, app.image3, app.status, 
               app.createdAt, app.updatedAt, app.reviewedAt,
               u.fullName, u.email, u.phone, u.imgProfile
        FROM volunteer_applications app
        INNER JOIN users u ON app.userId = u.id
        $whereString
        $orderClause
        LIMIT ? OFFSET ?
      ''';
      
      whereArgs.addAll([limit, offset]);
      return await db.rawQuery(query, whereArgs);
    } catch (e) {
      log("Error getting paginated volunteer applications: ${e.toString()}");
      return [];
    }
  }

  // Approve or Reject volunteer application with transaction updates
  Future<bool> reviewVolunteerApplication({
    required int applicationId,
    required int userId,
    required String newStatus,
  }) async {
    final db = await dbHelper.database;
    try {
      return await db.transaction((txn) async {
        final now = DateTime.now().toIso8601String();
        final statusLower = newStatus.toLowerCase();
        
        // 1. Update application status
        await txn.update(
          'volunteer_applications',
          {
            'status': statusLower,
            'reviewedAt': now,
            'updatedAt': now,
          },
          where: 'id = ?',
          whereArgs: [applicationId],
        );
        
        // 2. Adjust role & volunteer record based on approval/rejection
        if (statusLower == 'approved') {
          // Update user to volunteer and verified
          await txn.update(
            'users',
            {
              'role': 'volunteer',
              'isVerified': 1,
              'updatedAt': now,
            },
            where: 'id = ?',
            whereArgs: [userId],
          );
          
          // Ensure a record exists in the volunteers table
          final existing = await txn.query(
            'volunteers',
            where: 'userId = ?',
            whereArgs: [userId],
            limit: 1,
          );
          
          if (existing.isEmpty) {
            await txn.insert('volunteers', {
              'userId': userId,
              'isActive': 1,
              'rescueCount': 0,
              'createdAt': now,
              'updatedAt': now,
            });
          } else {
            await txn.update(
              'volunteers',
              {
                'isActive': 1,
                'updatedAt': now,
              },
              where: 'userId = ?',
              whereArgs: [userId],
            );
          }
        } else if (statusLower == 'rejected') {
          // Reset/keep user as reporter
          await txn.update(
            'users',
            {
              'role': 'reporter',
              'updatedAt': now,
            },
            where: 'id = ?',
            whereArgs: [userId],
          );
          
          // Set volunteer record to inactive if it exists
          await txn.update(
            'volunteers',
            {
              'isActive': 0,
              'updatedAt': now,
            },
            where: 'userId = ?',
            whereArgs: [userId],
          );
        }
        
        return true;
      });
    } catch (e) {
      log("Error reviewing volunteer application: ${e.toString()}");
      return false;
    }
  }
}
