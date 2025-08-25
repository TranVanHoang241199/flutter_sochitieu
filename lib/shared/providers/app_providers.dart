import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';
import '../models/user.dart';
import '../models/income_expense.dart';
import '../models/category.dart';

// Service Providers
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  final apiService = ref.read(apiServiceProvider);
  return SyncService(databaseService, apiService);
});

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Theme Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  
  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      state = ThemeMode.values[themeIndex];
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
      state = mode;
    } catch (e) {
      // Handle error
    }
  }
}

// User Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  return CurrentUserNotifier(databaseService);
});

class CurrentUserNotifier extends StateNotifier<User?> {
  final DatabaseService _databaseService;
  
  CurrentUserNotifier(this._databaseService) : super(null) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _databaseService.getCurrentUser();
      state = user;
    } catch (e) {
      state = null;
    }
  }

  Future<void> setCurrentUser(User user) async {
    try {
      await _databaseService.insertUser(user);
      state = user;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearCurrentUser() async {
    try {
      if (state != null) {
        await _databaseService.deleteUser(state!.id);
      }
      state = null;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _databaseService.updateUser(user);
      state = user;
    } catch (e) {
      // Handle error
    }
  }
}

// Income Expense Providers
final incomeExpensesProvider = StateNotifierProvider<IncomeExpensesNotifier, List<IncomeExpense>>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  return IncomeExpensesNotifier(databaseService);
});

class IncomeExpensesNotifier extends StateNotifier<List<IncomeExpense>> {
  final DatabaseService _databaseService;
  
  IncomeExpensesNotifier(this._databaseService) : super([]) {
    _loadIncomeExpenses();
  }

  Future<void> _loadIncomeExpenses() async {
    try {
      final incomeExpenses = await _databaseService.getIncomeExpenses();
      state = incomeExpenses;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addIncomeExpense(IncomeExpense incomeExpense) async {
    try {
      await _databaseService.insertIncomeExpense(incomeExpense);
      state = [incomeExpense, ...state];
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateIncomeExpense(IncomeExpense incomeExpense) async {
    try {
      await _databaseService.updateIncomeExpense(incomeExpense);
      state = state.map((item) => item.id == incomeExpense.id ? incomeExpense : item).toList();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteIncomeExpense(String id) async {
    try {
      await _databaseService.deleteIncomeExpense(id);
      state = state.where((item) => item.id != id).toList();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refresh() async {
    await _loadIncomeExpenses();
  }
}

// Category Providers
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  return CategoriesNotifier(databaseService);
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  final DatabaseService _databaseService;
  
  CategoriesNotifier(this._databaseService) : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      print('Đang load categories từ database...');
      final categories = await _databaseService.getCategories();
      print('Đã load được ${categories.length} categories: ${categories.map((c) => c.text).toList()}');

      // Nếu chưa có danh mục nào, tự động tạo danh mục mặc định
      if (categories.isEmpty) {
        print('Chưa có danh mục nào. Đang tạo danh mục mặc định...');
        final now = DateTime.now();
        final defaultCategories = [
          // Chi tiêu
          Category(
            id: 'cat_food',
            name: 'food',
            text: 'Ăn uống',
            icon: '🍽️',
            color: '#FF6B6B',
            order: 1,
            type: IncomeExpenseType.expense,
            createdAt: now,
            updatedAt: now,
            userId: 'offline_user',
          ),
          Category(
            id: 'cat_transport',
            name: 'transport',
            text: 'Di chuyển',
            icon: '🚗',
            color: '#4ECDC4',
            order: 2,
            type: IncomeExpenseType.expense,
            createdAt: now,
            updatedAt: now,
            userId: 'offline_user',
          ),
          Category(
            id: 'cat_shopping',
            name: 'shopping',
            text: 'Mua sắm',
            icon: '🛍️',
            color: '#45B7D1',
            order: 3,
            type: IncomeExpenseType.expense,
            createdAt: now,
            updatedAt: now,
            userId: 'offline_user',
          ),
          // Thu nhập
          Category(
            id: 'cat_salary',
            name: 'salary',
            text: 'Lương',
            icon: '💰',
            color: '#96CEB4',
            order: 1,
            type: IncomeExpenseType.income,
            createdAt: now,
            updatedAt: now,
            userId: 'offline_user',
          ),
          Category(
            id: 'cat_invest',
            name: 'investment',
            text: 'Đầu tư',
            icon: '📈',
            color: '#FFEAA7',
            order: 2,
            type: IncomeExpenseType.income,
            createdAt: now,
            updatedAt: now,
            userId: 'offline_user',
          ),
        ];

        for (final cat in defaultCategories) {
          try {
            await _databaseService.insertCategory(cat);
          } catch (e) {
            print('Lỗi khi tạo mặc định ${cat.text}: $e');
          }
        }

        final reloaded = await _databaseService.getCategories();
        print('Đã tạo xong danh mục mặc định. Tổng: ${reloaded.length}');
        state = reloaded;
        return;
      }

      state = categories;
    } catch (e) {
      print('Lỗi khi load categories: $e');
      state = [];
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _databaseService.insertCategory(category);
      state = [...state, category];
    } catch (e) {
      print('Lỗi khi thêm category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _databaseService.updateCategory(category);
      state = state.map((item) => item.id == category.id ? category : item).toList();
    } catch (e) {
      print('Lỗi khi cập nhật category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _databaseService.deleteCategory(id);
      state = state.where((item) => item.id != id).toList();
    } catch (e) {
      print('Lỗi khi xóa category: $e');
    }
  }

  Future<void> refresh() async {
    print('Đang refresh categories...');
    await _loadCategories();
  }
}

// Statistics Provider
final statisticsProvider = FutureProvider<Map<String, double>>((ref) async {
  final databaseService = ref.read(databaseServiceProvider);
  return await databaseService.getStatistics();
});

// Sync Status Provider
final syncStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final syncService = ref.read(syncServiceProvider);
  return await syncService.getSyncStatus();
});

// Connectivity Provider
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) => results.first);
});

// Filter Providers
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);
final selectedTypeProvider = StateProvider<IncomeExpenseType?>((ref) => null);

// Search Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Pagination Provider
final paginationProvider = StateNotifierProvider<PaginationNotifier, PaginationState>((ref) {
  return PaginationNotifier();
});

class PaginationState {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationState({
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalItems = 0,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    int? totalItems,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }
}

class PaginationNotifier extends StateNotifier<PaginationState> {
  PaginationNotifier() : super(PaginationState());

  void setTotalItems(int totalItems) {
    final hasNextPage = state.currentPage * state.pageSize < totalItems;
    final hasPreviousPage = state.currentPage > 1;
    
    state = state.copyWith(
      totalItems: totalItems,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  void nextPage() {
    if (state.hasNextPage) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.hasPreviousPage) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void goToPage(int page) {
    if (page > 0 && page <= (state.totalItems / state.pageSize).ceil()) {
      state = state.copyWith(currentPage: page);
    }
  }

  void reset() {
    state = PaginationState();
  }
}
