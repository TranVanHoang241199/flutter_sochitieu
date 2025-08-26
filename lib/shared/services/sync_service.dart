import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'api_service.dart';
import '../models/income_expense.dart';
import '../models/category.dart';
import '../models/user.dart';
import '../../core/constants/app_constants.dart';

class SyncService {
  final DatabaseService _databaseService;
  final ApiService _apiService;
  bool _isSyncing = false;

  SyncService(this._databaseService, this._apiService);

  bool get isSyncing => _isSyncing;

  // Kiểm tra kết nối mạng
  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // Đồng bộ dữ liệu từ server về local
  Future<bool> syncFromServer() async {
    if (_isSyncing) return false;
    if (!await checkConnectivity()) return false;

    _isSyncing = true;
    try {
      // Lấy danh mục từ server
      final categoriesResult = await _apiService.getCategories();
      if (categoriesResult['success'] == true) {
        final List<dynamic> categoriesData = categoriesResult['data'];
        final nowIso = DateTime.now().toIso8601String();
        for (final raw in categoriesData) {
          try {
            final m = Map<String, dynamic>.from(raw as Map);
            m['createdAt'] ??= nowIso;
            m['updatedAt'] ??= nowIso;
            m['order'] ??= 0;
            // Chuẩn hóa type: có thể là int hoặc chuỗi
            final t = m['type'];
            if (t is String) {
              final lower = t.toLowerCase();
              m['type'] = (lower.contains('income'))
                  ? IncomeExpenseType.income.index
                  : IncomeExpenseType.expense.index;
            } else if (t is bool) {
              // Ví dụ: true=income, false=expense (tùy backend)
              m['type'] = t ? IncomeExpenseType.income.index : IncomeExpenseType.expense.index;
            }
            final category = Category.fromJson(m);
            await _databaseService.insertCategory(category);
          } catch (_) {
            // Bỏ qua record lỗi để không chặn đồng bộ
          }
        }
      }

      // Lấy giao dịch từ server
      final incomeExpensesResult = await _apiService.getIncomeExpenses(
        pageSize: 1000, // Lấy tất cả giao dịch
      );
      if (incomeExpensesResult['success'] == true) {
        final List<dynamic> incomeExpensesData = incomeExpensesResult['data'];
        for (final raw in incomeExpensesData) {
          try {
            final m = Map<String, dynamic>.from(raw as Map);
            // Đảm bảo các trường tối thiểu tồn tại
            if (m['date'] == null && m['createdAt'] != null) {
              m['date'] = m['createdAt'];
            }
            // type chuẩn hóa về int index nếu cần
            final t = m['type'];
            if (t is String) {
              final lower = t.toLowerCase();
              m['type'] = (lower.contains('income'))
                  ? IncomeExpenseType.income.index
                  : IncomeExpenseType.expense.index;
            } else if (t is bool) {
              m['type'] = t ? IncomeExpenseType.income.index : IncomeExpenseType.expense.index;
            }
            final incomeExpense = IncomeExpense.fromJson(m);
            await _databaseService.insertIncomeExpense(incomeExpense);
          } catch (_) {
            // Bỏ qua record lỗi để không chặn đồng bộ
          }
        }
      }

      return true;
    } catch (e) {
      print('Lỗi khi đồng bộ từ server: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // Đồng bộ dữ liệu từ local lên server
  Future<bool> syncToServer() async {
    if (_isSyncing) return false;
    if (!await checkConnectivity()) return false;

    _isSyncing = true;
    try {
      // Lấy danh mục chưa đồng bộ
      final unsyncedCategories = await _databaseService.getUnsyncedCategories();
      
      // Lấy giao dịch chưa đồng bộ
      final unsyncedIncomeExpenses = await _databaseService.getUnsyncedIncomeExpenses();

      if (unsyncedCategories.isNotEmpty || unsyncedIncomeExpenses.isNotEmpty) {
        // Đồng bộ dữ liệu lên server
        final syncResult = await _apiService.syncData(
          incomeExpenses: unsyncedIncomeExpenses,
          categories: unsyncedCategories,
        );

        if (syncResult['success'] == true) {
          // Đánh dấu đã đồng bộ
          for (final category in unsyncedCategories) {
            await _databaseService.markAsSynced('categories', category.id);
          }
          
          for (final incomeExpense in unsyncedIncomeExpenses) {
            await _databaseService.markAsSynced('income_expenses', incomeExpense.id);
          }

          return true;
        }
      }

      return true;
    } catch (e) {
      print('Lỗi khi đồng bộ lên server: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // Đồng bộ hai chiều
  Future<bool> syncBidirectional() async {
    if (_isSyncing) return false;
    if (!await checkConnectivity()) return false;

    _isSyncing = true;
    try {
      // Đồng bộ từ local lên server trước
      final syncToServerResult = await syncToServer();
      if (!syncToServerResult) return false;

      // Sau đó đồng bộ từ server về local
      final syncFromServerResult = await syncFromServer();
      if (!syncFromServerResult) return false;

      return true;
    } catch (e) {
      print('Lỗi khi đồng bộ hai chiều: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // Đồng bộ tự động theo lịch trình
  Future<void> startAutoSync() async {
    // Kiểm tra kết nối mạng mỗi 15 phút
    await Future.delayed(AppConstants.syncInterval);
    
    if (await checkConnectivity()) {
      await syncBidirectional();
    }
    
    // Tiếp tục lặp
    startAutoSync();
  }

  // Đồng bộ khi có kết nối mạng
  Future<void> syncWhenOnline() async {
    if (await checkConnectivity()) {
      await syncBidirectional();
    }
  }

  // Xử lý khi có dữ liệu mới từ local
  Future<void> handleLocalDataChange() async {
    // Nếu có kết nối mạng, đồng bộ ngay
    if (await checkConnectivity()) {
      await syncToServer();
    }
    // Nếu không có mạng, dữ liệu sẽ được đồng bộ khi có mạng
  }

  // Xử lý khi có dữ liệu mới từ server
  Future<void> handleServerDataChange() async {
    if (await checkConnectivity()) {
      await syncFromServer();
    }
  }

  // Đồng bộ dữ liệu khi đăng nhập
  Future<bool> syncOnLogin(User user) async {
    if (!await checkConnectivity()) return false;

    try {
      // Đồng bộ dữ liệu cũ từ local lên server
      await syncToServer();
      
      // Đồng bộ dữ liệu mới từ server về local
      await syncFromServer();
      
      return true;
    } catch (e) {
      print('Lỗi khi đồng bộ sau đăng nhập: $e');
      return false;
    }
  }

  // Đồng bộ dữ liệu khi đăng xuất
  Future<void> syncOnLogout() async {
    try {
      // Đồng bộ dữ liệu cuối cùng trước khi đăng xuất
      if (await checkConnectivity()) {
        await syncToServer();
      }
    } catch (e) {
      print('Lỗi khi đồng bộ trước đăng xuất: $e');
    }
  }

  // Kiểm tra trạng thái đồng bộ
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final unsyncedCategories = await _databaseService.getUnsyncedCategories();
      final unsyncedIncomeExpenses = await _databaseService.getUnsyncedIncomeExpenses();
      final isOnline = await checkConnectivity();

      return {
        'isOnline': isOnline,
        'isSyncing': _isSyncing,
        'unsyncedCategories': unsyncedCategories.length,
        'unsyncedIncomeExpenses': unsyncedIncomeExpenses.length,
        'lastSyncTime': await _getLastSyncTime(),
      };
    } catch (e) {
      return {
        'isOnline': false,
        'isSyncing': false,
        'unsyncedCategories': 0,
        'unsyncedIncomeExpenses': 0,
        'lastSyncTime': null,
        'error': e.toString(),
      };
    }
  }

  // Lấy thời gian đồng bộ cuối cùng
  Future<DateTime?> _getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTimestamp = prefs.getInt('last_sync_timestamp');
      if (lastSyncTimestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
      }
    } catch (e) {
      print('Lỗi khi lấy thời gian đồng bộ: $e');
    }
    return null;
  }

  // Cập nhật thời gian đồng bộ
  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_sync_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Lỗi khi cập nhật thời gian đồng bộ: $e');
    }
  }

  // Dừng đồng bộ tự động
  void stopAutoSync() {
    _isSyncing = false;
  }
}
