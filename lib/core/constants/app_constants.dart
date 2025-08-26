class AppConstants {
  // App Info
  static const String appName = 'Sổ Chi Tiêu';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'http://sochitieu.somee.com/api';
  static const String loginEndpoint = '/account/login';
  static const String registerEndpoint = '/account/register';
  static const String incomeExpenseEndpoint = '/incomeexpense';
  static const String categoryEndpoint = '/category';
  static const String accountMeEndpoint = '/account/me';
  static const String reportOverviewEndpoint = '/report/overview';
  static const String reportByCategoryEndpoint = '/report/by-category';
  static const String reportByMonthEndpoint = '/report/by-month';
  static const String settingsEndpoint = '/setting';
  
  // Database
  static const String databaseName = 'sochitieu.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String userKey = 'user';
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Default Values
  static const String defaultCurrency = 'VND';
  static const int defaultPageSize = 20;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Sync Intervals
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration retryInterval = Duration(seconds: 30);
  
  // Error Messages
  static const String networkErrorMessage = 'Không có kết nối mạng';
  static const String serverErrorMessage = 'Lỗi server, vui lòng thử lại sau';
  static const String unknownErrorMessage = 'Đã xảy ra lỗi không xác định';
  static const String offlineModeMessage = 'Bạn đang ở chế độ offline';
}
