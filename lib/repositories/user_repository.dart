import 'dart:developer';

import 'package:resqare_app/database/db_helper.dart';
import 'package:resqare_app/models/login_model.dart';
import 'package:resqare_app/models/user_model_sql.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final DBHelper dbHelper = DBHelper();

  // Register New User
  Future<bool> registerUser(UserModelSql pengguna) async {
    final db = await dbHelper.database;
    try {
      await db.insert('users', pengguna.toMap());
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Check Existing Email
  Future<bool> checkEmailExists(String email) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  // Check Existing Phone
  Future<bool> checkPhoneExists(String phone) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
    );

    return result.isNotEmpty;
  }

  // Login User
  Future<UserModelSql?> loginUser(LoginModel pengguna) async {
    final db = await dbHelper.database;

    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [pengguna.email, pengguna.password],
    );

    if (results.isNotEmpty) {
      return UserModelSql.fromMap(results.first);
    }

    return null;
  }

  // Upadate User
  Future<bool> updateUser({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final db = await dbHelper.database;

    try {
      await db.update('users', data, where: 'id = ?', whereArgs: [userId]);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get User by ID
  Future<UserModelSql?> getUserById(int userId) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModelSql.fromMap(result.first);
  }

  // Legacy name for Get User by ID (kept for safety if needed, though unused)
  Future<UserModelSql?> getReport({required int reportId}) async {
    return getUserById(reportId);
  }

  // Get user contribution and rescue stats
  Future<Map<String, int>> getUserStats(int userId) async {
    final db = await dbHelper.database;
    try {
      final reportCountRes = await db.rawQuery(
        'SELECT COUNT(*) as count FROM reports WHERE createdBy = ?',
        [userId],
      );
      final volunteerRes = await db.query(
        'volunteers',
        where: 'userId = ?',
        whereArgs: [userId],
        limit: 1,
      );
      int reportsCreated = Sqflite.firstIntValue(reportCountRes) ?? 0;
      int rescueCount = 0;
      if (volunteerRes.isNotEmpty) {
        rescueCount = volunteerRes.first['rescueCount'] as int? ?? 0;
      }
      return {'reportsCreated': reportsCreated, 'rescueCount': rescueCount};
    } catch (e) {
      return {'reportsCreated': 0, 'rescueCount': 0};
    }
  }

  // Get volunteer status
  Future<String?> getVolunteerStatus(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'volunteers',
      columns: ['status'],
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['status'] as String?;
    }
    return null;
  }

  // Update volunteer status
  Future<bool> updateVolunteerStatus(int userId, String status) async {
    final db = await dbHelper.database;
    try {
      final rows = await db.update(
        'volunteers',
        {'status': status},
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return rows > 0;
    } catch (e) {
      return false;
    }
  }

  // Increment volunteer rescue count
  Future<bool> incrementVolunteerRescueCount(int userId) async {
    final db = await dbHelper.database;
    try {
      await db.rawUpdate(
        'UPDATE volunteers SET rescueCount = rescueCount + 1 WHERE userId = ?',
        [userId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Register Volunteer User with Application
  Future<bool> registerVolunteerWithApplication({
    required UserModelSql user,
    required String experience,
    required String reason,
    required List<String> certificateImages,
  }) async {
    final db = await dbHelper.database;
    try {
      return await db.transaction((txn) async {
        // 1. Insert user
        final userId = await txn.insert('users', user.toMap());

        // 2. Prepare certificate images
        final String? img1 = certificateImages.isNotEmpty ? certificateImages[0] : null;
        final String? img2 = certificateImages.length > 1 ? certificateImages[1] : null;
        final String? img3 = certificateImages.length > 2 ? certificateImages[2] : null;

        // 3. Insert volunteer application
        final now = DateTime.now().toIso8601String();
        await txn.insert('volunteer_applications', {
          'userId': userId,
          'experience': experience,
          'reason': reason,
          'image1': img1,
          'image2': img2,
          'image3': img3,
          'status': 'pending',
          'createdAt': now,
          'updatedAt': now,
        });

        return true;
      });
    } catch (e) {
      log("Error registering volunteer: ${e.toString()}");
      return false;
    }
  }
}
