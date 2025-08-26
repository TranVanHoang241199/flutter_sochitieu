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

        // Common flags/structures from various backends
        final bool successFlag =
            (data is Map && (data['success'] == true || data['isSuccess'] == true)) ||
            (data is Map && data['data'] != null);

        // Try to extract payload from multiple shapes
        final dynamic payload =
            (data is Map && data['data'] != null) ? data['data'] : data;

        // Extract tokens with multiple key possibilities
        final String? accessToken = (payload is Map)
            ? (payload['accessToken'] ?? payload['token'] ?? payload['access_token']) as String?
            : (data['accessToken'] ?? data['token'] ?? data['access_token']) as String?;
        final String? refreshToken = (payload is Map)
            ? (payload['refreshToken'] ?? payload['refresh_token']) as String?
            : (data['refreshToken'] ?? data['refresh_token']) as String?;

        // Extract user object from multiple locations / key names
        dynamic userJson = (payload is Map)
            ? (payload['user'] ?? payload['account'] ?? payload['profile'])
            : null;
        if (userJson == null && data is Map) {
          userJson = data['user'] ?? data['account'] ?? data['profile'];
        }

        // If user not wrapped, sometimes backend returns user fields at root
        if (userJson == null && payload is Map) {
          final possibleUserKeys = ['id', 'userName', 'username', 'fullName'];
          final hasUserShape = possibleUserKeys.any((k) => payload.containsKey(k));
          if (hasUserShape) userJson = payload;
        }

        if (accessToken != null && userJson is Map) {
          // Normalize user fields and fill missing values
          final nowIso = DateTime.now().toIso8601String();
          final normalized = <String, dynamic>{
            'id': userJson['id'] ?? userJson['userId'] ?? userJson['uid'] ?? userName,
            'userName': userJson['userName'] ?? userJson['username'] ?? userName,
            'email': userJson['email'],
            'fullName': userJson['fullName'] ?? userJson['name'] ?? userJson['displayName'],
            'phone': userJson['phone'],
            'avatar': userJson['avatar'] ?? userJson['avatarUrl'],
            'createdAt': userJson['createdAt'] ?? nowIso,
            'updatedAt': userJson['updatedAt'] ?? nowIso,
            'isOnline': true,
            'accessToken': accessToken,
            'refreshToken': refreshToken,
          };

          try {
            final user = User.fromJson(normalized);
            setAccessToken(accessToken);
            return {
              'success': true,
              'user': user,
              'accessToken': accessToken,
              'refreshToken': refreshToken,
            };
          } catch (_) {
            // Fallback: build User minimally if adapter parsing is strict
            final user = User(
              id: normalized['id'],
              userName: normalized['userName'],
              email: normalized['email'],
              fullName: normalized['fullName'],
              phone: normalized['phone'],
              avatar: normalized['avatar'],
              createdAt: DateTime.parse(normalized['createdAt']),
              updatedAt: DateTime.parse(normalized['updatedAt']),
              isOnline: true,
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            setAccessToken(accessToken);
            return {
              'success': true,
              'user': user,
              'accessToken': accessToken,
              'refreshToken': refreshToken,
            };
          }
        }

        // If backend uses boolean flags but no tokens/user provided
        if (successFlag) {
          return {
            'success': false,
            'message': data['message'] ?? 'Thiếu thông tin user hoặc token từ máy chủ',
          };
        }
      }
      return {
        'success': false,
        'message': response.data is Map ? (response.data['message'] ?? 'Đăng nhập thất bại') : 'Đăng nhập thất bại',
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

  Future<Map<String, dynamic>> me() async {
    try {
      final response = await _dio.get(AppConstants.accountMeEndpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final userData = data['data'];
          return {
            'success': true,
            'user': User.fromJson(userData),
          };
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Lấy thông tin người dùng thất bại',
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

  Future<Map<String, dynamic>> updateCategory(Category category) async {
    try {
      final response = await _dio.put(
        '${AppConstants.categoryEndpoint}/${category.id}',
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
            'message': 'Cập nhật danh mục thành công',
          };
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Cập nhật danh mục thất bại',
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

  Future<Map<String, dynamic>> deleteCategory(String id) async {
    try {
      final response = await _dio.delete('${AppConstants.categoryEndpoint}/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'message': 'Xóa danh mục thành công',
          };
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Xóa danh mục thất bại',
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

  // Report APIs
  Future<Map<String, dynamic>> getReportOverview({String? from, String? to}) async {
    try {
      final response = await _dio.get(
        AppConstants.reportOverviewEndpoint,
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
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
        'message': response.data['message'] ?? 'Lấy báo cáo tổng quan thất bại',
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

  Future<Map<String, dynamic>> getReportByCategory({required int year, required int month}) async {
    try {
      final response = await _dio.get(
        AppConstants.reportByCategoryEndpoint,
        queryParameters: {'year': year, 'month': month},
      );
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
        'message': response.data['message'] ?? 'Lấy báo cáo theo danh mục thất bại',
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

  Future<Map<String, dynamic>> getReportByMonth({required int year}) async {
    try {
      final response = await _dio.get(
        AppConstants.reportByMonthEndpoint,
        queryParameters: {'year': year},
      );
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
        'message': response.data['message'] ?? 'Lấy báo cáo theo tháng thất bại',
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

  // Settings APIs
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _dio.get(AppConstants.settingsEndpoint);
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
        'message': response.data['message'] ?? 'Lấy cài đặt thất bại',
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

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _dio.put(AppConstants.settingsEndpoint, data: settings);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
            'message': 'Cập nhật cài đặt thành công',
          };
        }
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Cập nhật cài đặt thất bại',
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
