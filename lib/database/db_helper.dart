import 'package:path/path.dart';
import 'package:resqare_app/database/db_seed.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resqare.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Users
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            email TEXT UNIQUE,
            phone TEXT UNIQUE,
            password TEXT,
            role TEXT,
            isVerified INTEGER,
            imgProfile TEXT,
            currentLatitude REAL,
            currentLongitude REAL,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
        // Role: "reporter"|"volunteer"|"admin"

        // 2. Volunteers
        await db.execute('''
          CREATE TABLE volunteers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER UNIQUE,
            isActive INTEGER,
            rescueCount INTEGER DEFAULT 0,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');

        // 3. Reports
        await db.execute('''
          CREATE TABLE reports(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            createdBy INTEGER,
            rescuedBy INTEGER,
            title TEXT NOT NULL,
            description TEXT,
            reportCategory TEXT,
            animalCategory TEXT,
            priorityLevel TEXT,
            status TEXT,
            latitude REAL,
            longitude REAL,
            address TEXT,

            hasInjury INTEGER DEFAULT 0,
            hasBleeding INTEGER DEFAULT 0,
            cannotWalk INTEGER DEFAULT 0,
            isTrapped INTEGER DEFAULT 0,
            isSick INTEGER DEFAULT 0,
            isAbandoned INTEGER DEFAULT 0,

            assignedAt TEXT,
            onRescueAt TEXT,
            completedAt TEXT,
            cancelledAt TEXT,

            createdAt TEXT,
            updatedAt TEXT
          )
        ''');

        // 4. Report Images
        await db.execute('''
          CREATE TABLE report_images(
            id INTEGER PRIMARY KEY AUTOINCREMENT,

            reportId INTEGER,
            image TEXT,

            createdAt TEXT
            )
        ''');

        // 5. Volunter Applications
        await db.execute('''
          CREATE TABLE volunteer_applications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            experience TEXT,
            reason TEXT,
            image1 TEXT,
            image2 TEXT,
            image3 TEXT,
            status TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            reviewedAt TEXT
          )
        ''');

        // 6. Notifications
        await db.execute('''
          CREATE TABLE notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,

            report_id INTEGER,

            title TEXT NOT NULL,
            message TEXT NOT NULL,

            type TEXT NOT NULL,

            is_read INTEGER DEFAULT 0,

            created_at TEXT NOT NULL
          )
        ''');

        // 7. Chat
        await db.execute('''
          CREATE TABLE chat_messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reportId INTEGER,
            senderId INTEGER,
            message TEXT,
            createdAt TEXT,
            isRead INTEGER DEFAULT 0
          )
        ''');

        await DBSeed.seed(db);
      },
    );
  }
}
