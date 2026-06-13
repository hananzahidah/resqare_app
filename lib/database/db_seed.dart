import 'package:sqflite/sqflite.dart';

class DBSeed {
  static Future<void> seed(Database db) async {
    final now = DateTime.now().toIso8601String();

    await _seedUsers(db, now);
    await _seedVolunteers(db, now);
    await _seedReports(db, now);
    await _seedNotifications(db, now);
  }

  static Future<void> _seedUsers(Database db, String now) async {
    await db.insert('users', {
      'fullName': 'Hanan Zahidah',
      'email': 'hanan@mail.com',
      'phone': '081111111111',
      'password': 'password123',
      'role': 'reporter',
      'isVerified': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('users', {
      'fullName': 'Alyssa Wulan',
      'email': 'alyssa@mail.com',
      'phone': '082222222222',
      'password': 'password123',
      'role': 'reporter',
      'isVerified': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('users', {
      'fullName': 'Rania Ataki',
      'email': 'volunteer1@resqare.com',
      'phone': '083333333333',
      'password': 'password123',
      'role': 'volunteer',
      'isVerified': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('users', {
      'fullName': 'Aline Sari',
      'email': 'volunteer2@resqare.com',
      'phone': '084444444444',
      'password': 'password123',
      'role': 'volunteer',
      'isVerified': 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  static Future<void> _seedVolunteers(Database db, String now) async {
    await db.insert('volunteers', {
      'userId': 3,
      'status': 'active',
      'rescueCount': 12,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('volunteers', {
      'userId': 4,
      'status': 'active',
      'rescueCount': 5,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  static Future<void> _seedReports(Database db, String now) async {
    await db.insert('reports', {
      'createdBy': 1,
      'title': 'Kucing Terluka di Pinggir Jalan',
      'description': 'Kucing terlihat pincang dan lemas.',
      'animalCategory': 'Cat',
      'priorityLevel': 'High',
      'status': 'pending',
      'latitude': -6.200000,
      'longitude': 106.816666,
      'address': 'Jakarta Pusat',
      'hasInjury': 1,
      'cannotWalk': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('reports', {
      'createdBy': 2,
      'rescuedBy': 3,
      'title': 'Anjing Terjebak Selokan',
      'description': 'Anjing tidak bisa keluar.',
      'animalCategory': 'Dog',
      'priorityLevel': 'Urgent',
      'status': 'on rescue',
      'latitude': -6.210000,
      'longitude': 106.820000,
      'address': 'Jakarta Selatan',
      'isTrapped': 1,
      'assignedAt': now,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('reports', {
      'createdBy': 1,
      'rescuedBy': 4,
      'title': 'Burung Jatuh dari Pohon',
      'description': 'Burung ditemukan tidak bisa terbang.',
      'animalCategory': 'Bird',
      'priorityLevel': 'Medium',
      'status': 'completed',
      'completedAt': now,
      'latitude': -6.230000,
      'longitude': 106.840000,
      'address': 'Jakarta Timur',
      'createdAt': now,
      'updatedAt': now,
    });
  }

  static Future<void> _seedNotifications(Database db, String now) async {
    await db.insert('notifications', {
      'user_id': 1,
      'report_id': 1,
      'title': 'Laporan berhasil dibuat',
      'message': 'Volunteer akan segera meninjau laporan Anda.',
      'type': 'report_created',
      'created_at': now,
    });

    await db.insert('notifications', {
      'user_id': 3,
      'report_id': 1,
      'title': 'Laporan baru di sekitar Anda',
      'message': 'Kucing terluka membutuhkan bantuan.',
      'type': 'new_report',
      'created_at': now,
    });
  }
}
