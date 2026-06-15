import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fit_byte_v3.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name $textType,
        email $textType,
        phoneNumber TEXT,
        profileImageUrl TEXT,
        age $integerType,
        height $realType,
        weight $realType,
        goalWeight $realType,
        gender $textType,
        activityLevel $textType,
        dietaryPreference $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE calorie_logs (
        id $idType,
        title $textType,
        subtitle $textType,
        calories $integerType,
        protein REAL DEFAULT 0,
        carbs REAL DEFAULT 0,
        fat REAL DEFAULT 0,
        icon $textType,
        date $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id $idType,
        title $textType,
        duration $integerType,
        caloriesBurned $integerType,
        date $textType
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
