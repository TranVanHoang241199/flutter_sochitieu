import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/income_expense.dart';
import '../models/category.dart';
import '../models/user.dart';
import '../../core/constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  String? _accessToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired, handle refresh token
          _handleTokenExpired();
        }
        handler.next(error);
      },
    ));
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Future<void> _handleTokenExpired() async {
    // Implement refresh token logic
    clearAccessToken();
  }

  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String userName, String password) async {
    try {
      final response = await _dio.post(AppConstants.loginEndpoint, data: {
        'userName': userName,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final userData = data['data'];
          setAccessToken(userData['accessToken']);
          
          return {
            'success': true,
            'user': User.fromJson(userData['user']),
            'accessToken': userData['accessToken'],
            'refreshToken': userData['refreshToken'],
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Đăng nhập thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String userName,
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(AppConstants.registerEndpoint, data: {
        'userName': userName,
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'message': 'Đăng ký thành công',
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Đăng ký thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  // Income Expense APIs
  Future<Map<String, dynamic>> getIncomeExpenses({
    int page = 1,
    int pageSize = 20,
    String? search,
    int? type,
    String? range,
    int? year,
    int? month,
    String? currency,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['searchValue'] = search;
      }

      final response = await _dio.get(
        AppConstants.incomeExpenseEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
            'totalCount': data['totalCount'],
            'page': data['page'],
            'pageSize': data['pageSize'],
            'totalPages': data['totalPages'],
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Lấy danh sách thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>> createIncomeExpense(IncomeExpense incomeExpense) async {
    try {
      final response = await _dio.post(
        AppConstants.incomeExpenseEndpoint,
        data: {
          'type': incomeExpense.type.index,
          'amount': incomeExpense.amount,
          'currency': incomeExpense.currency,
          'date': incomeExpense.date.toIso8601String(),
          'description': incomeExpense.description,
          'categoryId': incomeExpense.categoryId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
            'message': 'Tạo giao dịch thành công',
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Tạo giao dịch thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>> updateIncomeExpense(IncomeExpense incomeExpense) async {
    try {
      final response = await _dio.put(
        '${AppConstants.incomeExpenseEndpoint}/${incomeExpense.id}',
        data: {
          'type': incomeExpense.type.index,
          'amount': incomeExpense.amount,
          'currency': incomeExpense.currency,
          'date': incomeExpense.date.toIso8601String(),
          'description': incomeExpense.description,
          'categoryId': incomeExpense.categoryId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
            'message': 'Cập nhật giao dịch thành công',
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Cập nhật giao dịch thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>> deleteIncomeExpense(String id) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.incomeExpenseEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'message': 'Xóa giao dịch thành công',
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Xóa giao dịch thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  // Category APIs
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _dio.get(AppConstants.categoryEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Lấy danh mục thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>> createCategory(Category category) async {
    try {
      final response = await _dio.post(
        AppConstants.categoryEndpoint,
        data: {
          'name': category.name,
          'text': category.text,
          'icon': category.icon,
          'color': category.color,
          'order': category.order,
          'type': category.type.index,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
            'message': 'Tạo danh mục thành công',
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Tạo danh mục thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  // Sync APIs
  Future<Map<String, dynamic>> syncData({
    required List<IncomeExpense> incomeExpenses,
    required List<Category> categories,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.incomeExpenseEndpoint}/sync',
        data: {
          'incomeExpenses': incomeExpenses.map((e) => e.toJson()).toList(),
          'categories': categories.map((e) => e.toJson()).toList(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'message': 'Đồng bộ dữ liệu thành công',
            'syncedIds': data['data']['syncedIds'],
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Đồng bộ dữ liệu thất bại',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi không xác định',
      };
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối bị timeout';
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            return 'Yêu cầu không hợp lệ';
          case 401:
            return 'Không có quyền truy cập';
          case 403:
            return 'Bị cấm truy cập';
          case 404:
            return 'Không tìm thấy tài nguyên';
          case 500:
            return 'Lỗi server';
          default:
            return 'Lỗi kết nối: ${error.response?.statusCode}';
        }
      case DioExceptionType.cancel:
        return 'Yêu cầu bị hủy';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến server';
      default:
        return 'Lỗi kết nối: ${error.message}';
    }
  }
}
