import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/income_expense.dart';
import '../models/category.dart';
import '../models/user.dart';
import '../../core/constants/app_constants.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Method để kiểm tra database
  Future<void> checkDatabase() async {
    try {
      final db = await database;
      print('Database đã được khởi tạo thành công');
      
      // Kiểm tra bảng categories
      final categoriesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM categories')
      );
      print('Số lượng categories trong database: $categoriesCount');
      
      // Kiểm tra bảng users
      final usersCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users')
      );
      print('Số lượng users trong database: $usersCount');
      
      // Kiểm tra bảng income_expenses
      final incomeExpensesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM income_expenses')
      );
      print('Số lượng income_expenses trong database: $incomeExpensesCount');
      
    } catch (e) {
      print('Lỗi khi kiểm tra database: $e');
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), AppConstants.databaseName);
      print('Đang khởi tạo database tại: $path');
      
      final db = await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
      print('Database đã được khởi tạo thành công');
      return db;
    } catch (e) {
      print('Lỗi khi khởi tạo database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('Đang tạo bảng users...');
      // Tạo bảng User
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          userName TEXT NOT NULL,
          email TEXT,
          fullName TEXT,
          phone TEXT,
          avatar TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          isOnline INTEGER NOT NULL DEFAULT 0,
          accessToken TEXT,
          refreshToken TEXT
        )
      ''');
      print('Đã tạo bảng users thành công');

      print('Đang tạo bảng categories...');
      // Tạo bảng Category
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT,
          text TEXT,
          icon TEXT,
          color TEXT,
          orderIndex INTEGER NOT NULL DEFAULT 0,
          type INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          isSynced INTEGER NOT NULL DEFAULT 0,
          userId TEXT
        )
      ''');
      print('Đã tạo bảng categories thành công');

      print('Đang tạo bảng income_expenses...');
      // Tạo bảng IncomeExpense
      await db.execute('''
        CREATE TABLE income_expenses (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          currency TEXT,
          date TEXT NOT NULL,
          description TEXT,
          type INTEGER NOT NULL,
          categoryId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          isSynced INTEGER NOT NULL DEFAULT 0,
          userId TEXT
        )
      ''');
      print('Đã tạo bảng income_expenses thành công');

      print('Đang tạo indexes...');
      // Tạo indexes
      await db.execute('CREATE INDEX idx_income_expenses_date ON income_expenses (date)');
      await db.execute('CREATE INDEX idx_income_expenses_type ON income_expenses (type)');
      await db.execute('CREATE INDEX idx_income_expenses_category ON income_expenses (categoryId)');
      await db.execute('CREATE INDEX idx_categories_type ON categories (type)');
      await db.execute('CREATE INDEX idx_categories_order ON categories (orderIndex)');
      print('Đã tạo tất cả indexes thành công');
    } catch (e) {
      print('Lỗi khi tạo database schema: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Xử lý upgrade database khi cần
    if (oldVersion < 2) {
      // Thêm các cột mới nếu cần
    }
  }

  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    final data = user.toJson();
    // Chuẩn hóa kiểu bool -> int cho SQLite
    data['isOnline'] = (user.isOnline ? 1 : 0);
    await db.insert(
      'users',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'isOnline = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    final data = user.toJson();
    data['isOnline'] = (user.isOnline ? 1 : 0);
    await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category operations
  Future<void> insertCategory(Category category) async {
    try {
      final db = await database;
      print('Đang insert category: ${category.text} với data: ${category.toJson()}');
      // Chuẩn hóa map cho table (loại bỏ field 'order' vì không có cột này)
      final map = Map<String, dynamic>.from(category.toJson());
      map.remove('order');
      map['orderIndex'] = category.order;
      // Convert bool -> int
      map['isSynced'] = category.isSynced ? 1 : 0;

      final result = await db.insert(
        'categories',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('Đã insert category thành công với id: $result');
    } catch (e) {
      print('Lỗi khi insert category: $e');
      rethrow;
    }
  }

  Future<List<Category>> getCategories({IncomeExpenseType? type}) async {
    try {
      final db = await database;
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (type != null) {
        whereClause = 'type = ?';
        whereArgs = [type.index];
      }

      print('Đang query categories với whereClause: $whereClause, whereArgs: $whereArgs');

      final List<Map<String, dynamic>> maps = await db.query(
        'categories',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'orderIndex ASC',
      );

      print('Query categories trả về ${maps.length} kết quả: ${maps.map((m) => m['text'] ?? m['name']).toList()}');

      final categories = List.generate(maps.length, (i) {
        final row = Map<String, dynamic>.from(maps[i]);
        // Chuẩn hóa cột
        row['order'] = row['orderIndex'];
        row['isSynced'] = (row['isSynced'] == 1);
        return Category.fromJson(row);
      });

      print('Đã convert thành ${categories.length} Category objects: ${categories.map((c) => c.text).toList()}');
      return categories;
    } catch (e) {
      print('Lỗi khi getCategories: $e');
      rethrow;
    }
  }

  Future<Category?> getCategory(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromJson({
        ...maps.first,
        'order': maps.first['orderIndex'],
      });
    }
    return null;
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    final map = Map<String, dynamic>.from(category.toJson());
    map.remove('order');
    map['orderIndex'] = category.order;
    map['isSynced'] = category.isSynced ? 1 : 0;
    await db.update(
      'categories',
      map,
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // IncomeExpense operations
  Future<void> insertIncomeExpense(IncomeExpense incomeExpense) async {
    final db = await database;
    await db.insert(
      'income_expenses',
      incomeExpense.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<IncomeExpense>> getIncomeExpenses({
    IncomeExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    int limit = 0,
    int offset = 0,
  }) async {
    final db = await database;
    
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereConditions.add('type = ?');
      whereArgs.add(type.index);
    }

    if (startDate != null) {
      whereConditions.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereConditions.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (categoryId != null) {
      whereConditions.add('categoryId = ?');
      whereArgs.add(categoryId);
    }

    String? whereClause = whereConditions.isEmpty ? null : whereConditions.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'income_expenses',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
      limit: limit > 0 ? limit : null,
      offset: offset,
    );

    return List.generate(maps.length, (i) => IncomeExpense.fromJson(maps[i]));
  }

  Future<IncomeExpense?> getIncomeExpense(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income_expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return IncomeExpense.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateIncomeExpense(IncomeExpense incomeExpense) async {
    final db = await database;
    await db.update(
      'income_expenses',
      incomeExpense.toJson(),
      where: 'id = ?',
      whereArgs: [incomeExpense.id],
    );
  }

  Future<void> deleteIncomeExpense(String id) async {
    final db = await database;
    await db.delete(
      'income_expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<Map<String, double>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereConditions.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereConditions.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    String? whereClause = whereConditions.isEmpty ? null : whereConditions.join(' AND ');

    // Tổng thu
    final List<Map<String, dynamic>> incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM income_expenses WHERE type = ? ${whereClause != null ? 'AND $whereClause' : ''}',
      [IncomeExpenseType.income.index, ...whereArgs],
    );

    // Tổng chi
    final List<Map<String, dynamic>> expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM income_expenses WHERE type = ? ${whereClause != null ? 'AND $whereClause' : ''}',
      [IncomeExpenseType.expense.index, ...whereArgs],
    );

    double totalIncome = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    double totalExpense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // Sync operations
  Future<List<IncomeExpense>> getUnsyncedIncomeExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income_expenses',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) => IncomeExpense.fromJson(maps[i]));
  }

  Future<List<Category>> getUnsyncedCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return Category.fromJson({
        ...maps[i],
        'order': maps[i]['orderIndex'],
      });
    });
  }

  Future<void> markAsSynced(String table, String id) async {
    final db = await database;
    await db.update(
      table,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
