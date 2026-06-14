import 'package:sqflite/sqflite.dart';

class DBSeed {
  static Future<void> seed(Database db) async {
    await _seedUsers(db);
    await _seedVolunteers(db);
    await _seedVolunteerApplications(db);
    await _seedReports(db);
    await _seedReportImages(db);
    await _seedNotifications(db);
    await _seedChat(db);
  }

  // ================= USERS =================
  static Future<void> _seedUsers(Database db) async {
    final now = DateTime.now().toIso8601String();

    // ID 1: Admin
    await db.insert('users', {
      'fullName': 'Admin ResQare',
      'email': 'admin@resqare.com',
      'phone': '081100000001',
      'password': 'admin123',
      'role': 'admin',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.1754,
      'currentLongitude': 106.8271,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 2: Hanan (Reporter)
    await db.insert('users', {
      'fullName': 'Hanan Zahidah',
      'email': 'hanan@mail.com',
      'phone': '081200000002',
      'password': 'password123',
      'role': 'reporter',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.2000,
      'currentLongitude': 106.8166,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 3: Alyssa (Reporter)
    await db.insert('users', {
      'fullName': 'Alyssa Wulan',
      'email': 'alyssa@mail.com',
      'phone': '081200000003',
      'password': 'password123',
      'role': 'reporter',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.2100,
      'currentLongitude': 106.8200,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 4: Rania (Volunteer)
    await db.insert('users', {
      'fullName': 'Rania Ataki',
      'email': 'volunteer1@resqare.com',
      'phone': '081300000004',
      'password': 'password123',
      'role': 'volunteer',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.2300,
      'currentLongitude': 106.8400,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 5: Aline (Pending Application, logged in as Reporter)
    await db.insert('users', {
      'fullName': 'Aline Sari',
      'email': 'volunteer2@resqare.com',
      'phone': '081400000005',
      'password': 'password123',
      'role': 'reporter',
      'isVerified': 0,
      'imgProfile': null,
      'currentLatitude': -6.1550,
      'currentLongitude': 106.7200,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 6: Budi (Reporter)
    await db.insert('users', {
      'fullName': 'Budi Santoso',
      'email': 'budi@mail.com',
      'phone': '081200000006',
      'password': 'password123',
      'role': 'reporter',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.1850,
      'currentLongitude': 106.8220,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 7: Citra (Reporter)
    await db.insert('users', {
      'fullName': 'Citra Lestari',
      'email': 'citra@mail.com',
      'phone': '081200000007',
      'password': 'password123',
      'role': 'reporter',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.1244,
      'currentLongitude': 106.8406,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 8: Eko (Volunteer)
    await db.insert('users', {
      'fullName': 'Eko Prasetyo',
      'email': 'volunteer3@resqare.com',
      'phone': '081300000008',
      'password': 'password123',
      'role': 'volunteer',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.1684,
      'currentLongitude': 106.7583,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 9: Fitri (Volunteer)
    await db.insert('users', {
      'fullName': 'Fitri Handayani',
      'email': 'volunteer4@resqare.com',
      'phone': '081300000009',
      'password': 'password123',
      'role': 'volunteer',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.2444,
      'currentLongitude': 106.8006,
      'createdAt': now,
      'updatedAt': now,
    });

    // ID 10: Guntur (Volunteer)
    await db.insert('users', {
      'fullName': 'Guntur Prabowo',
      'email': 'volunteer5@resqare.com',
      'phone': '081300000010',
      'password': 'password123',
      'role': 'volunteer',
      'isVerified': 1,
      'imgProfile': null,
      'currentLatitude': -6.2250,
      'currentLongitude': 106.8860,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // ================= VOLUNTEERS =================
  static Future<void> _seedVolunteers(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('volunteers', {
      'userId': 4,
      'isActive': 1,
      'rescueCount': 12,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('volunteers', {
      'userId': 8,
      'isActive': 1,
      'rescueCount': 5,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('volunteers', {
      'userId': 9,
      'isActive': 1,
      'rescueCount': 3,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('volunteers', {
      'userId': 10,
      'isActive': 1,
      'rescueCount': 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // ================= APPLICATIONS =================
  static Future<void> _seedVolunteerApplications(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('volunteer_applications', {
      'userId': 5,
      'experience':
          'Pernah rescue kucing jalanan & ikut komunitas penyayang hewan di Jakbar',
      'reason':
          'Ingin berkontribusi langsung menyelamatkan hewan telantar di Jakarta',
      'image1': 'cert1.jpg',
      'image2': 'activity2.jpg',
      'image3': 'activity3.jpg',
      'status': 'pending',
      'createdAt': now,
      'updatedAt': now,
      'reviewedAt': null,
    });
  }

  // ================= REPORTS =================
  static Future<void> _seedReports(Database db) async {
    final now = DateTime.now().toIso8601String();

    // 1. Kucing terluka (Menteng, Jakarta Pusat)
    await db.insert('reports', {
      'createdBy': 2,
      'rescuedBy': 4,
      'title': 'Kucing terluka di pinggir jalan',
      'description': 'Kucing pincang dan lemas, ada luka di perut berdarah.',
      'animalCategory': 'cat',
      'priorityLevel': 'urgent',
      'status': 'on_rescue',
      'latitude': -6.200000,
      'longitude': 106.816666,
      'address': 'Menteng, Jakarta Pusat',
      'hasInjury': 1,
      'hasBleeding': 1,
      'cannotWalk': 1,
      'isTrapped': 0,
      'isSick': 0,
      'isAbandoned': 0,
      'assignedAt': now,
      'onRescueAt': now,
      'completedAt': null,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    // 2. Anjing terjebak (Senayan, Jakarta Selatan)
    await db.insert('reports', {
      'createdBy': 3,
      'rescuedBy': null,
      'title': 'Anjing terjebak di selokan',
      'description':
          'Anjing berukuran sedang terjebak di saluran air yang cukup dalam, tidak bisa naik.',
      'animalCategory': 'dog',
      'priorityLevel': 'urgent',
      'status': 'pending',
      'latitude': -6.210000,
      'longitude': 106.820000,
      'address': 'Senayan, Jakarta Selatan',
      'hasInjury': 0,
      'hasBleeding': 0,
      'cannotWalk': 0,
      'isTrapped': 1,
      'isSick': 0,
      'isAbandoned': 1,
      'assignedAt': null,
      'onRescueAt': null,
      'completedAt': null,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    // 3. Burung sayap terluka (Menteng, Jakarta Pusat)
    await db.insert('reports', {
      'createdBy': 2,
      'rescuedBy': 8,
      'title': 'Burung elang sayap terluka',
      'description':
          'Burung elang jatuh di halaman kantor dengan sayap kanan terluka berdarah.',
      'animalCategory': 'bird',
      'priorityLevel': 'medium',
      'status': 'completed',
      'latitude': -6.185000,
      'longitude': 106.822000,
      'address': 'Menteng, Jakarta Pusat',
      'hasInjury': 1,
      'hasBleeding': 1,
      'cannotWalk': 1,
      'isTrapped': 0,
      'isSick': 0,
      'isAbandoned': 1,
      'assignedAt': now,
      'onRescueAt': now,
      'completedAt': now,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    // 4. Kucing terjebak (Pademangan, Jakarta Utara)
    await db.insert('reports', {
      'createdBy': 6,
      'rescuedBy': null,
      'title': 'Kucing terjebak di atap ruko',
      'description':
          'Kucing mengeong keras sejak kemarin di atap ruko berlantai 3.',
      'animalCategory': 'cat',
      'priorityLevel': 'medium',
      'status': 'pending',
      'latitude': -6.124400,
      'longitude': 106.840600,
      'address': 'Pademangan, Jakarta Utara',
      'hasInjury': 0,
      'hasBleeding': 0,
      'cannotWalk': 0,
      'isTrapped': 1,
      'isSick': 0,
      'isAbandoned': 0,
      'assignedAt': null,
      'onRescueAt': null,
      'completedAt': null,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    // 5. Anjing telantar kelaparan (Kebon Jeruk, Jakarta Barat)
    await db.insert('reports', {
      'createdBy': 7,
      'rescuedBy': 9,
      'title': 'Anjing telantar kelaparan',
      'description':
          'Anjing liar terlihat sangat kurus dan lemas di dekat tempat sampah pasar.',
      'animalCategory': 'dog',
      'priorityLevel': 'low',
      'status': 'on_rescue',
      'latitude': -6.168400,
      'longitude': 106.758300,
      'address': 'Kebon Jeruk, Jakarta Barat',
      'hasInjury': 0,
      'hasBleeding': 0,
      'cannotWalk': 0,
      'isTrapped': 0,
      'isSick': 1,
      'isAbandoned': 1,
      'assignedAt': now,
      'onRescueAt': now,
      'completedAt': null,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    // 6. Burung hantu terluka (Ragunan, Jakarta Selatan)
    await db.insert('reports', {
      'createdBy': 3,
      'rescuedBy': 10,
      'title': 'Burung hantu terluka',
      'description':
          'Ditemukan burung hantu menabrak tiang listrik dan tidak bisa terbang kembali.',
      'animalCategory': 'bird',
      'priorityLevel': 'low',
      'status': 'completed',
      'latitude': -6.290000,
      'longitude': 106.815000,
      'address': 'Ragunan, Jakarta Selatan',
      'hasInjury': 1,
      'hasBleeding': 0,
      'cannotWalk': 1,
      'isTrapped': 0,
      'isSick': 0,
      'isAbandoned': 1,
      'assignedAt': now,
      'onRescueAt': now,
      'completedAt': now,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    // 7. Ular masuk pemukiman (Duren Sawit, Jakarta Timur)
    await db.insert('reports', {
      'createdBy': 6,
      'rescuedBy': 4,
      'title': 'Ular kobra masuk dapur warga',
      'description':
          'Ular kobra masuk ke dapur rumah warga, ukuran sekitar 1.5 meter membahayakan anak-anak.',
      'animalCategory': 'reptile',
      'priorityLevel': 'urgent',
      'status': 'on_rescue',
      'latitude': -6.225000,
      'longitude': 106.886000,
      'address': 'Duren Sawit, Jakarta Timur',
      'hasInjury': 0,
      'hasBleeding': 0,
      'cannotWalk': 0,
      'isTrapped': 1,
      'isSick': 0,
      'isAbandoned': 0,
      'assignedAt': now,
      'onRescueAt': now,
      'completedAt': null,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    // 8. Anak kucing terjepit pipa (Kalideres, Jakarta Barat)
    await db.insert('reports', {
      'createdBy': 7,
      'rescuedBy': null,
      'title': 'Anak kucing terjepit pipa air',
      'description':
          'Kepala anak kucing terjepit di lubang pipa pembuangan air kamar mandi warga.',
      'animalCategory': 'cat',
      'priorityLevel': 'medium',
      'status': 'pending',
      'latitude': -6.155000,
      'longitude': 106.720000,
      'address': 'Kalideres, Jakarta Barat',
      'hasInjury': 0,
      'hasBleeding': 0,
      'cannotWalk': 0,
      'isTrapped': 1,
      'isSick': 0,
      'isAbandoned': 1,
      'assignedAt': null,
      'onRescueAt': null,
      'completedAt': null,
      'cancelledAt': null,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // ================= REPORT IMAGES =================
  static Future<void> _seedReportImages(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('report_images', {
      'reportId': 1,
      'image': 'cat_injury_1.jpg',
      'createdAt': now,
    });

    await db.insert('report_images', {
      'reportId': 2,
      'image': 'dog_street.jpg',
      'createdAt': now,
    });

    await db.insert('report_images', {
      'reportId': 3,
      'image': 'bird_rescue.jpg',
      'createdAt': now,
    });
  }

  // ================= NOTIFICATIONS =================
  static Future<void> _seedNotifications(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('notifications', {
      'user_id': 2,
      'report_id': 1,
      'title': 'Volunteer menerima laporan',
      'message': 'Rania mulai menangani laporan kucing terluka',
      'type': 'report_update',
      'is_read': 0,
      'created_at': now,
    });

    await db.insert('notifications', {
      'user_id': 4,
      'report_id': 1,
      'title': 'Tugas baru',
      'message': 'Anda ditugaskan ke laporan baru',
      'type': 'assignment',
      'is_read': 0,
      'created_at': now,
    });
  }

  // ================= CHAT =================
  static Future<void> _seedChat(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('chat_messages', {
      'reportId': 1,
      'senderId': 2,
      'message': 'Halo, apakah sudah ditangani?',
      'createdAt': now,
      'isRead': 1,
    });

    await db.insert('chat_messages', {
      'reportId': 1,
      'senderId': 4,
      'message': 'Iya, saya sedang menuju lokasi',
      'createdAt': now,
      'isRead': 1,
    });

    await db.insert('chat_messages', {
      'reportId': 1,
      'senderId': 2,
      'message': 'Baik, hati-hati ya',
      'createdAt': now,
      'isRead': 0,
    });
  }
}
