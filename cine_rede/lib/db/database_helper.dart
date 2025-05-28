import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cine_rede/models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cine_rede.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        authorId TEXT,
        imageUrl TEXT,
        description TEXT,
        movieNote REAL,
        movieTitle TEXT,
        genres TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        username TEXT,
        photoUrl TEXT,
        friends TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE favoritos (
        userId TEXT,
        postId TEXT,
        PRIMARY KEY (userId, postId)
      )
    ''');
  }

  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<bool> isFavorito(String userId, String postId) async {
    final db = await instance.database;
    final result = await db.query(
      'favoritos',
      where: 'userId = ? AND postId = ?',
      whereArgs: [userId, postId],
    );
    return result.isNotEmpty;
  }

  Future<void> toggleFavorito(String userId, String postId) async {
    final db = await instance.database;
    final exists = await isFavorito(userId, postId);

    if (exists) {
      await db.delete('favoritos',
          where: 'userId = ? AND postId = ?', whereArgs: [userId, postId]);
    } else {
      await db.insert('favoritos', {
        'userId': userId,
        'postId': postId,
      });
    }
  }

  Future<List<String>> getPostsFavoritosDoUsuario(String userId) async {
    final db = await instance.database;
    final result =
        await db.query('favoritos', where: 'userId = ?', whereArgs: [userId]);
    return result.map((row) => row['postId'].toString()).toList();
  }
}
